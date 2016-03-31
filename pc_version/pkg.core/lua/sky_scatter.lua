execution_context = gs.ScriptContextAll

--------------------------------------------------------------------------------
latitude = 0.0 --> float
longitude = 0.3 --> float

rayleigh_strength = 0.3 --> float
rayleigh_brightness = 2.5 --> float
rayleigh_collection_power = 0.20 --> float

mie_strength = 0.01 --> float
mie_brightness = 0.1 --> float
mie_collection_power = 0.6 --> float
mie_distribution = 0.13 --> float

spot_brightness = 30.0 --> float
scatter_strength = 0.05 --> float

step_count = 6 --> int
intensity = 1.0 --> float
surface_height = 0.994 --> float
--------------------------------------------------------------------------------

function ClearFrame()
	-- only clear the depth buffer
	renderer:Clear(gs.Color.Black, 1.0, gs.GpuRenderer.ClearDepth)
	-- notify the engine that clearing has been handled
	return true
end

-- load the rayleigh shader (RenderScript is run from the rendering thread)
shader = renderer:LoadShader("@core/shaders/sky_scatter.isl")

-- hook the end of opaque render pass to draw the skybox
function EndRenderPass(pass)
	if not shader:IsReady() then
		return -- shader is not ready yet
	end

	if pass ~= gs.RenderPass.Opaque then
		return -- we're only interested in the opaque primitive pass
	end

	-- backup current view state
	local view_state = render_system:GetViewState()
	local view_rotation = view_state.view:GetRotationMatrix()

	renderer:SetIdentityMatrices()

	-- configure the rayleigh shader
	renderer:SetShader(shader)

	renderer:SetShaderMatrix3("view_rotation", view_rotation)

	renderer:SetShaderFloat("rayleigh_strength", rayleigh_strength)
	renderer:SetShaderFloat("rayleigh_brightness", rayleigh_brightness)
	renderer:SetShaderFloat("rayleigh_collection_power", rayleigh_collection_power)

	renderer:SetShaderFloat("mie_strength", mie_strength)
	renderer:SetShaderFloat("mie_brightness", mie_brightness)
	renderer:SetShaderFloat("mie_collection_power", mie_collection_power)
	renderer:SetShaderFloat("mie_distribution", mie_distribution)

	renderer:SetShaderFloat("spot_brightness", spot_brightness)
	renderer:SetShaderFloat("scatter_strength", scatter_strength)

	renderer:SetShaderFloat("step_count", step_count)
	renderer:SetShaderFloat("intensity", intensity)
	renderer:SetShaderFloat("surface_height", surface_height)

	renderer:SetShaderFloat("latitude", latitude)
	renderer:SetShaderFloat("longitude", longitude)

	-- configure the frame buffer so that only background pixels are drawn to
	renderer:EnableDepthTest(true)
	renderer:EnableDepthWrite(false)
	renderer:SetDepthFunc(gs.GpuRenderer.DepthLessEqual)
	render_system:DrawFullscreenQuad(render_system:GetViewportToInternalResolutionRatio())
	renderer:EnableDepthWrite(true)
	renderer:EnableDepthTest(true)

	-- restore view state
	render_system:SetViewState(view_state)
end
