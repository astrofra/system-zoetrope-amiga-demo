surface { skinned: 1 }

in {
	tex2D diffuse_map;
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
			vec4 diffuse_color = texture2D(diffuse_map, v_uv);

			%diffuse% = diffuse_color.xyz;
		%}
	}
}
