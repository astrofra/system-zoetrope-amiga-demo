-- {"name":"Sphere", "category":"Primitive", "editor":["@data/script_integration/register_as_component.py", "@data/script_integration/add_to_scene_create_menu.py"]}
execution_context = gs.ScriptContextAll

radius = 0.5 --> float
subdiv_x = 16 --> int
subdiv_y = 6 --> int
smoothing_angle = 40.0 --> float
material = nil --> RenderMaterial

function Wrap(v, range_start, range_end)
	local dt = math.floor(math.floor(range_end) - math.floor(range_start) + 1)

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
	if geo:AllocateVertex((subdiv_y + 1) * subdiv_x + 2) == 0 then
		return
	end

	geo:SetVertex(0, 0, radius, 0)

	local vtx_counter = 1
	for s = 0, subdiv_y do

		local t = (s + 1) / (subdiv_y + 2)
		local a = t * math.rad(180)

		local y = math.cos(a) * radius
		local s_r = math.sin(a) * radius

		for c = 0, (subdiv_x - 1) do
			local c_a = c * (math.rad(360)) / subdiv_x

			geo:SetVertex(vtx_counter, math.cos(c_a) * s_r, y, math.sin(c_a) * s_r)
			vtx_counter = vtx_counter + 1
		end
	end

	geo:SetVertex(vtx_counter, 0, -radius, 0)

	-- Build polygons.
	if geo:AllocatePolygon((subdiv_y + 2) * subdiv_x) == 0 then
		return
	end

	local poly_counter = 0
	local uv_counter = 0

	for c = 0, (subdiv_x - 1) do
		geo:SetPolygon(poly_counter, 3, 0)
		poly_counter = poly_counter + 1
		uv_counter = uv_counter + 3
	end

	for s = 0, (subdiv_y - 1) do
		for c = 0,(subdiv_x - 1) do
			geo:SetPolygon(poly_counter, 4, 0)
			poly_counter = poly_counter + 1
			uv_counter = uv_counter + 4
		end
	end

	for c = 0, (subdiv_x - 1) do
		geo:SetPolygon(poly_counter, 3, 0)
		poly_counter = poly_counter + 1
		uv_counter = uv_counter + 3
	end

	geo:AllocateRgb(uv_counter)
	geo:AllocateUVChannel(3, uv_counter)

	if geo:AllocatePolygonBinding() == 0 then
		return
	end

	poly_counter = 0
	for c = 0, (subdiv_x - 1) do
		geo:SetPolygonBinding(poly_counter, {0, Wrap(c + 2, 1, subdiv_x), c + 1})
		geo:SetRgb(poly_counter, {gs.Color.One, gs.Color.One, gs.Color.One})
		local uv1 = gs.Vector2(0, Wrap((c + 0.5) / subdiv_x, 0, 1))
		local uv2 = gs.Vector2(1 / (subdiv_y + 2), Wrap((c + 1) / subdiv_x, 0, 1))
		local uv3 = gs.Vector2(1 / (subdiv_y + 2), c / subdiv_x)
		geo:SetUV(0, poly_counter, {uv1, uv2, uv3})
		geo:SetUV(1, poly_counter, {uv1, uv2, uv3})
		geo:SetUV(2, poly_counter, {uv1, uv2, uv3})
		poly_counter = poly_counter + 1
	end

	for s = 0, (subdiv_y - 1) do
		local i = 1 + subdiv_x * s
		for c = 0, (subdiv_x - 1) do
			geo:SetPolygonBinding(poly_counter, {i + c,
												Wrap(i + c + 1, i, i + subdiv_x - 1) ,
												Wrap(i + c + subdiv_x + 1, i + subdiv_x, i + subdiv_x * 2 - 1) ,
												i + c + subdiv_x})
			local uv1 = (s + 1) / (subdiv_y + 2)
			local uv2 = (s + 2) / (subdiv_y + 2)
			local uv3 = c / subdiv_x
			local uv4 = Wrap((c + 1) / subdiv_x, 0, 1)
			geo:SetRgb(poly_counter, {gs.Color.One, gs.Color.One, gs.Color.One, gs.Color.One})
			geo:SetUV(0, poly_counter, {gs.Vector2(uv1, uv3), gs.Vector2(uv1, uv4), gs.Vector2(uv2, uv4), gs.Vector2(uv2, uv3)})
			geo:SetUV(1, poly_counter, {gs.Vector2(uv1, uv3), gs.Vector2(uv1, uv4), gs.Vector2(uv2, uv4), gs.Vector2(uv2, uv3)})
			geo:SetUV(2, poly_counter, {gs.Vector2(uv1, uv3), gs.Vector2(uv1, uv4), gs.Vector2(uv2, uv4), gs.Vector2(uv2, uv3)})
		   poly_counter = poly_counter + 1
		end
	end

	local i = 1 + subdiv_x * subdiv_y
	for c = 0, (subdiv_x - 1) do
		geo:SetPolygonBinding(poly_counter, {i + c, Wrap(i + c + 1, i, i + subdiv_x - 1), i + subdiv_x})
		geo:SetRgb(poly_counter, {gs.Color.One, gs.Color.One, gs.Color.One})
		local uv1 = gs.Vector2(1 - 1 / (subdiv_y + 2), c / subdiv_x)
		local uv2 = gs.Vector2(1 - 1 / (subdiv_y + 2), Wrap((c + 1) / subdiv_x, 0, 1))
		local uv3 = gs.Vector2(0.99, Wrap((c + 0.5) / subdiv_x, 0, 1))
		geo:SetUV(0, poly_counter, {uv1, uv2, uv3})
		geo:SetUV(1, poly_counter, {uv1, uv2, uv3})
		geo:SetUV(2, poly_counter, {uv1, uv2, uv3})
		poly_counter = poly_counter + 1
	end

	geo:ComputeVertexNormal(math.rad(smoothing_angle))
	geo:ComputeVertexTangent()

	return engine:GetRenderSystemAsync():CreateGeometry(geo)
end

function GetUniqueName()
	return string.format("@gen/sphere_%.2f_%d_%d_%.2f_%s", radius, subdiv_y, subdiv_x, smoothing_angle, GetMaterialPath())
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
	if subdiv_y < 4 then subdiv_y = 4 end
	if subdiv_x < 6 then subdiv_x = 6 end
	if radius < 0.1 then radius = 0.1 end
	if smoothing_angle < 0.0 then smoothing_angle = 0.0 end
	if smoothing_angle > 180.0 then smoothing_angle = 180.0 end

	Setup() -- simply regenerate the geometry on parameter change
end

function Delete()
	this:RemoveComponent(object) -- remove our object component
	object = nil
end
