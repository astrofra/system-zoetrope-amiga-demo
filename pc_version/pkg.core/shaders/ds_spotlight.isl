variant {
	vertex {
		out { vec3 forward; }

		source %{
			forward = _mtx_mul(vModelViewMatrix, vec4(vPosition, 1.0)).xyz;
			%out.position% = _mtx_mul(vModelViewProjectionMatrix, vec4(vPosition, 1.0));
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
			if (norm_dpth.z == 0.0)
				discard;

			vec3 frag_viewpos = (forward / forward.z) * norm_dpth.w;

			// normal in view-model space
			vec3 normal = norm_dpth.xyz;

			// light diffuse contribution
			vec3 dt = frag_viewpos - vLightViewPosition;
			float dl = length(dt);
			dt = dt / dl;
			float atten = vLightState.x > 0.0 ? max(1.0 - dl / vLightState.x, 0.0) : 1.0;
			float idiff = max(-dot(dt, normal) * atten, 0.0);

			float sdiff = dot(vLightViewDirection, dt);
			if (sdiff < vLightState.y) {
				if (sdiff < 0.0)
					sdiff = 0.0;
				else
					sdiff = max((sdiff - vLightState.z) / (vLightState.y - vLightState.z), 0.0);
			} else {
				sdiff = 1.0;
			}

			// light specular contribution
			vec4 spec_glos = texture2D(vGBuffer2, UV);
			vec3 e = reflect(normalize(frag_viewpos), normal);
			float ispec = pow(max(-dot(dt, normalize(e)), 0.0), spec_glos.w * 96.0) * atten * sdiff;

			// final contribution
			vec4 diff_alpha = texture2D(vGBuffer1, UV);
			%out.color% = vec4(diff_alpha.rgb * vLightDiffuseColor * idiff * sdiff + spec_glos.rgb * vLightSpecularColor * ispec, 1.0);
		%}
	}
}
