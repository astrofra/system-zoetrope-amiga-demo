variant {
	vertex {
		out { vec3 forward; }

		source %{
			forward = vPosition.xyz;
			%out.position% = vec4(vPosition, 1.0);
		%}
	}

	pixel {
		in { vec3 forward; }

		global %{
			#include "@core/shaders/common.i"
		%}

		source %{
			vec2 UV = %in.fragcoord%.xy * vInverseInternalResolution.xy;
			vec4 norm_dpth = UnpackNormalDepth(UV);

			if (norm_dpth.z == 0.0) {
				%out.color% = vec4(0.0, 0.0, 0.0, 1.0);
			} else {
				vec3 frag_viewpos = (forward / forward.z) * norm_dpth.w;

				// normal in view-model space
				vec3 normal = norm_dpth.xyz;

				// light diffuse contribution
				float idiff = max(-dot(vLightViewDirection, normal), 0.0);

				// light specular contribution
				vec4 spec_glos = texture2D(vGBuffer2, UV);
				vec3 e = reflect(normalize(frag_viewpos), normal);
				float ispec = pow(max(-dot(vLightViewDirection, normalize(e)), 0.0), spec_glos.w * 96.0);

				// final contribution
				vec4 diff_alpha = texture2D(vGBuffer1, UV);
				%out.color% = vec4(diff_alpha.rgb * vLightDiffuseColor * idiff + spec_glos.rgb * vLightSpecularColor * ispec, 1.0);
			}
		%}
	}
}
