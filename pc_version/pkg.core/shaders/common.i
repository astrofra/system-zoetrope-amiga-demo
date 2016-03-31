// common utility functions

#ifndef COMMON_I
#define COMMON_I

// depth buffer access helpers
vec4 UnpackNormalDepth(vec2 UV)
{
	vec4 pck = texture2D(vGBuffer0, UV);
	vec2 nxy = pck.xy * 2.0 - 1.0;

	float z = dot(pck.wz, vec2(1.0, 256.0)) * 1024.0 / 256.0;
	return vec4(nxy.x, nxy.y, -sqrt(1.0 - (nxy.x * nxy.x + nxy.y * nxy.y)), z);
}

// vector<->color conversions
vec3 PackVectorToColor(vec3 vector) { return vector * 0.5 + 0.5; }
vec3 UnpackVectorFromColor(vec3 color) { return color * 2.0 - 1.0; }

// skinning related functions
#ifdef IS_VERTEX_SHADER

mat4 BuildSkinMatrix()
{
	return vBoneMatrix[int(vBoneIndex.x)] * vBoneWeight.x + vBoneMatrix[int(vBoneIndex.y)] * vBoneWeight.y + vBoneMatrix[int(vBoneIndex.z)] * vBoneWeight.z + vBoneMatrix[int(vBoneIndex.w)] * vBoneWeight.w;
}

mat4 BuildPreviousSkinMatrix()
{
	return vPreviousBoneMatrix[int(vBoneIndex.x)] * vBoneWeight.x + vPreviousBoneMatrix[int(vBoneIndex.y)] * vBoneWeight.y + vPreviousBoneMatrix[int(vBoneIndex.z)] * vBoneWeight.z + vPreviousBoneMatrix[int(vBoneIndex.w)] * vBoneWeight.w;
}

#endif // IS_VERTEX_SHADER

// light model output structure
struct LightModelOut
{
	float i_diff;
	float i_spec;
};

// get depth buffer value
float SampleDepthBuffer(tex2D depth_buffer, vec2 uv)
{
	vec4 rgba = texture2D(depth_buffer, uv);
	if (vTechniqueIsForward == 1)
		return dot(rgba, vec4(1.0, 1/255.0, 1/65025.0, 1/160581375.0));
	return 1.0;
}

// Eye enumeration
const float EyeMono = 0;
const float EyeStereoLeft = 1;
const float EyeStereoRight = 2;

#endif // COMMON_I
