in { tex2D u_tex; }

variant {
	vertex {
		source %{
			%out.position% = vec4(vPosition, 1.0);
		%}
	}

	pixel {
		global %{
			float lumaRGB(vec3 v) { return dot(v, vec3(0.212, 0.716, 0.072)); }
		%}

		source %{
			vec2 UV = %in.fragcoord%.xy * vInverseInternalResolution.xy;

			float w = 1.75;
			float
				t = lumaRGB(texture2D(u_tex, UV + vec2(0.0, -1.0) * w * vInverseInternalResolution.xy).xyz),
				l = lumaRGB(texture2D(u_tex, UV + vec2(-1.0, 0.0) * w * vInverseInternalResolution.xy).xyz),
				r = lumaRGB(texture2D(u_tex, UV + vec2(1.0, 0.0) * w * vInverseInternalResolution.xy).xyz),
				b = lumaRGB(texture2D(u_tex, UV + vec2(0.0, 1.0) * w * vInverseInternalResolution.xy).xyz);

			vec2 n = vec2(-(t - b), r - l);
			float nl = length(n);
				
			if (nl < (1.0 / 6.0)) {
				%out.color% = texture2D(u_tex, UV);
			}
			else {
				n *= vInverseInternalResolution.xy / nl;

				vec4 o = texture2D(u_tex, UV),
					t0 = texture2D(u_tex, UV + n * 0.5) * 0.9,
					t1 = texture2D(u_tex, UV - n * 0.5) * 0.9,
					t2 = texture2D(u_tex, UV + n) * 0.75,
					t3 = texture2D(u_tex, UV - n) * 0.75;

				%out.color% = (o + t0 + t1 + t2 + t3) / 4.3;
			}
		%}
	}
}
