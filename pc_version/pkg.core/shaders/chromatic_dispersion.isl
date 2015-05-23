in {
	float u_width;
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
			vec2 offset = vec2(u_width, 0.0);

			vec2 ref_uv_r = (%in.fragcoord%.xy - offset) * vInverseInternalResolution.xy;
			vec4 ref_r = texture2D(u_tex, ref_uv_r);

			vec2 ref_uv_g = %in.fragcoord%.xy * vInverseInternalResolution.xy;
			vec4 ref_g = texture2D(u_tex, ref_uv_g);

			vec2 ref_uv_b = (%in.fragcoord%.xy + offset) * vInverseInternalResolution.xy;
			vec4 ref_b = texture2D(u_tex, ref_uv_b);

			%out.color% = vec4(ref_r.r, ref_g.g, ref_b.b, (ref_r.a + ref_g.a + ref_b.a) / 3.0);
		%}
	}
}
