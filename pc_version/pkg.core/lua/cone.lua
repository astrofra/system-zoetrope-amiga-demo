-- {"name":"Cone", "category":"Primitive", "editor":["@data/script_integration/register_as_component.py", "@data/script_integration/add_to_scene_create_menu.py"]}
execution_context = gs.ScriptContextAll

radius = 1 --> float
height = 1 --> float
subdiv = 4 --> int
smoothing_angle = 40.0 --> float
material = nil --> RenderMaterial

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
	if geo:AllocateVertex(subdiv + 1) == 0 then
		return
	end

	for c = 0, (subdiv - 1) do
		local c_a = c * (math.rad(360)) / subdiv
		geo:SetVertex(c, math.cos(c_a) * radius, 0, math.sin(c_a) * radius)
	end
	geo:SetVertex(subdiv, 0, height, 0)

	-- build polygons
	if geo:AllocatePolygon(subdiv + 1) == 0 then
		return
	end

	geo:SetPolygon(0, subdiv, 0)
	for n=1,subdiv do
	   geo:SetPolygon(n, 3, 0)
	end

	geo:AllocateRgb(subdiv * 3 + subdiv)
	geo:AllocateUVChannel(3, subdiv * 3 + subdiv)

	if geo:AllocatePolygonBinding() == 0 then
		return
	end

	local idx_vtx_up_list = {}
	local uv_list = {}
	local color_list = {}

	-- the big polygon at the back of the cone
	for c = 0, (subdiv - 1) do
		idx_vtx_up_list[#idx_vtx_up_list + 1] = c

		local c_a = c * (math.rad(360)) / subdiv
		uv_list[#uv_list + 1] = gs.Vector2(math.cos(c_a) * 0.25 + 0.25, math.sin(c_a) * 0.25 + 0.25)
		color_list[#color_list + 1] = gs.Color.One
	end
	geo:SetRgb(0, color_list)
	geo:SetUV(0, 0, uv_list)
	geo:SetUV(1, 0, uv_list)
	geo:SetUV(2, 0, uv_list)
	geo:SetPolygonBinding(0, idx_vtx_up_list)

	-- side of the cone
	for c = 0, (subdiv - 1) do
		local next_id = c + 1
		if c + 1 >= subdiv then
			next_id = 0
		end

		geo:SetPolygonBinding(c + 1, {next_id, c, subdiv})
		geo:SetRgb(c + 1, {gs.Color.One, gs.Color.One, gs.Color.One})
		local uv1 = gs.Vector2((c + 1)/subdiv, 0.5)
		local uv2 = gs.Vector2(c / subdiv, 0.5)
		local uv3 = gs.Vector2(0.5, 1)
		geo:SetUV(0, c + 1, {uv1, uv2, uv3})
		geo:SetUV(1, c + 1, {uv1, uv2, uv3})
		geo:SetUV(2, c + 1, {uv1, uv2, uv3})
	end

	geo:ComputeVertexNormal(math.rad(smoothing_angle))
	geo:ComputeVertexTangent()

	return engine:GetRenderSystemAsync():CreateGeometry(geo)
end

function GetUniqueName()
	return string.format("@gen/cone_%.2f_%d_%d_%.2f_%s", radius, height, subdiv, smoothing_angle, GetMaterialPath())
end

object = nil -- associated object component (hidden and not serialized)

function Setup()
	local render_system = engine:GetRenderSystemAsync()

	local uname = GetUniqueName()
	print("CONE SETUP: "..uname)
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
	if subdiv < 3 then subdiv = 3 end
	if smoothing_angle < 0.0 then smoothing_angle = 0.0 end
	if smoothing_angle > 180.0 then smoothing_angle = 180.0 end

	Setup() -- simply regenerate the geometry on parameter change
end

function Delete()
	this:RemoveComponent(object) -- remove our object component
	object = nil
end
