in {
	tex2D u_tex = "@core/textures/error.png";
}

variant {
	pixel {
		source %{
			float k = texture2D(u_tex, %in.fragcoord%.xy * vInverseInternalResolution.xy / vInverseInternalResolution.zw * 6.0).a;
			%constant% = vec4(k * 0.25, 0, 0, 1.0);
		%}
	}
}
