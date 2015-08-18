variant {
	vertex {
		out { vec2 forward; }

		source %{
			%out.position% = vec4(vPosition, 1.0);
			forward = vPosition.xy;
		%}
	}

	pixel {
		in { vec2 forward; }

		global %{
			#include "@core/shaders/common.i"
			#include "@core/shaders/shadow_common.i"
		%}

		source %{
			vec2 UV = %in.fragcoord%.xy * vInverseInternalResolution.xy;

			vec4 norm_dpth = UnpackNormalDepth(UV);
			if (norm_dpth.z == 0.0) {
				%out.color% = vec4(0.0, 0.0, 0.0, 1.0);
			} else {
				vec3 cforward = vec3(forward / (vViewState.z * vInverseViewportSize.zw), 1.0);
				vec3 pixel_view_pos = cforward * (norm_dpth.w - vLightState.w);

				// evaluate PCF on the shadow map corresponding to this fragment slice
				float pcf = ComputeLinearLightShadowPCF(pixel_view_pos);

				if (pcf > 0.0) {
					pixel_view_pos = cforward * norm_dpth.w;

					// normal in view-model space
					vec3 normal = norm_dpth.xyz;

					// light diffuse contribution
					float idiff = max(-dot(vLightViewDirection, normal), 0.0);

					// light specular contribution
					vec4 spec_glos = texture2D(vGBuffer2, UV);
					vec3 e = reflect(normalize(pixel_view_pos), normal);
					float ispec = pow(max(-dot(vLightViewDirection, normalize(e)), 0.0), spec_glos.w * 96.0);

					// final contribution
					vec4 diff_alpha = texture2D(vGBuffer1, UV);
					%out.color% = vec4(mix(vLightShadowColor, diff_alpha.rgb * vLightDiffuseColor * idiff + spec_glos.rgb * vLightSpecularColor * ispec, pcf), 1.0);
				} else {
					%out.color% = vec4(vLightShadowColor, 1.0);
				}
			}
		%}
	}
}
