in {
    texCube cube_map;
}

variant {
	vertex {
		out {
			vec3 p;
			vec3 n;
		}

		source %{
			%out.position% = _mtx_mul(vModelViewProjectionMatrix, vec4(vPosition, 1.0));

            p = (vModelMatrix * vec4(vPosition, 1.0)).xyz;
            n = normalize(vNormalMatrix * vNormal);
		%}
	}

	pixel {
		source %{
			vec3 e = p - vViewPosition.xyz;
			vec3 r = normalize(reflect(e, normalize(n)));

			vec4 cube_color = textureCube(cube_map, r);
			%diffuse% = cube_color.xyz;
		%}
	}
}
