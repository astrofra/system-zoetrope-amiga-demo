variant {
	vertex {
		out { vec3 forward; }

		source %{
			forward = _mtx_mul(vModelViewMatrix, vec4(vPosition, 1.0)).xyz;
			%out.position% = _mtx_mul(vModelViewProjectionMatrix, vec4(vPosition, 1.0));
		%}
	}

	pixel {
		in { vec3 forward; }

		global %{
			#include "@core/shaders/common.i"
			#include "@core/shaders/shadow_common.i"
		%}

		source %{
			vec2 UV = %in.fragcoord%.xy * vInverseInternalResolution.xy;
			vec4 norm_dpth = UnpackNormalDepth(UV);

			if (norm_dpth.z == 0.0) {
				%out.color% = vec4(0.0, 0.0, 0.0, 1.0);
			} else {
				vec3 pixel_view_pos = (forward / forward.z) * norm_dpth.w;

				float pcf = ComputePointLightShadowPCF(pixel_view_pos);

				if (pcf > 0.0) {
					// normal in view-model space
					vec3 normal = norm_dpth.xyz;
				
					// light diffuse contribution
					vec3 dt = pixel_view_pos - vLightViewPosition;
					float dl = length(dt);
					dt = dt / dl;
					float atten = vLightState.x > 0.0 ? max(1.0 - dl / vLightState.x, 0.0) : 1.0;
					float idiff = max(-dot(dt, normal) * atten, 0.0);
				
					// light specular contribution
					vec4 spec_glos = texture2D(vGBuffer2, UV);
					vec3 e = reflect(normalize(pixel_view_pos), normal);
					float ispec = pow(max(-dot(dt, normalize(e)), 0.0), spec_glos.w * 96.0) * atten;

					// final contribution
					vec4 diff_alpha = texture2D(vGBuffer1, UV);
					%out.color% = vec4(mix(vLightShadowColor, diff_alpha.rgb * vLightDiffuseColor * idiff + spec_glos.rgb * vLightSpecularColor * ispec, pcf), 1.0);
				} else {
					%out.color% = vec4(vLightShadowColor, 1.0);
				}
			}
		%}
	}
}
