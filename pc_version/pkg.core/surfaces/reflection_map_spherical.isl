in {
    tex2D spherical_map;
}

variant {
	vertex {
		out {
			vec3 p;
			vec3 n;
		}

		source %{
			%out.position% = _mtx_mul(vModelViewProjectionMatrix, vec4(vPosition, 1.0));

            p = (vModelMatrix * vec4(vPosition, 1.0)).xyz;
            n = normalize(vNormalMatrix * vNormal);
		%}
	}

	pixel {
		source %{
			vec3 e = p - vViewPosition.xyz;
			vec3 r = normalize(reflect(e, normalize(n)));
			vec2 uv_n;
			if(r.z > 0)
				uv_n = (r.xy / (2.0*(1.0 + r.z))) + 0.5;
			else
				uv_n = (r.xy / (2.0*(1.0 - r.z))) + 0.5;

			vec4 spherical_color = texture2D(spherical_map, uv_n);
			%diffuse% = spherical_color.xyz;
		%}
	}
}