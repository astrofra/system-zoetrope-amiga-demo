-- {"name":"Capsule", "category":"Primitive", "editor":["@data/script_integration/register_as_component.py", "@data/script_integration/add_to_scene_create_menu.py"]}

execution_context = gs.ScriptContextAll

height = 2.0 --> float
radius = 0.5 --> float
subdiv_y = 6 --> int
subdiv_x = 16 --> int
smoothing_angle = 40.0 --> float
material = nil --> RenderMaterial

function Wrap(v, range_start, range_end, use_float)
	local dt = math.floor(math.floor(range_end) - math.floor(range_start) + 1)
	if use_float == false then
		v = math.floor(v)
	end

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

	local height_cylinder = (height - radius * 2)
	if height_cylinder < 0 then
		height_cylinder = 0
	end

	-- generate vertices
	if geo:AllocateVertex((subdiv_y + 1) * subdiv_x * 2 + 2) == 0 then
		return
	end

	geo:SetVertex(0, -radius - (height_cylinder * 0.5), 0, 0)

	local vtx_counter = 1
	for s = 0, subdiv_y do

		local t = (s + 1) / (subdiv_y + 2)
		local a = t * math.pi * 0.5

		local y = math.cos(a) * radius + (height_cylinder * 0.5)
		local s_r = math.sin(a) * radius

		for c = 0, (subdiv_x - 1) do

			local c_a = c * (math.rad(360)) / subdiv_x

			geo:SetVertex(vtx_counter, -y, math.cos(c_a) * s_r, math.sin(c_a) * s_r)
			vtx_counter = vtx_counter + 1
		end
	end
	for s = 0, subdiv_y do

		local t = (s + 1) / (subdiv_y + 1)
		local a = t * math.pi * 0.5

		local y = math.cos(a) * radius + (height_cylinder * 0.5)
		local s_r = math.sin(a) * radius

		for c = 0, (subdiv_x-1) do

			local c_a = c * (math.rad(360)) / subdiv_x

			geo:SetVertex(vtx_counter, y, math.cos(c_a) * s_r, math.sin(c_a) * s_r)
			vtx_counter = vtx_counter + 1
		end
	end

	geo:SetVertex(vtx_counter, radius + (height_cylinder * 0.5), 0, 0)

	-- Build polygons.
	if geo:AllocatePolygon((subdiv_y * 2 + 2) * subdiv_x + subdiv_x) == 0 then
		return
	end

	local poly_counter = 0
	local uv_counter = 0

	-- north pole triangles
	for c =0, (subdiv_x - 1) do
		geo:SetPolygon(poly_counter, 3, 0)
		poly_counter = poly_counter + 1
		uv_counter = uv_counter + 3
	end
	-- north pole quad from the dome
	for s = 0, (subdiv_y - 1) do
		for c = 0, (subdiv_x - 1) do
			geo:SetPolygon(poly_counter, 4, 0)
			poly_counter = poly_counter + 1
			uv_counter = uv_counter + 4
		end
	end
	-- middle tube
	for c = 0, (subdiv_x - 1) do
		geo:SetPolygon(poly_counter, 4, 0)
		poly_counter = poly_counter + 1
		 uv_counter = uv_counter + 4
	end
	-- south pole quad from the dome
	for s = 0, (subdiv_y - 1) do
		for c = 0, (subdiv_x - 1) do
			geo:SetPolygon(poly_counter, 4, 0)
			poly_counter = poly_counter + 1
			uv_counter = uv_counter + 4
		end
	end
	-- south pole triangles
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

	local function sin_cos_between_zero_one(v)
		return (v + 1) * 0.5
	end

	-- north pole triangles
	local poly_counter = 0
	for c = 0, (subdiv_x - 1) do
		geo:SetPolygonBinding(poly_counter, {0, Wrap(c + 2, 1, subdiv_x, false), c + 1})
		geo:SetRgb(poly_counter, {gs.Color.One, gs.Color.One, gs.Color.One})
		local r = 1.0 / subdiv_y
		local first_value = Wrap((c + 1) / subdiv_x, 0, 1, true) * 2 * math.pi
		local second_value = (c / subdiv_x) * 2 * math.pi
		local uv1 = gs.Vector2((sin_cos_between_zero_one(math.sin(first_value) * r)), sin_cos_between_zero_one(math.cos(first_value) * r))
		local uv2 = gs.Vector2(sin_cos_between_zero_one(math.sin(second_value) *r), sin_cos_between_zero_one(math.cos(second_value) * r))
		geo:SetUV(0, poly_counter, {gs.Vector2(0.5, 0.5), uv1, uv2})
		geo:SetUV(1, poly_counter, {gs.Vector2(0.5, 0.5), uv1, uv2})
		geo:SetUV(2, poly_counter, {gs.Vector2(0.5, 0.5), uv1, uv2})

		poly_counter = poly_counter + 1
	end

	-- north pole quad from the dome
	for s = 0, (subdiv_y - 1) do
		local i = 1 + subdiv_x * s
		for c = 0,( subdiv_x - 1) do
			geo:SetPolygonBinding(poly_counter, {i + c,
												Wrap(i + c + 1, i, i + subdiv_x - 1, false) ,
												Wrap(i + c + subdiv_x + 1, i + subdiv_x, i + subdiv_x * 2 - 1, false) ,
												i + c + subdiv_x})
			geo:SetRgb(poly_counter, {gs.Color.One, gs.Color.One, gs.Color.One, gs.Color.One})

			local uv1 = (c / subdiv_x) * 2 * math.pi
			local uv2 = Wrap((c + 1) / subdiv_x, 0, 1, true) * 2 * math.pi
			local r = (1.0 / subdiv_y) * (s + 1)
			local v_uva = gs.Vector2(sin_cos_between_zero_one(math.sin(uv1) * r), sin_cos_between_zero_one(math.cos(uv1) * r))
			local v_uvb = gs.Vector2(sin_cos_between_zero_one(math.sin(uv2) * r), sin_cos_between_zero_one(math.cos(uv2) * r))
			r = (1.0 / subdiv_y) * (s+2)
			local v_uvc = gs.Vector2(sin_cos_between_zero_one(math.sin(uv2) * r), sin_cos_between_zero_one(math.cos(uv2) * r))
			local v_uvd = gs.Vector2(sin_cos_between_zero_one(math.sin(uv1) * r), sin_cos_between_zero_one(math.cos(uv1) * r))
			geo:SetUV(0, poly_counter, {v_uva, v_uvb, v_uvc, v_uvd})
			geo:SetUV(1, poly_counter, {v_uva, v_uvb, v_uvc, v_uvd})
			geo:SetUV(2, poly_counter, {v_uva, v_uvb, v_uvc, v_uvd})

		   poly_counter = poly_counter + 1
		end
	end

	-- middle tube
	local i = 1 + subdiv_x * subdiv_y
	local j = 1 + subdiv_x * subdiv_y + subdiv_x * (subdiv_y+1)
	for c = 0, (subdiv_x - 1) do
		geo:SetPolygonBinding(poly_counter, {i + c,
											Wrap(i + c + 1, i, i + subdiv_x - 1, false) ,
											Wrap(j + c + 1, j, j + subdiv_x - 1, false) ,
												j + c})
		geo:SetRgb(poly_counter, {gs.Color.One, gs.Color.One, gs.Color.One, gs.Color.One})
		local uv1 = gs.Vector2(c / subdiv_x, 0.5)
		local uv2 = gs.Vector2((c + 1)/subdiv_x, 0.5)
		local uv3 = gs.Vector2((c + 1)/subdiv_x, 1)
		local uv4 = gs.Vector2(c / subdiv_x, 1)
		geo:SetUV(0, poly_counter, {uv1, uv2, uv3, uv4})
		geo:SetUV(1, poly_counter, {uv1, uv2, uv3, uv4})
		geo:SetUV(2, poly_counter, {uv1, uv2, uv3, uv4})
		poly_counter = poly_counter + 1
	end

	-- south pole quad from the dome
	for s = 0,(subdiv_y - 1) do
		local i = 1 + subdiv_x * s + subdiv_x * (subdiv_y + 1)
		for c = 0,(subdiv_x - 1) do
			geo:SetPolygonBinding(poly_counter, {i + c,
												i + c + subdiv_x,
												Wrap(i + c + subdiv_x + 1, i + subdiv_x, i + subdiv_x * 2 - 1, false) ,
												Wrap(i + c + 1, i, i + subdiv_x - 1, false)})
		    geo:SetRgb(poly_counter, {gs.Color.One, gs.Color.One, gs.Color.One})

			local uv1 = (c / subdiv_x) * 2 * math.pi
			local uv2 = Wrap((c + 1) / subdiv_x, 0, 1, true) * 2 * math.pi
			local r = (1.0 / subdiv_y) * (s + 1)
			local v_uva = gs.Vector2(sin_cos_between_zero_one(math.sin(uv1) * r), sin_cos_between_zero_one(math.cos(uv1) * r))
			local v_uvb = gs.Vector2(sin_cos_between_zero_one(math.sin(uv2) * r), sin_cos_between_zero_one(math.cos(uv2) * r))
			r = (1.0 / subdiv_y) * (s + 2)
			local v_uvc = gs.Vector2(sin_cos_between_zero_one(math.sin(uv2) * r), sin_cos_between_zero_one(math.cos(uv2) * r))
			local v_uvd = gs.Vector2(sin_cos_between_zero_one(math.sin(uv1) * r), sin_cos_between_zero_one(math.cos(uv1) * r))
			geo:SetUV(0, poly_counter, {v_uva, v_uvd, v_uvc, v_uvb})
			geo:SetUV(1, poly_counter, {v_uva, v_uvd, v_uvc, v_uvb})
			geo:SetUV(2, poly_counter, {v_uva, v_uvd, v_uvc, v_uvb})

		   poly_counter = poly_counter + 1
		end
	end

	-- south pole triangles
	i = 1 + subdiv_x * (subdiv_y + 1)
	for c = 0, (subdiv_x - 1) do
		geo:SetPolygonBinding(poly_counter, {i + c, Wrap(i + c + 1, i, i + subdiv_x - 1, false), (subdiv_y + 1) * subdiv_x *2 + 1})
		geo:SetRgb(poly_counter, {gs.Color.One, gs.Color.One, gs.Color.One})
		local r = 1.0 / subdiv_y
		local second_value = Wrap((c + 1) / subdiv_x, 0, 1, true) * 2 * math.pi
		local first_value = (c / subdiv_x) * 2 * math.pi
		local uv1 = gs.Vector2(sin_cos_between_zero_one(math.sin(first_value) * r), sin_cos_between_zero_one(math.cos(first_value) * r))
		local uv2 = gs.Vector2(sin_cos_between_zero_one(math.sin(second_value) * r), sin_cos_between_zero_one(math.cos(second_value) * r))
		geo:SetUV(0, poly_counter, {uv1, uv2, gs.Vector2(0.5, 0.5)})
		geo:SetUV(1, poly_counter, {uv1, uv2, gs.Vector2(0.5, 0.5)})
		geo:SetUV(2, poly_counter, {uv1, uv2, gs.Vector2(0.5, 0.5)})

		poly_counter = poly_counter + 1
	end

	geo:ComputeVertexNormal(math.rad(smoothing_angle))
	geo:ComputeVertexTangent()

	return engine:GetRenderSystemAsync():CreateGeometry(geo)
end

function GetUniqueName()
	return string.format("@gen/capsule_%.2f_%d_%d_%d_%.2f_%s", radius, subdiv_y, subdiv_x, height, smoothing_angle, GetMaterialPath())
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
