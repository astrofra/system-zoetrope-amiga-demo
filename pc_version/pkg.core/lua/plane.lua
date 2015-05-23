-- {"name":"Plane", "category":"Primitive", "editor":["@data/script_integration/register_as_component.py", "@data/script_integration/add_to_scene_create_menu.py"]}
execution_context = gs.ScriptContextAll

width = 1 --> float
length = 1 --> float
subdiv_x = 1 --> int
subdiv_z = 1 --> int
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

	local d = gs.Vector2(width, length)
	d = d * 0.5

	geo:AllocateMaterialTable(1)
	geo:SetMaterial(0, GetMaterialPath(), true)

	-- generate vertices
	local vtx_count = (1 + subdiv_x) * (1 + subdiv_z)
	if geo:AllocateVertex(vtx_count) == 0 then
		return
	end

	local count_vtx = 0
	local x = -d.x
	for i = 0, subdiv_x do
		local z = -d.y
		for j = 0, subdiv_z do
			geo:SetVertex(count_vtx, x, 0, z)
			count_vtx = count_vtx + 1
			z = z + length / subdiv_z
		end
		x = x + width / subdiv_x
	end

	-- build polygons
	local polygon_count = subdiv_x * subdiv_z
	if geo:AllocatePolygon(polygon_count) == 0 then
		return
	end

	for i = 0, polygon_count - 1 do
		geo:SetPolygon(i, 4, 0)
	end

	geo:AllocateRgb(polygon_count * 4)
	geo:AllocateUVChannel(3, polygon_count * 4)

	if geo:AllocatePolygonBinding() == 0 then
		return
	end

	local count_poly = 0
	for i = 0, subdiv_x - 1 do
		for j = 0, subdiv_z - 1 do
			geo:SetPolygonBinding(count_poly, {i * (1 + subdiv_z) + j,
												i * (1 + subdiv_z) + j + 1,
												(i + 1) * (1 + subdiv_z) + j + 1,
												(i + 1) * (1 + subdiv_z) + j})

			geo:SetRgb(count_poly, {gs.Color.One, gs.Color.One, gs.Color.One, gs.Color.One})
			local uv1 = gs.Vector2(i / subdiv_x, j / subdiv_z)
			local uv2 = gs.Vector2(i / subdiv_x, (j + 1) / subdiv_z)
			local uv3 = gs.Vector2((i + 1) / subdiv_x, (j + 1) / subdiv_z)
			local uv4 = gs.Vector2((i + 1) / subdiv_x, j / subdiv_z)
			geo:SetUV(0, count_poly, {uv1, uv2, uv3, uv4})
			geo:SetUV(1, count_poly, {uv1, uv2, uv3, uv4})
			geo:SetUV(2, count_poly, {uv1, uv2, uv3, uv4})
			count_poly = count_poly + 1
		end
	end

	geo:ComputeVertexNormal(math.rad(0.7))
	geo:ComputeVertexTangent()

	return engine:GetRenderSystemAsync():CreateGeometry(geo)
end

function GetUniqueName()
	return string.format("@gen/plane_%.2f_%.2f_%d_%d_%s", width, length, subdiv_x, subdiv_z, GetMaterialPath())
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
	if subdiv_x < 1 then subdiv_x = 1 end
	if subdiv_z < 1 then subdiv_z = 1 end

	Setup() -- simply regenerate the geometry on parameter change
end

function Delete()
	this:RemoveComponent(object) -- remove our object component
	object = nil
end
