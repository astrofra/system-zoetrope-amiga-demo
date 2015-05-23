-- {"name":"Cylinder", "category":"Primitive", "editor":["@data/script_integration/register_as_component.py", "@data/script_integration/add_to_scene_create_menu.py"]}
execution_context = gs.ScriptContextAll

radius = 0.5 --> float
height = 1.0 --> float
subdiv_x = 16 --> int
smoothing_angle = 40.0 --> float
material = nil --> RenderMaterial

function Wrap(v, range_start, range_end)
	local dt = math.floor(math.floor(range_end) - math.floor(range_start) + 1)
	v = math.floor(v)

	while v < range_start do
		v = v + dt
	end
	while v > range_end do
		v = v - dt
	end

	return v
end

function GetMaterialPath()
	if material == nil then
		material = engine:GetRenderSystemAsync():LoadMaterial("@core/materials/default.mat")
	end
	return material:GetName()
end

function CreateRenderGeometry(uname)
	local geo = gs.CoreGeometry()
	geo:SetName(uname)

	geo:AllocateMaterialTable(1)
	geo:SetMaterial(0, GetMaterialPath(), true)

	-- generate vertices
	if geo:AllocateVertex(subdiv_x * 2) == 0 then
		return
	end

	for c = 0, (subdiv_x - 1) do
		local c_a = c * (math.rad(360)) / subdiv_x
		geo:SetVertex(c, math.cos(c_a) * radius, height * 0.5, math.sin(c_a) * radius)
		geo:SetVertex(c + subdiv_x, math.cos(c_a) * radius, -height * 0.5, math.sin(c_a) * radius)
	end

	-- build polygons
	if geo:AllocatePolygon(subdiv_x + 2) == 0 then
		return
	end

	geo:SetPolygon(0, subdiv_x, 0)
	geo:SetPolygon(1, subdiv_x, 0)

	for c = 0, (subdiv_x - 1) do
	   geo:SetPolygon(c + 2, 4, 0)
	end

	geo:AllocateRgb(subdiv_x * 2 + subdiv_x * 4)
	geo:AllocateUVChannel(3, subdiv_x * 2 + subdiv_x * 4)

	if geo:AllocatePolygonBinding() == 0 then
		return
	end

	local idx_vtx_up_list = {}
	local idx_vtx_down_list = {}
	local uv_up_list = {}
	local uv_down_list = {}
	local color_list = {}
	local step_uv = (math.rad(360)) / subdiv_x

	for c = 0, (subdiv_x - 1) do
		idx_vtx_up_list[#idx_vtx_up_list + 1] = (subdiv_x - 1) - c
		idx_vtx_down_list[#idx_vtx_down_list + 1] = c + subdiv_x

		local uv_up = ((subdiv_x - 1) - c) * step_uv
		local uv_down = c * step_uv
		uv_up_list[#uv_up_list + 1] = gs.Vector2(math.cos(uv_up) * 0.25 + 0.25, math.sin(uv_up) * 0.25 + 0.25)
		uv_down_list[#uv_down_list + 1] = gs.Vector2(math.cos(uv_down) * 0.25 + 0.75, math.sin(uv_down) * 0.25 + 0.25)
		color_list[#color_list + 1] = gs.Color.One
	end

	geo:SetRgb(0, color_list)
	geo:SetUV(0, 0, uv_up_list)
	geo:SetUV(1, 0, uv_up_list)
	geo:SetUV(2, 0, uv_up_list)
	geo:SetPolygonBinding(0, idx_vtx_up_list)

	geo:SetRgb(1, color_list)
	geo:SetUV(0, 1, uv_down_list)
	geo:SetUV(1, 1, uv_down_list)
	geo:SetUV(2, 1, uv_down_list)
	geo:SetPolygonBinding(1, idx_vtx_down_list)

	for c = 0, (subdiv_x - 1) do
		geo:SetPolygonBinding(c + 2, {c,
									Wrap(c + 1, 0, subdiv_x - 1) ,
									Wrap(c + 1 + subdiv_x, subdiv_x, subdiv_x * 2 - 1) ,
									c + subdiv_x})
		geo:SetRgb(c + 2, {gs.Color.One, gs.Color.One, gs.Color.One, gs.Color.One})
		local uv1 = gs.Vector2(c / subdiv_x, 0.5)
		local uv2 = gs.Vector2((c + 1) / subdiv_x, 0.5)
		local uv3 = gs.Vector2((c + 1) / subdiv_x, 1)
		local uv4 = gs.Vector2(c / subdiv_x, 1)
		geo:SetUV(0, c + 2, {uv1, uv2, uv3, uv4})
		geo:SetUV(1, c + 2, {uv1, uv2, uv3, uv4})
		geo:SetUV(2, c + 2, {uv1, uv2, uv3, uv4})
	end

	geo:ComputeVertexNormal(math.rad(smoothing_angle))
	geo:ComputeVertexTangent()

	return engine:GetRenderSystemAsync():CreateGeometry(geo)
end

function GetUniqueName()
	return string.format("@gen/cylinder_%.2f_%.2f_%d_%.2f_%s", radius, height, subdiv_x, smoothing_angle, GetMaterialPath())
end

object = nil -- associated object component (hidden and not serialized)

function Setup()
	local render_system = engine:GetRenderSystemAsync()

	local uname = GetUniqueName()
	local render_geo = render_system:HasGeometry(uname)

	if render_geo == nil then
		render_geo = CreateRenderGeometry(uname)
	end

	if object == nil then
		object = gs.Object()
		this:AddComponent(object)
	end

	object:SetShowInEditor(false)
	object:SetDoNotSerialize(true)

	object:SetGeometry(render_geo)
end

function OnEditorSetParameter(name)
	if subdiv_x < 6 then subdiv_x = 6 end
	if subdiv_x >= 256 then subdiv_x = 255 end
	if radius < 0.1 then radius = 0.1 end
	if smoothing_angle < 0.0 then smoothing_angle = 0.0 end
	if smoothing_angle > 180.0 then smoothing_angle = 180.0 end

	Setup() -- simply regenerate the geometry on parameter change
end

function Delete()
	this:RemoveComponent(object) -- remove our object component
	object = nil
end
