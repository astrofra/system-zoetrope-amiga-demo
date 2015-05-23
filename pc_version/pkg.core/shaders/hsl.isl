in {
	tex2D u_tex;
	float u_H;
	float u_S;
	float u_L;
}

variant {
	vertex {
		source %{
			%out.position% = vec4(vPosition, 1.0);
		%}
	}

	pixel {
		global %{
			vec3 RGBToHSL(vec3 color)
			{
				float fmin = min(min(color.r, color.g), color.b); // min. value of RGB
				float fmax = max(max(color.r, color.g), color.b); // max. value of RGB
				float delta = fmax - fmin; // delta RGB value

				vec3 hsl = vec3(0.0, 0.0, (fmax + fmin) * 0.5);

				if (delta != 0.0) {
					hsl.y = hsl.z < 0.5 ? delta / (fmax + fmin) : delta / (2.0 - fmax - fmin);

					float hdelta = delta * 0.5;
					vec3 deltaRGB = (((vec3(fmax, fmax, fmax) - color) / 6.0) + vec3(hdelta, hdelta, hdelta)) / delta;

					if (color.r == fmax )
						hsl.x = clamp(deltaRGB.b - deltaRGB.g, 0.0, 1.0);
					else if (color.g == fmax)
						hsl.x = clamp((1.0 / 3.0) + deltaRGB.r - deltaRGB.b, 0.0, 1.0);
					else if (color.b == fmax)
						hsl.x = clamp((2.0 / 3.0) + deltaRGB.g - deltaRGB.r, 0.0, 1.0);
				}
				return hsl;
			}

			float HueToRGB(float f1, float f2, float hue)
			{
				if (hue < 0.0)
					hue += 1.0;
				else if (hue > 1.0)
					hue -= 1.0;

				if ((6.0 * hue) < 1.0)
					return f1 + (f2 - f1) * 6.0 * hue;
				else if ((2.0 * hue) < 1.0)
					return f2;
				else if ((3.0 * hue) < 2.0)
					return f1 + (f2 - f1) * ((2.0 / 3.0) - hue) * 6.0;

				return f1;
			}

			vec3 HSLToRGB(vec3 hsl)
			{
				if (hsl.y == 0.0)
					return hsl.zzz;

				float f2 = hsl.z < 0.5 ? hsl.z * (1.0 + hsl.y) : (hsl.z + hsl.y) - hsl.y * hsl.z;
				float f1 = 2.0 * hsl.z - f2;
				return vec3(HueToRGB(f1, f2, hsl.x + (1.0 / 3.0)), HueToRGB(f1, f2, hsl.x), HueToRGB(f1, f2, hsl.x - (1.0 / 3.0)));
			}
		%}

		source %{
			vec2 UV = %in.fragcoord%.xy * vInverseInternalResolution.xy;
			vec4 ref = texture2D(u_tex, UV);
			vec3 hsl = RGBToHSL(ref.rgb);

			hsl.x += u_H;
			if (hsl.x > 1.0)
				hsl.x -= 1.0;
			hsl.y *= u_S;
			hsl.z *= u_L;

			%out.color% = vec4(HSLToRGB(hsl), ref.a);
		%}
	}
}
