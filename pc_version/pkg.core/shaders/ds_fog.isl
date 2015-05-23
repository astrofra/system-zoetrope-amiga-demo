variant {
	vertex {
		source %{
			%out.position% = vec4(vPosition, 1.0);
		%}
	}

	pixel {
		global %{
			#include "@core/shaders/common.i"
		%}

		source %{
			vec2 UV = %in.fragcoord%.xy * vInverseInternalResolution.xy;
			vec4 norm_dpth = UnpackNormalDepth(UV);
			%out.color% = vec4(vFogColor.rgb, clamp((norm_dpth.w - vFogState.x) * vFogState.z, 0.0, 1.0));
		%}
	}
}
