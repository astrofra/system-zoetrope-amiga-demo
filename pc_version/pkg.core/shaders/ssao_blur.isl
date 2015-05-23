in {
	float u_blur_radius;
	tex2D u_normal_depth;
}

variant {
	vertex {
		source %{
			%out.position% = vec4(vPosition, 1.0);
		%}
	}

	pixel {
		global %{
			float DecodeDepth(vec2 UV) { return texture2D(u_normal_depth, UV).w; }

			vec4 BlurSample(vec2 UV, float ref_depth, vec4 ref_source) { return texture2D(u_tex, UV); }
		%}

		source %{
			vec2 UV = %in.fragcoord%.xy * vInverseInternalResolution.xy * vFxScale;
			float ref_depth = DecodeDepth(UV);
			vec4 ref_source = texture2D(u_tex, UV);

			vec2 blur_factor = u_blur_radius * vInverseViewportSize.xy;

			vec4 txl = vec4(0.0, 0.0, 0.0, 0.0);
			for (float v = -0.5; v < 0.51; v += 0.25)
				for (float u = -0.5; u < 0.51; u += 0.25)
						txl += BlurSample(UV + vec2(u, v) * blur_factor, ref_depth, ref_source);

			%out.color% = txl / 25.0;
		%}
	}
}
