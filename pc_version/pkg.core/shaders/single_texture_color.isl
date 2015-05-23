in { tex2D u_tex; }

variant {
	vertex {
		out {
			vec4 v_color;
			vec2 v_uv;
		}

		source %{
			v_color = vColor0;
			v_uv = vUV0;
			%out.position% = _mtx_mul(vModelViewProjectionMatrix, vec4(vPosition, 1.0));
		%}
	}

	pixel {
		in {
			vec4 v_color;
			vec2 v_uv;
		}

		source %{
			%out.color% = texture2D(u_tex, v_uv) * v_color;
		%}
	}
}
