in {
	float u_time = 0.5;
	texCube u_layer0;
	texCube u_layer1;
}

variant {
	vertex {
		out { vec2 v_uv; }

		source %{
			v_uv = (vPosition.xy * vec2(0.4, 0.4)) / vInverseViewportSize.zw;
			%out.position% = vec4(vPosition, 1.0);
		%}
	}

	pixel {
		in { vec2 v_uv; }

		source %{
			vec3 v = vec3(v_uv, 1.0);
			v = _mtx_mul(vNormalMatrix, normalize(v));

			%out.color% = mix(textureCube(u_layer0, v), textureCube(u_layer1, v), u_time);
		%}
	}
}
