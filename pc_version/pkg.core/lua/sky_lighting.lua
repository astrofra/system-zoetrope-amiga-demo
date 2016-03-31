-- {"name":"Sky Lighting", "compatibility":["Node", "Scene"], "category":"Lighting", "editor":["@data/script_integration/register_as_component.py", "@data/script_integration/add_to_scene_create_menu.py"]}
execution_context = gs.ScriptContextAll

--------------------------------------------------------------------------------
time_of_day = 12 --> float
longitude = 0.3 --> float
attenuation = 1.0 --> float

shadow_range = 150 --> float
shadow_bias = 0.01 --> float
shadow_split = gs.Vector4(0.25, 0.25, 0.25, 0.25) --> gs::Vector4
--------------------------------------------------------------------------------

dofile("@core/lua/math_common.lua")

function LatlongToDirection(latitude, longitude)
	return gs.Vector3(math.sin(latitude) * math.sin(longitude), math.cos(latitude), math.sin(latitude) * math.cos(longitude))
end

function CreateSkyLight(name, enabled_shadow)
	local node = gs.Node()
	node:SetInstantiatedBy(this)
	node:SetName(name)

	local transform = gs.Transform()
	node:AddComponent(transform)

	local light = gs.Light()
	light:SetModel(gs.Light.Model_Linear)
	if enabled_shadow then
		light:SetShadow(gs.Light.Shadow_Map)
		light:SetShadowRange(150)
	end
	node:AddComponent(light)

	return node
end

main_light = nil
back_light = nil
rayleigh = nil

function Setup()
	main_light = CreateSkyLight("Sky Main Light", true)
	this:AddNode(main_light)

	back_light = CreateSkyLight("Sky Back Light", false)
	this:AddNode(back_light)

	rayleigh = gs.RenderScript()
	rayleigh:SetPath("@core/lua/sky_scatter.lua")
	rayleigh:SetDoNotSerialize(true)
	rayleigh:SetShowInEditor(false)
	this:AddComponent(rayleigh)

	UpdateLighting()
end

function UpdateLighting()
	local main_light_c = main_light:GetLight()
	main_light_c:SetDiffuseIntensity(1.0 * attenuation)
	main_light_c:SetSpecularIntensity(1.0 * attenuation)

	main_light_c:SetShadowRange(shadow_range)
	main_light_c:SetShadowBias(shadow_bias)
	main_light_c:SetShadowSplit(shadow_split)

	local back_light_c = back_light:GetLight()
	back_light_c:SetDiffuseIntensity(0.5 * attenuation)

	-- compute latitude from time of day
	local latitude = (time_of_day / 24.0 - 0.5) * math.pi * 2.0

	-- send to the render script
	rayleigh:Set("latitude", latitude)
	rayleigh:Set("longitude", longitude)

	-- set main light attributes
	local light_dir = LatlongToDirection(latitude, longitude)

	local light_color = get_rayleight(light_dir, light_dir, true)
	main_light_c:SetDiffuseColor(light_color)
	main_light_c:SetSpecularColor(light_color)

	main_light:GetTransform():SetWorld(gs.Matrix4(gs.Matrix3.LookAt(light_dir:Reversed())))

	-- set back light attributes
	local back_light_dir = LatlongToDirection(latitude, longitude + math.pi)
	local back_light_color = get_rayleight(back_light_dir, light_dir, false)
	back_light_c:SetDiffuseColor(back_light_color)

	back_light:GetTransform():SetWorld(gs.Matrix4(gs.Matrix3.LookAt(light_dir)))

	-- update scene environment if it exists
	local scene_environment = this:GetComponentsWithAspect("Environment")

	if #scene_environment > 0 then
		-- evaluate ambient color by sampling the skybox along the horizon line
		local ambient_color = gs.Color(0, 0, 0)
		ambient_color = ambient_color + get_rayleight(gs.Vector3.Right, light_dir, false)
		ambient_color = ambient_color + get_rayleight(gs.Vector3.Left, light_dir, false)
		ambient_color = ambient_color + get_rayleight(gs.Vector3.Up, light_dir, false)
		ambient_color = ambient_color + get_rayleight(gs.Vector3.Down, light_dir, false)
		ambient_color = ambient_color * 0.25

		-- set in environment
		scene_environment[1]:SetTimeOfDay(time_of_day / 24)
		scene_environment[1]:SetAmbientIntensity(0.5)
		scene_environment[1]:SetAmbientColor(ambient_color)
	end
end

function OnEditorSetParameter(name)
	time_of_day = Clamp(time_of_day, 0, 24)
	UpdateLighting()
end

function Delete()
	this:RemoveNode(main_light)
	this:RemoveNode(back_light)
	this:RemoveComponent(rayleigh)
end

--------------------------------------------------------------------------------
-- skybox rayleigh model ported straight from the shader
--------------------------------------------------------------------------------

-- values for the rayleigh (should be the same as used by the shader)
rayleigh_strength = 0.3
rayleigh_brightness = 2.5 
rayleigh_collection_power = 0.20 

mie_strength = 0.01 
mie_brightness = 0.1 
mie_collection_power = 0.6 
mie_distribution = 0.13 

spot_brightness = 30.0 
scatter_strength = 0.05 

step_count = 6.0 
intensity = 1.0 
surface_height = 0.994 

function smoothstep(edge0, edge1, x)
    local t = Clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)
end

function phase(alpha, g)
	local g2 = g * g
	local a = 3.0 * (1.0 - g2)
	local b = 2.0 * (2.0 + g2)
	local c = 1.0 + alpha * alpha
	local d = math.pow(1.0 + g2 - 2.0 * g * alpha, 1.5)
	return (a / b) * (c / d)
end

function atmospheric_depth(position, dir)
	local a = dir:Dot(dir)
	local b = 2.0 * dir:Dot(position)
	local c = position:Dot(position) - 1.0
	local det = b * b - 4.0 * a * c
	local detSqrt = math.sqrt(det)
	local q = (-b - detSqrt) / 2.0
	local t1 = c / q
	return t1
end

function horizon_extinction(position, dir, radius)
	local u = dir:Dot(position * -1)
	if u < 0.0 then
		return 1.0
	end

	local near = position + dir * u
	if near:Len() < radius then
		return 0.0
	end

	local v2 = near:Normalized() * radius - position
	local diff = math.acos(v2:Normalized():Dot(dir))
	return smoothstep(0.0, 1.0, math.pow(diff * 2.0, 3.0))
end

Kr = gs.Vector3(0.18867780436772762, 0.4978442963618773, 0.6616065586417131)

function absorb(dist, color, factor)
	local k = factor / dist
	return color - color * gs.Vector3(math.pow(Kr.x, k), math.pow(Kr.y, k), math.pow(Kr.z, k))
end 
	
function get_rayleight(eyedir, lightdir, use_spot)
	local alpha = Clamp(eyedir:Dot(lightdir), -1, 1)
		
	local rayleigh_factor = phase(alpha, -0.01) * rayleigh_brightness
	local mie_factor = phase(alpha, mie_distribution) * mie_brightness
	local spot = smoothstep(0.0, 15.0, phase(alpha, 0.9995)) * spot_brightness

	local eye_position = gs.Vector3(0.0, surface_height, 0.0)
	local eye_depth = atmospheric_depth(eye_position, eyedir)
	local step_length = eye_depth / step_count
	local eye_extinction = horizon_extinction(eye_position, eyedir, surface_height - 0.15)

	local rayleigh_collected = gs.Vector3(0.0, 0.0, 0.0)
	local mie_collected = gs.Vector3(0.0, 0.0, 0.0)
	
	for	i = 0, step_count-1 do
		local sample_distance = step_length * i
		local position = eye_position + eyedir * sample_distance
		local extinction = horizon_extinction(position, lightdir, surface_height - 0.35)
		local sample_depth = atmospheric_depth(position, lightdir)
	
		local influx = absorb(sample_depth, gs.Vector3(intensity, intensity, intensity), scatter_strength) * extinction
		rayleigh_collected = rayleigh_collected + absorb(sample_distance, influx * Kr, rayleigh_strength)
		mie_collected = mie_collected + absorb(sample_distance, influx, mie_strength)
	end

	rayleigh_collected = (rayleigh_collected * eye_extinction * math.pow(eye_depth, rayleigh_collection_power)) / step_count
	mie_collected = (mie_collected * eye_extinction * math.pow(eye_depth, mie_collection_power)) / step_count

	local output = mie_collected * mie_factor + rayleigh_collected * rayleigh_factor
	if use_spot then
		output = output + mie_collected * spot
	end

	return gs.Color(output.x, output.y, output.z)
end
