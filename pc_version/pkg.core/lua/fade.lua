-- {"name":"Fade", "compatibility":["Node", "Scene"], "category":"Rendering", "editor":["@data/script_integration/register_as_component.py"]}
execution_context = gs.ScriptContextAll

opacity = 0 --> float
color = gs.Color.Black --> gs::Color

function EndDrawFrame()
	-- do nothing if attached to a node that is not the current view
	if getmetatable(this)[".type"] == "Node" and this ~= render_system:GetView() then
		return
	end

	renderer:SetIdentityMatrices()

	renderer:EnableDepthTest(false)
	renderer:EnableDepthWrite(false)

	renderer:EnableBlending(true)
	renderer:SetBlendFunc(gs.GpuRenderer.BlendSrcAlpha, gs.GpuRenderer.BlendOneMinusSrcAlpha)

	local blend_c = gs.Color(color.r, color.g, color.b, opacity)

	render_system:DrawTriangleAutoRGB(1, {gs.Vector3(-1, -1, 0.5), gs.Vector3(1, -1, 0.5), gs.Vector3(1, 1, 0.5)}, {blend_c, blend_c, blend_c})
	render_system:DrawTriangleAutoRGB(1, {gs.Vector3(-1, -1, 0.5), gs.Vector3(1, 1, 0.5), gs.Vector3(-1, 1, 0.5)}, {blend_c, blend_c, blend_c})
end

function OnEditorSetParameter(name)
	if opacity > 1 then opacity = 1 end
	if opacity < 0 then opacity = 0 end
end
