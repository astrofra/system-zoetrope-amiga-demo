in {
	tex2D u_tex;
	float u_strength;
	float u_radius;
	float u_distance_scale;
	vec2 u_iproj2d;
}

variant {
	vertex {
		source %{
			%out.position% = vec4(vPosition, 1.0);
		%}
	}

	pixel {
		global %{
			#define k_buffer (vInverseInternalResolution.xy * vFxScale)

			vec3 ComputeDepthBufferViewPos(vec2 uv, float z)
			{
				vec3 svc = vec3((((uv * vDisplayBufferRatio) - vec2(0.5, 0.5)) * 2.0) * u_iproj2d, 1.0);
				return svc * (z + vViewState.x);
			}

			vec4 GetNormalDepth(vec2 uv) { return texture2D(u_tex, uv); }

			vec2 GetRandom(vec2 uv) { return normalize(texture2D(vNoiseMap, uv / 128.0 * (vec2(1.0, 1.0) / vInverseInternalResolution.xy)).xy * 2.0 - 1.0); }

			float EvaluateAmbientOcclusion(vec2 tcoord, vec2 uv, vec3 p, vec3 cnorm)
			{
				uv *= k_buffer;

				float z = GetNormalDepth(tcoord + uv).w;
				vec3 diff = ComputeDepthBufferViewPos(tcoord + uv, z) - p;

				vec3 v = normalize(diff);
				float d = length(diff) * u_distance_scale;

				const float g_bias = 0.3;
				return max(0.0, dot(cnorm, v) - g_bias) * (1.0 / (1.0 + d)) * u_strength;
			}
		%}

		source %{
			vec2 vec[4];
			vec[0] = vec2(1.0, 0.0);
			vec[1] = vec2(-1.0, 0.0);
			vec[2] = vec2(0.0, 1.0);
			vec[3] = vec2(0.0, -1.0);

			vec2 uv = %in.fragcoord%.xy * k_buffer;

			vec4 normal_depth = GetNormalDepth(uv);
			vec3 p = ComputeDepthBufferViewPos(uv, normal_depth.w);
			vec3 n = normal_depth.xyz;
			vec2 rand = GetRandom(uv);

			float ao = 0.0;
			float rad = u_radius / p.z;

			// SSAO Calculation
			int iterations = 4;
			for (int j = 0; j < iterations; ++j) {
				vec2 coord1 = reflect(vec[j], rand) * rad;
				vec2 coord2 = vec2(coord1.x * 0.707 - coord1.y * 0.707, coord1.x * 0.707 + coord1.y * 0.707);

				ao += EvaluateAmbientOcclusion(uv, coord1 * 0.25, p, n);
				ao += EvaluateAmbientOcclusion(uv, coord2 * 0.5, p, n);
				ao += EvaluateAmbientOcclusion(uv, coord1 * 0.75, p, n);
				ao += EvaluateAmbientOcclusion(uv, coord2, p, n);
			}

			ao /= 4.0 * float(iterations);
			%out.color% = vec4(0.0, 0.0, 0.0, ao);
		%}
	}
}
