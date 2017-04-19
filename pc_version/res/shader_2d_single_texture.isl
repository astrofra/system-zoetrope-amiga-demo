in { tex2D u_tex [wrap-u: clamp, wrap-v: clamp, filter: nearest]; }

variant {
	vertex {
		out { vec2 v_uv; }

		source %{
			v_uv = vUV0;
			%out.position% = vec4(vPosition, 1.0);
		%}
	}

	pixel {
		in { vec2 v_uv; }

		source %{
			%out.color% = texture2D(u_tex, v_uv);
		%}
	}
}
