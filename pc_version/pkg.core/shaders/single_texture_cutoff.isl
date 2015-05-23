in {
	tex2D u_tex;
	float u_cutoff;
}

variant {
	vertex {
		out { vec2 v_uv; }

		source %{
			v_uv = vUV0;
			%out.position% = _mtx_mul(vModelViewProjectionMatrix, vec4(vPosition, 1.0));
		%}
	}

	pixel {
		in { vec2 v_uv; }

		source %{
			vec4 ref = texture2D(u_tex, v_uv);
			%out.color% = vec4(max(ref.rgb - u_cutoff, 0.0), ref.a);
		%}
	}
}
