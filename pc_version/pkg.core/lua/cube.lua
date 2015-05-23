-- {"name":"Cube", "category":"Primitive", "editor":["@data/script_integration/register_as_component.py", "@data/script_integration/add_to_scene_create_menu.py"]}
execution_context = gs.ScriptContextAll

width = 1 --> float
height = 1 --> float
length = 1 --> float
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

	local d = gs.Vector3(width, height, length)
	d = d * 0.5

	geo:AllocateMaterialTable(1)
	geo:SetMaterial(0, GetMaterialPath(), true)

	-- generate vertices
	if geo:AllocateVertex(8) == 0 then
		return
	end

	geo:SetVertex(0, -d.x, d.y, d.z);
	geo:SetVertex(1, d.x, d.y, d.z);
	geo:SetVertex(2, d.x, d.y, -d.z);
	geo:SetVertex(3, -d.x, d.y, -d.z);
	geo:SetVertex(4, -d.x, -d.y, d.z);
	geo:SetVertex(5, d.x, -d.y, d.z);
	geo:SetVertex(6, d.x, -d.y, -d.z);
	geo:SetVertex(7, -d.x, -d.y, -d.z);

	-- build polygons
	if geo:AllocatePolygon(6) == 0 then
		return
	end

	for n = 0, 5 do
	   geo:SetPolygon(n, 4, 0)
	end

	geo:AllocateRgb(6 * 4)
	geo:AllocateUVChannel(3, 6 * 4)

	if geo:AllocatePolygonBinding() == 0 then
		return
	end

	geo:SetPolygonBinding(0, {0, 1, 2, 3})
	geo:SetPolygonBinding(1, {3, 2, 6, 7})
	geo:SetPolygonBinding(2, {7, 6, 5, 4})
	geo:SetPolygonBinding(3, {4, 5, 1, 0})
	geo:SetPolygonBinding(4, {2, 1, 5, 6})
	geo:SetPolygonBinding(5, {0, 3, 7, 4})

	for c = 0, 5 do
		geo:SetRgb(c, {gs.Color.One, gs.Color.One, gs.Color.One, gs.Color.One})
	end

	geo:SetUV(0, 0, {gs.Vector2(0.5, 0), gs.Vector2(0.5, 0.33), gs.Vector2(0.25, 0.33), gs.Vector2(0.25, 0)})
	geo:SetUV(0, 1, {gs.Vector2(0, 0.33), gs.Vector2(0.25, 0.33), gs.Vector2(0.25, 0.66), gs.Vector2(0, 0.66)})
	geo:SetUV(0, 2, {gs.Vector2(0.25, 1), gs.Vector2(0.25, 0.66), gs.Vector2(0.5, 0.66), gs.Vector2(0.5, 1)})
	geo:SetUV(0, 3, {gs.Vector2(0.75, 0.66), gs.Vector2(0.5, 0.66), gs.Vector2(0.5, 0.33), gs.Vector2(0.75, 0.33)})
	geo:SetUV(0, 4, {gs.Vector2(0.25, 0.33), gs.Vector2(0.5, 0.33), gs.Vector2(0.5, 0.66), gs.Vector2(0.25, 0.66)})
	geo:SetUV(0, 5, {gs.Vector2(0.75, 0.33), gs.Vector2(1, 0.33), gs.Vector2(1, 0.66), gs.Vector2(0.75, 0.66)})

	geo:SetUV(1, 0, {gs.Vector2(0.5, 0), gs.Vector2(0.5, 0.33), gs.Vector2(0.25, 0.33), gs.Vector2(0.25, 0)})
	geo:SetUV(1, 1, {gs.Vector2(0, 0.33), gs.Vector2(0.25, 0.33), gs.Vector2(0.25, 0.66), gs.Vector2(0, 0.66)})
	geo:SetUV(1, 2, {gs.Vector2(0.25, 1), gs.Vector2(0.25, 0.66), gs.Vector2(0.5, 0.66), gs.Vector2(0.5, 1)})
	geo:SetUV(1, 3, {gs.Vector2(0.75, 0.66), gs.Vector2(0.5, 0.66), gs.Vector2(0.5, 0.33), gs.Vector2(0.75, 0.33)})
	geo:SetUV(1, 4, {gs.Vector2(0.25, 0.33), gs.Vector2(0.5, 0.33), gs.Vector2(0.5, 0.66), gs.Vector2(0.25, 0.66)})
	geo:SetUV(1, 5, {gs.Vector2(0.75, 0.33), gs.Vector2(1, 0.33), gs.Vector2(1, 0.66), gs.Vector2(0.75, 0.66)})

	geo:SetUV(2, 0, {gs.Vector2(0.5, 0), gs.Vector2(0.5, 0.33), gs.Vector2(0.25, 0.33), gs.Vector2(0.25, 0)})
	geo:SetUV(2, 1, {gs.Vector2(0, 0.33), gs.Vector2(0.25, 0.33), gs.Vector2(0.25, 0.66), gs.Vector2(0, 0.66)})
	geo:SetUV(2, 2, {gs.Vector2(0.25, 1), gs.Vector2(0.25, 0.66), gs.Vector2(0.5, 0.66), gs.Vector2(0.5, 1)})
	geo:SetUV(2, 3, {gs.Vector2(0.75, 0.66), gs.Vector2(0.5, 0.66), gs.Vector2(0.5, 0.33), gs.Vector2(0.75, 0.33)})
	geo:SetUV(2, 4, {gs.Vector2(0.25, 0.33), gs.Vector2(0.5, 0.33), gs.Vector2(0.5, 0.66), gs.Vector2(0.25, 0.66)})
	geo:SetUV(2, 5, {gs.Vector2(0.75, 0.33), gs.Vector2(1, 0.33), gs.Vector2(1, 0.66), gs.Vector2(0.75, 0.66)})

	geo:ComputeVertexNormal(math.rad(smoothing_angle))
	geo:ComputeVertexTangent()

	return engine:GetRenderSystemAsync():CreateGeometry(geo)
end

function GetUniqueName()
	return string.format("@gen/cube_%.2f_%.2f_%.2f_%.2f_%s", width, height, length, smoothing_angle, GetMaterialPath())
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
	if smoothing_angle < 0.0 then smoothing_angle = 0.0 end
	if smoothing_angle > 180.0 then smoothing_angle = 180.0 end

	Setup() -- simply regenerate the geometry on parameter change
end

function Delete()
	this:RemoveComponent(object) -- remove our object component
	object = nil
end
