in {
	tex2D diffuse_map [wrap-u: clamp, wrap-v: clamp];
	tex2D crt_map [wrap-u: repeat, wrap-v: repeat];
	tex2D spherical_map;
}

variant {
	vertex {
		out {
			vec2 v_uv;
			vec3 p;
			vec3 n;			
		}

		source %{
			%out.position% = _mtx_mul(vModelViewProjectionMatrix, vec4(vPosition, 1.0));
			v_uv = vUV0;
            p = (vModelMatrix * vec4(vPosition, 1.0)).xyz;
            n = normalize(vNormalMatrix * vNormal);			
		%}
	}

	pixel {
		source %{
			/*
				Diffuse
			*/
			vec2 v_uv2 = ((v_uv - vec2(0.5, 0.0)) * vec2(0.875, 1.0)) + vec2(0.5, 0.0);
			vec2 q_uv = v_uv2 * vec2(384.0 * 2.0, 280.0 * 2.0);
			q_uv.x = floor(q_uv.x);
			q_uv.y = floor(q_uv.y);
			q_uv *= vec2(1.0 / (384.0 * 2.0), 1.0 / (280.0 * 2.0));

			q_uv = 0.75 * q_uv + 0.25 * v_uv2;

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

			/*
				Crt mask
			*/
			vec4 crt_color = texture2D(crt_map, v_uv2);


			/*
				Reflection
			*/
			vec3 e = p - vViewPosition.xyz;
			vec3 r = normalize(reflect(e, normalize(n)));
			vec2 uv_n;
			if(r.z > 0)
				uv_n = (r.xy / (2.0*(1.0 + r.z))) + 0.5;
			else
				uv_n = (r.xy / (2.0*(1.0 - r.z))) + 0.5;

			vec4 spherical_color = texture2D(spherical_map, uv_n);

			%diffuse% = diffuse_color + (blur_color * crt_color);
			%specular% = vec4(1.0, 1.0, 1.0, 1.0);
			%glossiness% = 1.25;
			%constant% = spherical_color;
		%}
	}
}

// in {
//     tex2D spherical_map;
// }

// variant {
// 	vertex {
// 		out {
// 			vec3 p;
// 			vec3 n;
// 		}

// 		source %{
// 			%out.position% = _mtx_mul(vModelViewProjectionMatrix, vec4(vPosition, 1.0));

//             p = (vModelMatrix * vec4(vPosition, 1.0)).xyz;
//             n = normalize(vNormalMatrix * vNormal);
// 		%}
// 	}

// 	pixel {
// 		source %{
// 			vec3 e = p - vViewPosition.xyz;
// 			vec3 r = normalize(reflect(e, normalize(n)));
// 			vec2 uv_n;
// 			if(r.z > 0)
// 				uv_n = (r.xy / (2.0*(1.0 + r.z))) + 0.5;
// 			else
// 				uv_n = (r.xy / (2.0*(1.0 - r.z))) + 0.5;

// 			vec4 spherical_color = texture2D(spherical_map, uv_n);
// 			%diffuse% = spherical_color;
// 		%}
// 	}
// }
