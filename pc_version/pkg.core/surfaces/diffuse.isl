in {
	vec4 diffuse_color = vec4(0.7,0.7,0.7,1.0) [hint:color];
}

variant {
	pixel {
		source %{
			%diffuse% = diffuse_color.xyz;
		%}
	}
}
