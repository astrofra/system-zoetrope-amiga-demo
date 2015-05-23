<Shader>
	<Inputs>
		<Input Name="a_position" Type="Attribute" Scope="Vertex" Semantic="Position" DataType="vec3"/>
		<Input Name="u_source" Semantic="Texture2D" DataType="DataTexture2D"/>
		<Input Name="u_ibs" Semantic="InverseBufferSize" DataType="vec2"/>
		<Input Name="u_fx_scale" Semantic="FxScale" DataType="float"/>
		<Input Name="u_pass" Semantic="Constant" DataType="float"/>
		<Input Name="u_attenuation" Semantic="Constant" DataType="float"/>
		<Input Name="u_blur_d" Semantic="Constant" DataType="vec2"/>
	</Inputs>
	<Vertex Source="%out.position% = vec4(a_position, 1.0);"/>
	<Pixel Source="
vec2 UV = %in.fragcoord%.xy * u_ibs * u_fx_scale;
float b = pow(4.0, u_pass);

vec4 ref = texture2D(u_source, UV);

vec3 color = ref.rgb;
float k = 1.0;

for (float s = 1.0; s &lt; 4.0; s++)
{
	float w = clamp(pow(u_attenuation, b * s), 0.0, 1.0);
	vec2 dt_UV = u_blur_d * u_ibs * b * s;

	color += w * texture2D(u_source, UV - dt_UV).rgb;
	color += w * texture2D(u_source, UV + dt_UV).rgb;
	k += w + w;
}
%out.color% = vec4(color / k, ref.a);
"/>
</Shader>