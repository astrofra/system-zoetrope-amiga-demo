variant {
	vertex {
		source %{
			%out.position% = _mtx_mul(vModelViewProjectionMatrix, vec4(vPosition, 1.0));
		%}
	}

	pixel {
		source %{
			%out.color% = vec4(1.0, 1.0, 1.0, 1.0);
		%}
	}
}
