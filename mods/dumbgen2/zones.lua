-- Zone management system for Temnaya Zashelina
-- Divides the world into 501x501 node squares with different zone types

temz_zones = {}

-- Constants
temz_zones.ZONE_SIZE = 501
temz_zones.HALF = 250  -- (501-1)/2
temz_zones.SPAWN_ZONE = {x = 0, z = 0}

-- Zone type registry
temz_zones.generators = {}

-- In-memory cache for zone assignments
local zone_cache = {}

-- Get world seed for deterministic RNG
local world_seed = tonumber(minetest.get_mapgen_setting("seed"))

-- Parse zone weights from settings
local function parse_zone_weights()
	local weights_str = minetest.settings:get("temz.zone_weights") or "city:1,labyrinth:1,factory:1"
	local weights = {}
	local total = 0
	
	for entry in string.gmatch(weights_str, "[^,]+") do
		local zone_type, weight = string.match(entry, "([^:]+):(%d+%.?%d*)")
		if zone_type and weight then
			weight = tonumber(weight) or 1
			weights[zone_type] = weight
			total = total + weight
		end
	end
	
	return weights, total
end

local zone_weights, total_weight = parse_zone_weights()

-- Hash function for zone coordinates (Lua 5.1 compatible)
local function hash_zone_coords(zx, zz)
	-- Simple but effective hash mixing
	local h = world_seed
	h = ((h + zx * 2654435761) % 2147483647)
	h = ((h + zz * 2246822519) % 2147483647)
	h = ((h * 16807) % 2147483647)
	return h
end

-- Get deterministic random number for a zone
local function get_zone_rng(zx, zz)
	local seed = hash_zone_coords(zx, zz)
	local rng = PcgRandom(seed)
	return rng
end

-- Convert world coordinates to zone coordinates
function temz_zones.world_to_zone(x, z)
	local zx = math.floor((x + temz_zones.HALF) / temz_zones.ZONE_SIZE)
	local zz = math.floor((z + temz_zones.HALF) / temz_zones.ZONE_SIZE)
	return zx, zz
end

-- Get world bounds for a zone
function temz_zones.get_zone_bounds(zx, zz)
	local min_x = zx * temz_zones.ZONE_SIZE - temz_zones.HALF
	local max_x = zx * temz_zones.ZONE_SIZE + temz_zones.HALF
	local min_z = zz * temz_zones.ZONE_SIZE - temz_zones.HALF
	local max_z = zz * temz_zones.ZONE_SIZE + temz_zones.HALF
	
	return {x = min_x, z = min_z}, {x = max_x, z = max_z}
end

-- Assign a zone type deterministically
local function assign_zone_type(zx, zz)
	-- Spawn zone is always plain
	if zx == temz_zones.SPAWN_ZONE.x and zz == temz_zones.SPAWN_ZONE.z then
		return "spawn_plain"
	end
	
	-- Use deterministic RNG for this zone
	local rng = get_zone_rng(zx, zz)
	local roll = rng:next(0, 10000) / 10000.0 * total_weight
	
	-- Select zone type based on weights
	local accumulated = 0
	for zone_type, weight in pairs(zone_weights) do
		accumulated = accumulated + weight
		if roll < accumulated then
			return zone_type
		end
	end
	
	-- Fallback to first available type
	return next(zone_weights) or "spawn_plain"
end

-- Get zone type with caching
function temz_zones.get_zone_type(zx, zz)
	-- Create cache key
	local key = (zx * 1000000) + zz  -- Simple key for small coordinates
	
	-- Check cache
	if zone_cache[key] then
		return zone_cache[key]
	end
	
	-- Assign and cache
	local zone_type = assign_zone_type(zx, zz)
	zone_cache[key] = zone_type
	
	-- TODO: Optional persistence with ModStorage
	
	return zone_type
end

-- Iterate over all zones overlapping a given area
function temz_zones.for_each_zone_overlapping(minp, maxp, callback)
	-- Convert corners to zone coordinates
	local min_zx, min_zz = temz_zones.world_to_zone(minp.x, minp.z)
	local max_zx, max_zz = temz_zones.world_to_zone(maxp.x, maxp.z)
	
	-- Iterate over all overlapping zones
	for zx = min_zx, max_zx do
		for zz = min_zz, max_zz do
			local zone_min, zone_max = temz_zones.get_zone_bounds(zx, zz)
			callback(zx, zz, zone_min, zone_max)
		end
	end
end

-- Register a zone generator
function temz_zones.register_generator(name, def)
	if not def or not def.generate then
		error("[temz_zones] Generator " .. name .. " must have a generate function")
	end
	
	temz_zones.generators[name] = {
		y_min = def.y_min or -31000,
		y_max = def.y_max or 31000,
		generate = def.generate,
	}
	
	minetest.log("action", "[temz_zones] Registered generator: " .. name)
end

-- Debug: Get zone info at player position
minetest.register_chatcommand("temz_zone_here", {
	description = "Show zone information at your position",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		
		local pos = player:get_pos()
		local zx, zz = temz_zones.world_to_zone(pos.x, pos.z)
		local zone_type = temz_zones.get_zone_type(zx, zz)
		local zone_min, zone_max = temz_zones.get_zone_bounds(zx, zz)
		
		return true, string.format("Zone (%d, %d): type=%s, bounds=(%d,%d) to (%d,%d)",
			zx, zz, zone_type, zone_min.x, zone_min.z, zone_max.x, zone_max.z)
	end,
})

-- Debug: Teleport to zone center
minetest.register_chatcommand("temz_tp_zone", {
	params = "<zx> <zz>",
	description = "Teleport to the center of a zone",
	privs = {teleport = true},
	func = function(name, param)
		local zx, zz = param:match("^(%S+)%s+(%S+)$")
		zx = tonumber(zx)
		zz = tonumber(zz)
		
		if not zx or not zz then
			return false, "Usage: /temz_tp_zone <zx> <zz>"
		end
		
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		
		local zone_type = temz_zones.get_zone_type(zx, zz)
		local center_x = zx * temz_zones.ZONE_SIZE
		local center_z = zz * temz_zones.ZONE_SIZE
		
		player:set_pos({x = center_x, y = 5, z = center_z})
		return true, string.format("Teleported to zone (%d, %d) [%s]", zx, zz, zone_type)
	end,
})

minetest.log("action", "[temz_zones] Zone management system initialized")
