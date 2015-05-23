variant {
	vertex {
		source %{
			%out.position% = vec4(vPosition, 1.0);
		%}
	}

	pixel {
		source %{
			vec2 UV = %in.fragcoord%.xy * vInverseInternalResolution.xy;
			vec4 diff_alpha = texture2D(vGBuffer1, UV);
			vec4 const_unkn = texture2D(vGBuffer3, UV);
			%out.color% = vec4(diff_alpha.rgb * vAmbientColor + const_unkn.xyz, 1.0);
		%}
	}
}
