-- Generation orchestrator: VoxelManip-based terrain generation with zone support

local generate_floor = minetest.settings:get_bool("temz.generate_floor", true)

-- Cache content IDs for performance (loaded lazily on first use)
local c_air, c_stone, c_dirt, c_grass, c_uliza_ground

local function init_content_ids()
	if c_air then return end
	c_air = minetest.get_content_id("air")
	c_stone = minetest.get_content_id("default:stone")
	c_dirt = minetest.get_content_id("default:dirt")
	c_grass = minetest.get_content_id("default:dirt_with_grass")
	if minetest.registered_nodes["uliza:ground"] then
		c_uliza_ground = minetest.get_content_id("uliza:ground")
	else
		c_uliza_ground = c_grass
	end
end

-- Perlin noise for floor variation
local floor_noise = PerlinNoise({
	offset = 0,
	scale = 1,
	spread = {x = 30, y = 30, z = 30},
	seed = 8472,
	octaves = 3,
	persist = 0.5,
	lacunarity = 2.0,
})

local function ranges_intersect(a_min, a_max, b_min, b_max)
	return a_max >= b_min and b_max >= a_min
end

local function generate_universal_floor(vm, data, area, minp, maxp, zone_type)
	if not generate_floor then return end
	init_content_ids()
	
	local floor_min_y = math.max(minp.y, -20)
	local floor_max_y = math.min(maxp.y, 0)
	if floor_min_y > floor_max_y then return end
	
	local c_surface = (zone_type == "city") and c_uliza_ground or c_grass
	
	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			local noise_val = floor_noise:get_3d({x = x, y = 0, z = z})
			for y = floor_min_y, floor_max_y do
				local vi = area:index(x, y, z)
				if data[vi] == c_air then
					if y == 0 then
						data[vi] = c_surface
					elseif y >= -5 then
						data[vi] = noise_val > 0.3 and c_dirt or c_stone
					else
						data[vi] = noise_val > 0.6 and c_dirt or c_stone
					end
				end
			end
		end
	end
end

minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map(minp, maxp)
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()
	local param2_data = vm:get_param2_data()
	local deferred = {}
	
	-- Check if ANY overlapping zone disables floor generation
	local skip_floor = false
	temz_zones.for_each_zone_overlapping(minp, maxp, function(zx, zz, zone_min, zone_max)
		local zone_type = temz_zones.get_zone_type(zx, zz)
		if zone_type == "labyrinth" or zone_type == "factory" then
			skip_floor = true
		end
	end)
	
	temz_zones.for_each_zone_overlapping(minp, maxp, function(zx, zz, zone_min, zone_max)
		local zone_type = temz_zones.get_zone_type(zx, zz)
		
		-- Only generate floor if no special zones in this chunk
		if generate_floor and not skip_floor then
			generate_universal_floor(vm, data, area, minp, maxp, zone_type)
		end
		
		if zone_type == "spawn_plain" then return end
		
		local generator = temz_zones.generators[zone_type]
		if not generator then return end
		
		if not ranges_intersect(minp.y, maxp.y, generator.y_min, generator.y_max) then
			return
		end
		
		local ctx = {
			vm = vm, data = data, param2 = param2_data, area = area,
			chunk_minp = minp, chunk_maxp = maxp,
			sub_minp = {
				x = math.max(minp.x, zone_min.x),
				y = math.max(minp.y, generator.y_min),
				z = math.max(minp.z, zone_min.z),
			},
			sub_maxp = {
				x = math.min(maxp.x, zone_max.x),
				y = math.min(maxp.y, generator.y_max),
				z = math.min(maxp.z, zone_max.z),
			},
			zone_minp = zone_min, zone_maxp = zone_max,
			zx = zx, zz = zz,
			prng = PcgRandom((zx * 0x1234567) + (zz * 0x7654321) + blockseed),
			deferred = deferred,
			defer = function(fn) table.insert(deferred, fn) end,
		}
		
		pcall(generator.generate, ctx)
	end)
	
	-- Check if any zone in this chunk disables decorations
	local has_no_decorations = false
	temz_zones.for_each_zone_overlapping(minp, maxp, function(zx, zz, zone_min, zone_max)
		local zone_type = temz_zones.get_zone_type(zx, zz)
		if zone_type == "labyrinth" or zone_type == "factory" then
			has_no_decorations = true
		end
	end)
	
	-- Only generate decorations/ores if not in special zones (BEFORE setting data!)
	if not has_no_decorations then
		minetest.generate_decorations(vm, minp, maxp)
		minetest.generate_ores(vm, minp, maxp)
	else
		minetest.log("action", "[dumbgen2] Skipping decorations for special zone at " .. minetest.pos_to_string(minp))
	end
	
	vm:set_data(data)
	vm:set_param2_data(param2_data)
	vm:calc_lighting(minp, maxp)
	vm:update_liquids()
	vm:write_to_map()
	
	if #deferred > 0 then
		minetest.after(0.1, function()
			for _, fn in ipairs(deferred) do pcall(fn) end
		end)
	end
end)

minetest.log("action", "[dumbgen2] Generation orchestrator initialized")
