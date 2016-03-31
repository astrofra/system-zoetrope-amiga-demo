in {
	tex2D diffuse_map;
	tex2D height_map;
	tex2D normal_map;

	float min_layer = 10;
	float max_layer = 100;

	float parallax_scale = 0.1;
}

variant {

	vertex {
		out {
			vec2 v_uv;
			vec3 v_tangent;
			vec3 v_bitangent;
			vec3 v_normal;
			vec3 v_tangent_view_dir;
		}

		source %{
			v_uv = vUV0;

			v_tangent = vTangent;
			v_bitangent = vBitangent;
			v_normal = vNormal;

			mat3 tangent_matrix = _build_mat3(v_tangent, v_bitangent, v_normal);

			// compute the pixel to view direction in tangent space
			vec4 model_view_pos = _mtx_mul(vInverseModelMatrix, vViewPosition);
			vec3 view_dir = model_view_pos.xyz - vPosition;
			v_tangent_view_dir = _mtx_mul(transpose(tangent_matrix), view_dir);

			%position% = vec4(vPosition, 1.0);
		%}
	}

	pixel {

		global %{
			#include "@core/shaders/common.i"

			vec2 ParallaxOffsetUV(vec3 view_dir, vec2 uv, float scale)
			{
				view_dir = normalize(view_dir);

				float num_layers = mix(max_layer, min_layer, abs(view_dir.z));
				float height_step = 1.0 / num_layers;

				vec2 uv_step = view_dir.xy / view_dir.z * scale / num_layers;

				// while point is above surface
				float prv_height = 0, height = 0;
				float prv_tex_height = 0, tex_height = 0;

				while (true) {
					prv_tex_height = tex_height;

					tex_height = texture2D(height_map, uv).r;
					if (height >= tex_height)
						break;

					prv_height = height;
					height += height_step;
					uv -= uv_step;
				}

				// backtrack UV to the intersection point
				float dt0 = prv_tex_height - prv_height;
				float dt1 = height - tex_height;

				float k = dt0 / (dt0 + dt1);
				uv += uv_step * (1.0 - k);
				return uv;
			}
		%}

		source %{
			// compute parallax UV offset
			vec2 uv = ParallaxOffsetUV(v_tangent_view_dir, v_uv, parallax_scale);

			// sample, unpack and transform normal to tangent space
			mat3 tangent_matrix = _build_mat3(normalize(v_tangent), normalize(v_bitangent), normalize(v_normal));

			vec3 n = texture2D(normal_map, uv).xyz;
			n = UnpackVectorFromColor(n);
			n = normalize(tangent_matrix * n);
			n = vNormalViewMatrix * n;

			%normal% = n;
			%diffuse% = texture2D(diffuse_map, uv).xyz;
			%specular% = vec3(1.0, 1.0, 1.0);
		%}
	}
}