in {
	tex2D diffuse_map [wrap-u: clamp, wrap-v: clamp];
	tex2D crt_map [wrap-u: repeat, wrap-v: repeat];
}

variant {
	vertex {
		out {
			vec2 v_uv;
		}

		source %{
			v_uv = vUV0;
		%}
	}

	pixel {
		source %{
			vec2 q_uv = v_uv * vec2(384.0 * 2.0, 280.0 * 2.0);
			q_uv.x = floor(q_uv.x);
			q_uv.y = floor(q_uv.y);
			q_uv *= vec2(1.0 / (384.0 * 2.0), 1.0 / (280.0 * 2.0));

			q_uv = 0.75 * q_uv + 0.25 * v_uv;

			vec4 diffuse_color = texture2D(diffuse_map, q_uv);
			vec4 blur_color =  vec4(0,0,0,1);

			blur_color += texture2D(diffuse_map, q_uv + vec2(0.0025, 0.0025));
			blur_color += texture2D(diffuse_map, q_uv + vec2(-0.0025, 0.0025));
			blur_color += texture2D(diffuse_map, q_uv + vec2(-0.0025, -0.0025));
			blur_color += texture2D(diffuse_map, q_uv + vec2(0.0025, -0.0025));

			blur_color += texture2D(diffuse_map, q_uv + vec2(0.005, 0.005));
			blur_color += texture2D(diffuse_map, q_uv + vec2(-0.005, 0.005));
			blur_color += texture2D(diffuse_map, q_uv + vec2(-0.005, -0.005));
			blur_color += texture2D(diffuse_map, q_uv + vec2(0.005, -0.005));

			blur_color += texture2D(diffuse_map, q_uv + vec2(0.01, 0.01));
			blur_color += texture2D(diffuse_map, q_uv + vec2(-0.01, 0.01));
			blur_color += texture2D(diffuse_map, q_uv + vec2(-0.01, -0.01));
			blur_color += texture2D(diffuse_map, q_uv + vec2(0.01, -0.01));

			blur_color += texture2D(diffuse_map, q_uv + vec2(0.015, 0.015));
			blur_color += texture2D(diffuse_map, q_uv + vec2(-0.015, 0.015));
			blur_color += texture2D(diffuse_map, q_uv + vec2(-0.015, -0.015));
			blur_color += texture2D(diffuse_map, q_uv + vec2(0.015, -0.015));

			blur_color *= (1.0 / 16.0);

			vec4 crt_color = texture2D(crt_map, v_uv);

			%diffuse% = diffuse_color + (blur_color * crt_color);
			%specular% = vec4(1.0, 1.0, 1.0, 1.0);
			%glossiness% = 1.25;
			// %constant% = vec4(1.0, 0.0, 0.5, 1.0);
		%}
	}
}
