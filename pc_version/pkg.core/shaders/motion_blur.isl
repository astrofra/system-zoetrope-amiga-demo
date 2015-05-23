in {
	tex2D u_source;
	tex2D u_velocity;
	float u_strength;
	float u_pow;
	float max;
}

variant {
	vertex {
		out { vec2 v_uv; }

		source %{
			v_uv = vUV0;
			%out.position% = _mtx_mul(vModelViewProjection, vec4(vPosition, 1.0));
		%}
	}

	pixel {
		in { vec2 v_uv; }

		global %{
			// sample velocity weighting to reduce background velocity induced leakage
			#define	SAMPLE_WEIGHTING

			float AdjustVelocity(float v) { return clamp(pow(v, u_pow) * u_strength, -u_max, u_max); }

		#ifdef SAMPLE_WEIGHTING
			float ComputeSampleWeight(vec2 uv)
			{
				vec2 V = texture2D(u_velocity, uv).xy;
				return AdjustVelocity(length(V));
			}

			vec4 MotionSample(vec2 uv, float weight) { return texture2D(u_source, uv) * weight; }
		#else
			vec4 MotionSample(vec2 uv) { return texture2D(u_source, uv); }
		#endif
		%}

		source %{
			vec4 ref = texture2D(u_source, v_uv);
			vec2 V = texture2D(u_velocity, v_uv).xy;

			float l = length(V);
			float n_l = AdjustVelocity(l);

			V = V * (l > 0.0001 ? n_l / l : 0.0);

		#ifdef SAMPLE_WEIGHTING
			float t_weight = n_l, w;
			vec4 result = ref * n_l;
			#define DO_MOTION_SAMPLE(_UV) {\
				w = ComputeSampleWeight(_UV);\
				t_weight += w;\
				result += MotionSample(_UV, w);\
			}
		#else
			vec4 result = ref;
			#define DO_MOTION_SAMPLE(_UV) result += MotionSample(_UV);
		#endif

			DO_MOTION_SAMPLE(v_uv - V)
			DO_MOTION_SAMPLE(v_uv - V * 0.75)
			DO_MOTION_SAMPLE(v_uv - V * 0.5)
			DO_MOTION_SAMPLE(v_uv - V * 0.25)
			DO_MOTION_SAMPLE(v_uv + V * 0.25)
			DO_MOTION_SAMPLE(v_uv + V * 0.5)
			DO_MOTION_SAMPLE(v_uv + V * 0.75)
			DO_MOTION_SAMPLE(v_uv + V)

			float a = clamp(n_l / vInverseViewportSize.x, 0.001, 1.0);
		#ifdef SAMPLE_WEIGHTING
			%out.color% = vec4(t_weight > 0.0 ? result.rgb / t_weight : ref.rgb, a);
		#else
			%out.color% = vec4(result.rgb / 9.0, a);
		#endif
		%}
	}
}
