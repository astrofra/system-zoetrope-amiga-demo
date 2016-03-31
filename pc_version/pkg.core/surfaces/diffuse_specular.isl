in {
	vec4 diffuse_color = vec4(0.7,0.7,0.7,1.0) [hint:color];
	vec4 specular_color = vec4(0.5,0.5,0.5,1.0) [hint:color];
	float glossiness = 0.5;
}

variant {
	pixel {
		source %{
			%diffuse% = diffuse_color.xyz;
			%specular% = specular_color.xyz;
			%glossiness% = glossiness;
		%}
	}
}
