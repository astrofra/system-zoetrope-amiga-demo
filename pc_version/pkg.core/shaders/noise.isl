in {
	tex2D u_tex;
	float u_strength;
	float u_mono;
	float u_bias;
	vec2 u_random;
}

variant {
	vertex {
		source %{
			%out.position% = _mtx_mul(vModelViewProjection, vec4(vPosition, 1.0));
		%}
	}

	pixel {
		source %{
			vec2 ref_uv = %in.fragcoord%.xy * vInverseInternalResolution.xy;
			vec4 ref = texture2D(u_tex, ref_uv);

			vec2 noise_uv = %in.fragcoord%.xy / 128.0;
			vec4 noise_a = texture2D(vNoiseMap, noise_uv + vec2(u_random.x * 3.456, u_random.x * 7.145)),
				noise_b = texture2D(vNoiseMap, noise_uv + vec2(u_random.y * 2.789, u_random.y * 9.781));

			vec4 noise = noise_a.r > 0.5 ? noise_b.barg : noise_a.rgba;
			noise = mix(noise, noise.rrrr, u_mono);

			//
			float strength = u_strength * 6.0;
			float luma = dot(ref.rgb, vec3(0.299, 0.587, 0.114));

			if (u_bias < 0.5)
				strength *= pow(clamp(1.0 + luma * (u_bias - 0.5) * 2.0, 0.0, 1.0), 5.0);
			if (u_bias > 0.5)
				strength *= pow(clamp(1.0 - (1.0 - luma) * (u_bias - 0.5) * 2.0, 0.0, 1.0), 5.0);

			%out.color% = vec4(ref.rgb * (1.0 + (noise.rgb - 0.5) * strength * 2.0), ref.a);
		%}
	}
}
