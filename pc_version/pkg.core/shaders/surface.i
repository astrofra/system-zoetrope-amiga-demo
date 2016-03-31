variant {
	vertex {
		out {
			float vDepth;
			vec3 vViewPos;
			vec4 vPixelPos;
			vec3 vPixelNormal;
			mat4 vSkinMatrix;
			mat3 vSkinNormalMatrix;
			vec4 vProjPos;
			vec4 vPrevProjPos;
			vec4 vPixelPickingId;
			vec2 vTerrainUV;
			mat3 vInstanceNormalMatrix;
			mat3 vInstanceNormalViewMatrix;
		}

		global %{
	vec4 cubic(float v)
	{
		vec4 n = vec4(1.0, 2.0, 3.0, 4.0) - v;
		vec4 s = n * n * n;
		float x = s.x;
		float y = s.y - 4.0 * s.x;
		float z = s.z - 4.0 * s.y + 6.0 * s.x;
		float w = 6.0 - x - y - z;
		return vec4(x, y, z, w);
	}

	// Perform bi-cubic sampling of a 2D texture
	vec4 bicubic_filter(sampler2D tex, vec2 texcoord, vec2 texscale)
	{
		float fx = fract(texcoord.x);
		float fy = fract(texcoord.y);
		texcoord.x -= fx;
		texcoord.y -= fy;

		vec4 xcubic = cubic(fx);
		vec4 ycubic = cubic(fy);

		vec4 c = vec4(texcoord.x - 0.5, texcoord.x + 1.5, texcoord.y - 0.5, texcoord.y + 1.5);
		vec4 s = vec4(xcubic.x + xcubic.y, xcubic.z + xcubic.w, ycubic.x + ycubic.y, ycubic.z + ycubic.w);
		vec4 offset = c + vec4(xcubic.y, xcubic.w, ycubic.y, ycubic.w) / s;

		vec4 sample0 = texture2D(tex, vec2(offset.x, offset.z) * texscale);
		vec4 sample1 = texture2D(tex, vec2(offset.y, offset.z) * texscale);
		vec4 sample2 = texture2D(tex, vec2(offset.x, offset.w) * texscale);
		vec4 sample3 = texture2D(tex, vec2(offset.y, offset.w) * texscale);

		float sx = s.x / (s.x + s.y);
		float sy = s.z / (s.z + s.w);

		return mix(mix(sample3, sample2, sx), mix(sample1, sample0, sx), sy);
	}

#if defined(IS_TERRAIN)
	float SampleTerrain(vec2 uv)
	{
		//float y = bicubic_filter(vTerrainHeightmap, uv * vTerrainHeightmapSize, 1.0 / vTerrainHeightmapSize).r;
		float y = texture2D(vTerrainHeightmap, uv).r;
		return y * vTerrainSize.y;
	}
#endif // IS_TERRAIN

#if defined(USE_HW_INSTANCING)
	// redirect variables to attributes
	#define vModelMatrix vInstanceModelMatrix
	#define vPreviousModelMatrix vInstancePreviousModelMatrix
	#define vPickingId vInstancePickingId

	// the following values are computed in the shader as they no longer are invariants
	#define vNormalMatrix vInstanceNormalMatrix
	#define vNormalViewMatrix vInstanceNormalViewMatrix
	#define vModelViewMatrix vInstanceModelViewMatrix
	#define vModelViewProjectionMatrix vInstanceModelViewProjectionMatrix
#endif // USE_HW_INSTANCING
		%}

		source %{
	vec4 %position%;
	vec3 %normal%;

#if defined(IS_TERRAIN)
	vec3 pos = vTerrainPatchOrigin + vec3(vUV0.x, 0, vUV0.y) * vTerrainPatchSize; // vertex position inside terrain

	// compute the normalized UV
	vec3 norm_pos = pos / vTerrainSize;
	vTerrainUV = norm_pos.xz + vec2(0.5, 0.5);

	// read elevation from height map
	pos.y = SampleTerrain(vTerrainUV);
# if !defined(VERTEX_SHADER_WRITES_TO_POSITION)
	%position% = vec4(pos, 1.0);
# endif

	// build tangent frame from the height map
	float k = 0.5;
	vec2 T_uv = vec2(k / vTerrainSize.x, 0);
	vec2 B_uv = vec2(0, k / vTerrainSize.z);

	float T_y = SampleTerrain(vTerrainUV + T_uv) - pos.y;
	float B_y = SampleTerrain(vTerrainUV + B_uv) - pos.y;

	vec3 T = vec3(k, T_y, 0.0);
	vec3 B = vec3(0.0, B_y, k);

# if !defined(VERTEX_SHADER_WRITES_TO_NORMAL)
	%normal% = vec3(T_y, k, -B_y); // get normal from the tangent frame
# endif

#else // !IS_TERRAIN

# if defined(USE_HW_INSTANCING)
	// compute HW instancing invariants and hope the compiler optimize these out when left unreferenced
	vInstanceNormalMatrix = mat3(normalize(vModelMatrix[0].xyz), normalize(vModelMatrix[1].xyz), normalize(vModelMatrix[2].xyz));
	vInstanceNormalViewMatrix = _mtx_mul(mat3(vViewMatrix[0].xyz, vViewMatrix[1].xyz, vViewMatrix[2].xyz), vInstanceNormalMatrix);
	mat4 vInstanceModelViewMatrix = _mtx_mul(vViewMatrix, vModelMatrix);
	mat4 vInstanceModelViewProjectionMatrix = _mtx_mul(vViewProjectionMatrix, vModelMatrix);
# endif // USE_HW_INSTANCING

# if !defined(VERTEX_SHADER_WRITES_TO_POSITION)
	%position% = vec4(vPosition, 1.0);
# endif

# if !defined(VERTEX_SHADER_WRITES_TO_NORMAL)
	%normal% = vNormal;
# endif

# if defined(USE_SKINNING)
	vSkinMatrix = BuildSkinMatrix();
	vSkinNormalMatrix = _mat4_to_mat3(vSkinMatrix); // FIXME will break with scaling...
#endif

#endif // !IS_TERRAIN

	// SHADER CODE
	%shader_code%

#if defined(USE_SKINNING)
	vec4 vPreSkinPosition = %position%;
	%position% = _mtx_mul(vSkinMatrix, %position%);
	%normal% = _mtx_mul(vSkinNormalMatrix, %normal%);
#endif

#if defined(PIXEL_SHADER_REQUIRES_VPIXELPOS)
	vPixelPos = %position%;
#endif

#if defined(PIXEL_SHADER_REQUIRES_VPIXELNORMAL)
	vPixelNormal = _mtx_mul(vNormalViewMatrix, %normal%);
#endif

	// START RenderPass surface/shader glue code
#if defined(IS_DEPTH_PASS)

	%out.position% = _mtx_mul(vModelViewProjectionMatrix, %position%);

#elif defined(IS_FORWARD_CONSTANT_PASS)

	vDepth = _mtx_mul(vModelViewMatrix, %position%).z;
	vec4 _f_pos = _mtx_mul(vModelViewProjectionMatrix, %position%);
# if defined(USE_DEPTH_BIAS)
	_f_pos.z += DEPTH_BIAS;
# endif
	%out.position% = _f_pos;

#elif defined(IS_FORWARD_LIGHT_CONTRIBUTION_PASS)

	vViewPos = _mtx_mul(vModelViewMatrix, %position%).xyz;
	vec4 _f_pos = _mtx_mul(vModelViewProjectionMatrix, %position%);
# if defined(DEPTH_BIAS)
	_f_pos.z += DEPTH_BIAS;
# endif
	%out.position% = _f_pos;

#elif defined(IS_DEFERRED_ATTRIBUTE_PASS)

	vDepth = _mtx_mul(vModelViewMatrix, %position%).z;
	vec4 _f_pos = _mtx_mul(vModelViewProjectionMatrix, %position%);
# if defined(DEPTH_BIAS)
	_f_pos.z += DEPTH_BIAS;
# endif
	%out.position% = _f_pos;

#elif defined(IS_POSTPROCESS_NORMALDEPTH_PASS)

	vDepth = _mtx_mul(vModelViewMatrix, %position%).z;
	%out.position% = _mtx_mul(vModelViewProjectionMatrix, %position%);

#elif defined(IS_POSTPROCESS_VELOCITY_PASS)

	mat4 vPreviousModelViewMatrix = _mtx_mul(vViewMatrix, vPreviousModelMatrix);
	mat4 vPreviousModelViewProjectionMatrix = _mtx_mul(vViewProjectionMatrix, vPreviousModelMatrix);
# if defined(USE_SKINNING)
	mat4 previous_skin_mtx = BuildPreviousSkinMatrix();
	vec4 f_previous_position = _mtx_mul(previous_skin_mtx, vPreSkinPosition); // %position% is already skinned...
# else
	vec4 f_previous_position = %position%;
# endif

	// projected vertices
	vProjPos = _mtx_mul(vModelViewProjectionMatrix, %position%);
	vPrevProjPos = _mtx_mul(vPreviousModelViewProjectionMatrix, f_previous_position);

	/*
		Volume expansion along the motion vector.
		Extrusions are slightly overshot to minimize trail clipping.
	*/
# if 1
#  if defined(USE_SKINNING)
	vec3 mv_normal = normalize(_mtx_mul(_mat4_to_mat3(vSkinMatrix), %normal%));
#  else
	vec3 mv_normal = normalize(_mtx_mul(_mat4_to_mat3(vModelViewMatrix), %normal%));
#  endif
	vec4 vpos = _mtx_mul(vModelViewMatrix, %position%);
	vec4 previous_vpos = _mtx_mul(vPreviousModelViewMatrix, f_previous_position);

	vec4 dt_vpos = vpos - previous_vpos;
	vpos += dt_vpos * dot(mv_normal, normalize(dt_vpos.xyz)) * 1.1; // slightly overshot

	%out.position% = _mtx_mul(vProjectionMatrix, vpos);
# else
	%out.position% = _mtx_mul(vModelViewProjectionMatrix, %position%);
# endif

#elif defined(IS_PICKING_PASS)

	%out.position% = _mtx_mul(vModelViewProjectionMatrix, %position%);
	vPixelPickingId = vPickingId;

#endif
	// END RenderPass surface/shader glue code
		%}
	}

	pixel {
		global %{
#if defined(USE_HW_INSTANCING)
	#define vNormalMatrix vPixelInstanceNormalMatrix
	#define vNormalViewMatrix vPixelInstanceNormalViewMatrix
#endif // USE_HW_INSTANCING
		%}

		source %{
#if defined(USE_HW_INSTANCING)
	mat3 vPixelInstanceNormalMatrix = mat3(normalize(vInstanceNormalMatrix[0]), normalize(vInstanceNormalMatrix[1]), normalize(vInstanceNormalMatrix[2]));
	mat3 vPixelInstanceNormalViewMatrix = mat3(normalize(vInstanceNormalViewMatrix[0]), normalize(vInstanceNormalViewMatrix[1]), normalize(vInstanceNormalViewMatrix[2]));
#endif // USE_HW_INSTANCING

	vec3 %normal%;

#if defined(PIXEL_SHADER_REQUIRES_VPIXELNORMAL) && !defined(PIXEL_SHADER_WRITES_TO_NORMAL)
	%normal% = normalize(vPixelNormal); // normalization can be skipped for performance improvement
#endif

	vec3 %diffuse% = vec3(1.0, 1.0, 1.0);
	vec3 %specular% = vec3(0.0, 0.0, 0.0);
	float %glossiness% = 0.25;
	vec3 %constant% = vec3(0.0, 0.0, 0.0);
	float %opacity% = 1.0;

	// SHADER CODE
	%shader_code%

#if defined(ALPHA_TEST_THRESHOLD)
	if (%opacity% < ALPHA_TEST_THRESHOLD)
		discard;
#endif

	// START RenderPass surface/shader glue code
#if defined(IS_DEPTH_PASS)

	// ATI requires color to be written for depth only.
	%out.color% = vec4(%in.fragcoord%.zzz, 1.0);
	// nVidia requires depth to be written for depth only.
	%out.depth% = %in.fragcoord%.z;

#elif defined(IS_FORWARD_CONSTANT_PASS)

	vec3 _f_color = %diffuse% * vAmbientColor + %constant%;
	float k_fog = vFogState.z > 0.0 ? clamp((vDepth - vFogState.x) * vFogState.z, 0.0, 1.0) : 0.0;

	%out.color% = vec4(mix(_f_color, vFogColor, k_fog), %opacity%);

#elif defined(IS_FORWARD_LIGHT_CONTRIBUTION_PASS)

# if defined(SPOT_LIGHT_MODEL) || defined(POINT_LIGHT_MODEL)
	vec3 incident = vViewPos - vLightViewPosition;
	float incident_d = length(incident);
	incident /= incident_d;
# elif defined(LINEAR_LIGHT_MODEL)
	vec3 incident = vLightViewDirection;
	float incident_d = 0.0;
# endif

	LightModelOut _m = ComputeLightModel(vViewPos, %normal%, incident_d, incident, %glossiness% * 96.0);
	vec3 _f_color = %diffuse% * vLightDiffuseColor * _m.i_diff + %specular% * vLightSpecularColor * _m.i_spec;

# if defined(USE_PROJECTION_MAP)
	vec4 _pjm_uv = _mtx_mul(vLightShadowMatrix[0], vec4(vViewPos, 1.0));
	_f_color *= texture2D(vLightProjectionMap, _pjm_uv.xy / _pjm_uv.w).rgb;
# endif

# if defined(LIGHT_CAST_SHADOW)
	float pcf = 1.0;
#  if defined(SPOT_LIGHT_MODEL)
	pcf = ComputeShadowPCF(vViewPos, vLightShadowMatrix[0], vLightShadowMap);
#  elif defined(POINT_LIGHT_MODEL)
	pcf = ComputePointLightShadowPCF(vViewPos);
#  elif defined(LINEAR_LIGHT_MODEL)
	pcf = ComputeLinearLightShadowPCF(vViewPos);
#  endif
	_f_color = mix(vLightShadowColor, _f_color, pcf);
# endif

	float _t_opacity = %opacity%;
	_t_opacity *= vFogState.z > 0.0 ? clamp(1.0 - (vViewPos.z - vFogState.x) * vFogState.z, 0.0, 1.0) : 1.0;

	%out.color% = vec4(_f_color, _t_opacity);

#elif defined(IS_DEFERRED_ATTRIBUTE_PASS)

	%out.color0% = vec4(%normal%, vDepth);
	%out.color1% = vec4(%diffuse%, 1.0);
	%out.color2% = vec4(%specular%, %glossiness%);
	%out.color3% = vec4(%constant%, 0.0);

#elif defined(IS_POSTPROCESS_NORMALDEPTH_PASS)

	%out.color% = vec4(%normal%, vDepth);

#elif defined(IS_POSTPROCESS_VELOCITY_PASS)

	vec2 V = (vPrevProjPos.xy / vPrevProjPos.w) - (vProjPos.xy / vProjPos.w);
	%out.color% = vec4(V, 0.0, 1.0);

#elif defined(IS_PICKING_PASS)

	%out.color% = vPixelPickingId;

#endif
	// END RenderPass surface/shader glue code
		%}
	}
}
