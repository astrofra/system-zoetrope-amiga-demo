in {
	float u_strength;
	tex2D u_tex;
}

variant {
	vertex {
		source %{
			%out.position% = vec4(vPosition, 1.0);
		%}
	}

	pixel {
		source %{
			vec2 UV = %in.fragcoord%.xy * vInverseInternalResolution.xy;
			vec4 ref = texture2D(u_tex, UV);

			%out.color% = mix
			(
				ref,
				texture2D(u_tex, UV + vec2(-1.0, -1.0) * vInverseInternalResolution.xy) * -0.125 +
				texture2D(u_tex, UV + vec2( 0.0, -1.0) * vInverseInternalResolution.xy) * -0.125 +
				texture2D(u_tex, UV + vec2( 1.0, -1.0) * vInverseInternalResolution.xy) * -0.125 +
				texture2D(u_tex, UV + vec2(-1.0,  0.0) * vInverseInternalResolution.xy) * -0.125 +
				ref * 2.0 +
				texture2D(u_tex, UV + vec2( 1.0,  0.0) * vInverseInternalResolution.xy) * -0.125 +
				texture2D(u_tex, UV + vec2(-1.0,  1.0) * vInverseInternalResolution.xy) * -0.125 +
				texture2D(u_tex, UV + vec2( 0.0,  1.0) * vInverseInternalResolution.xy) * -0.125 +
				texture2D(u_tex, UV + vec2( 1.0,  1.0) * vInverseInternalResolution.xy) * -0.125,
				u_strength
			);
		%}
	}
}
