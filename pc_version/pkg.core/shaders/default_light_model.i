// Default lighting model
// note: All calculations are done in view space.

#ifndef DEFAULT_LIGHT_MODEL_I
#define DEFAULT_LIGHT_MODEL_I

LightModelOut ComputePhongModel(vec3 p, vec3 n, vec3 incident, float gloss)
{
	LightModelOut m;
	m.i_diff = max(-dot(incident, n), 0.0);
	vec3 e = normalize(reflect(p, n));
	m.i_spec = pow(max(-dot(incident, e), 0.0), gloss);
	return m;
}

float ComputePointLightAttenuation(float d)
{
	float k = 1.0;
	if (vLightState.x > 0.0)
		k = max(1.0 - d / vLightState.x, 0.0); // distance attenuation
	return k;
}

float ComputeSpotLightAttenuation(float d, vec3 incident)
{
	float k = ComputePointLightAttenuation(d);
	float c = dot(vLightViewDirection, incident);

	if (c < vLightState.y) {
		if (c <= 0.0)
			k = 0.0;
		else
			k *= max((c - vLightState.z) / (vLightState.y - vLightState.z), 0.0); // cone/edge attenuation
	}
	return k;
}

float ComputeLinearLightAttenuation() { return 1.0; }

/*
	p: pixel position
	n: pixel normal
	d: distance from light to pixel
	incident: light incident direction
*/
LightModelOut ComputeLightModel(vec3 p, vec3 n, float d, vec3 incident, float gloss)
{
	LightModelOut m = ComputePhongModel(p, n, incident, gloss);

#if defined(SPOT_LIGHT_MODEL)
	float k = ComputeSpotLightAttenuation(d, incident);
#elif defined(POINT_LIGHT_MODEL)
	float k = ComputePointLightAttenuation(d);
#elif defined(LINEAR_LIGHT_MODEL)
	float k = ComputeLinearLightAttenuation();
#else
	float k = 1.0;
#endif

	m.i_diff *= k;
	m.i_spec *= k;
	return m;
}

#endif // DEFAULT_LIGHT_MODEL_I
