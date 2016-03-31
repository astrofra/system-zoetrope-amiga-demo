in {
	tex2D diffuse_map;
	tex2D normal_map;
}

variant {
	vertex {
		out {
			vec2 v_uv;
			vec3 v_normal;
			vec3 v_tangent;
			vec3 v_bitangent;
		}

		source %{
			v_uv = vUV0;
			v_normal = vNormal;
			v_tangent = vTangent;
			v_bitangent = vBitangent;
		%}
	}

	pixel {
		source %{
			vec3 n = texture2D(normal_map, v_uv).xyz;

			mat3 tangent_matrix = _build_mat3(normalize(v_bitangent), normalize(v_tangent), normalize(v_normal));
			n = n * 2.0 - 1.0;
			n = tangent_matrix * n;
			n = vNormalViewMatrix * n;

			%diffuse% = texture2D(diffuse_map, v_uv).xyz;
			%normal% = n;
		%}
	}
}