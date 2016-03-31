in {
	mat3 view_rotation;

	float rayleigh_strength = 0.3;
	float rayleigh_brightness = 2.5;
	float rayleigh_collection_power = 0.20;

	float mie_strength = 0.01;
	float mie_brightness = 0.1;
	float mie_collection_power = 0.6;
	float mie_distribution = 0.13;

	float spot_brightness = 30.0;
	float scatter_strength = 0.05;

	float step_count = 6.0;
	float intensity = 1.0;
	float surface_height = 0.994;

	float longitude = 0.3;
	float latitude = 0.0;
}

variant {

	vertex {
		out { vec2 v_uv; }
		source %{
			float factor = 1.0 / 3.2; // assume default fov
			v_uv = (vPosition.xy * vec2(factor, factor)) * vInverseViewportSize.zw;
			%out.position% = vec4(vPosition, 1.0);
		%}
	}

	pixel {
		global %{
			float phase(float alpha, float g)
			{
				float g2 = g * g;
				float a = 3.0 * (1.0 - g2);
				float b = 2.0 * (2.0 + g2);
				float c = 1.0 + alpha * alpha;
				float d = pow(1.0 + g2 - 2.0 * g * alpha, 1.5);
				return (a / b) * (c / d);
			}

			float atmospheric_depth(vec3 position, vec3 dir)
			{
				float a = dot(dir, dir);
				float b = 2.0 * dot(dir, position);
				float c = dot(position, position) - 1.0;
				float det = b * b - 4.0 * a * c;
				float detSqrt = sqrt(det);
				float q = (-b - detSqrt) / 2.0;
				float t1 = c / q;
				return t1;
			}

			float horizon_extinction(vec3 position, vec3 dir, float radius)
			{
				float u = dot(dir, -position);
				if	(u < 0.0)
					return 1.0;

				vec3 near = position + u * dir;
				if	(length(near) < radius)
					return 0.0;

				vec3 v2 = normalize(near) * radius - position;
				float diff = acos(dot(normalize(v2), dir));
				return smoothstep(0.0, 1.0, pow(diff * 2.0, 3.0));
			}

			#define Kr vec3(0.18867780436772762, 0.4978442963618773, 0.6616065586417131)

			vec3 absorb(float dist, vec3 color, float factor)
			{
				float k = factor / dist;
				return color - color * pow(Kr, vec3(k, k, k));
			}
        %}

		source %{
			vec3 v = vec3(v_uv, 1.0);
			v = _mtx_mul(view_rotation, normalize(v));

			vec3 lightdir = vec3(sin(latitude) * sin(longitude), cos(latitude), sin(latitude) * cos(longitude));
			lightdir = normalize(lightdir);

			vec3 eyedir = v;
			float alpha = dot(eyedir, lightdir);

			//
			float rayleigh_factor = phase(alpha, -0.01) * rayleigh_brightness;
			float mie_factor = phase(alpha, mie_distribution) * mie_brightness;
			float spot = smoothstep(0.0, 15.0, phase(alpha, 0.9995)) * spot_brightness;

			//
			vec3 eye_position = vec3(0.0, surface_height, 0.0);
			float eye_depth = atmospheric_depth(eye_position, eyedir);
			float step_length = eye_depth / step_count;
			float eye_extinction = horizon_extinction(eye_position, eyedir, surface_height - 0.15);

			//
			vec3 rayleigh_collected = vec3(0.0, 0.0, 0.0);
			vec3 mie_collected = vec3(0.0, 0.0, 0.0);

			for	(float i = 0; i < step_count; i++)
			{
				float sample_distance = step_length * i;
				vec3 position = eye_position + eyedir * sample_distance;
				float extinction = horizon_extinction(position, lightdir, surface_height - 0.35);
				float sample_depth = atmospheric_depth(position, lightdir);

				vec3 influx = absorb(sample_depth, vec3(intensity), scatter_strength) * extinction;
				rayleigh_collected += absorb(sample_distance, Kr * influx, rayleigh_strength);
				mie_collected += absorb(sample_distance, influx, mie_strength);
			}

			//
			rayleigh_collected = (rayleigh_collected * eye_extinction * pow(eye_depth, rayleigh_collection_power)) / step_count;
			mie_collected = (mie_collected * eye_extinction * pow(eye_depth, mie_collection_power)) / float(step_count);

			vec3 color = vec3(spot * mie_collected + mie_factor * mie_collected + rayleigh_factor * rayleigh_collected);

			%out.color% = vec4(color, 1.0);
		%}
	}
}