-- Labyrinth generation: rooms, corridors, maze layout (hash-based)

labyrinth.generation = {}

-- Content IDs (lazy loaded)
local c_air, c_floor_beton, c_floor_bricks, c_transparent_beton, c_door, c_ghost_trigger

local function init_content_ids()
	if c_air then return end
	c_air = minetest.get_content_id("air")
	c_floor_beton = minetest.get_content_id("constructions:beton")
	c_floor_bricks = minetest.get_content_id("constructions:white_bricks2")
	c_transparent_beton = minetest.get_content_id("constructions:transparent_beton")
	c_door = minetest.get_content_id("labyrinth:slide_door_closed")
	c_ghost_trigger = minetest.get_content_id("labyrinth:ghost_trigger")
end

-- Maze generation constants
local ROOM_SIZE_MIN = 3   -- Minimum room size
local ROOM_SIZE_MAX = 18  -- Maximum room size
local CELL_SIZE = ROOM_SIZE_MAX  -- Grid cell size (use max room size)
local CORRIDOR_WIDTH = 6  -- Width of corridors between rooms (narrower)
local ROOM_HEIGHT = 6  -- Height of rooms (Y=1 to Y=7)
local CORRIDOR_HEIGHT = 2  -- Height of corridors (lower ceiling)
local WALL_THICKNESS = 1
local DOORFRAME_HEIGHT = 3  -- Height of doorframes

-- Hash function for deterministic random values
local function hash_pos(x, z, seed)
	local h = seed
	h = (h + x * 374761393) % 2147483647
	h = (h + z * 668265263) % 2147483647
	h = (h * 1664525 + 1013904223) % 2147483647
	return h
end

-- Get room size for a grid cell (deterministic based on position)
local function get_room_size(grid_x, grid_z, seed)
	local h = hash_pos(grid_x, grid_z, seed + 54321)
	return ROOM_SIZE_MIN + (h % (ROOM_SIZE_MAX - ROOM_SIZE_MIN + 1))
end

-- Check if there should be a corridor opening in a direction
local function has_corridor(grid_x, grid_z, direction, seed)
	local h = hash_pos(grid_x * 4 + direction, grid_z, seed + 12345)
	return (h % 100) < 95  -- 95% chance of corridor (very passable, almost all doors open)
end

-- Check if there should be a ghost trigger at this position
local function should_place_ghost(x, z, seed)
	local h = hash_pos(x, z, seed + 99999)
	return (h % 100) < 15  -- 15% chance of ghost trigger
end

-- Main generation function (hash-based, non-iterative)
function labyrinth.generation.generate(ctx)
	init_content_ids()
	
	local zone_seed = ctx.zx * 374761393 + ctx.zz * 668265263
	local base_y = 1  -- Floor at Y=0, rooms from Y=1 to Y=7
	local ceiling_y = base_y + ROOM_HEIGHT + 1
	local cell_total = CELL_SIZE + CORRIDOR_WIDTH  -- Total space per grid cell
	
	-- First pass: Clear any existing ground/decorations from Y=-20 to ceiling
	local cleared_count = 0
	local had_grass = 0
	local c_stone = minetest.get_content_id("default:stone")
	for y = -20, ceiling_y do
		if y >= ctx.sub_minp.y and y <= ctx.sub_maxp.y then
			for z = ctx.sub_minp.z, ctx.sub_maxp.z do
				for x = ctx.sub_minp.x, ctx.sub_maxp.x do
					local vi = ctx.area:index(x, y, z)
					if y == 0 and ctx.data[vi] ~= c_air then
						had_grass = had_grass + 1
					end
					-- Fill below Y=0 with stone, clear above
					if y < 0 then
						ctx.data[vi] = c_stone
					else
						ctx.data[vi] = c_air
					end
					cleared_count = cleared_count + 1
				end
			end
		end
	end
	minetest.log("action", string.format("[labyrinth] Cleared %d voxels, %d had non-air at Y=0", cleared_count, had_grass))
	
	-- Generate voxel by voxel
	for z = ctx.sub_minp.z, ctx.sub_maxp.z do
		for x = ctx.sub_minp.x, ctx.sub_maxp.x do
			-- Convert world position to grid cell
			local rel_x = x - ctx.zone_minp.x
			local rel_z = z - ctx.zone_minp.z
			local grid_x = math.floor(rel_x / cell_total)
			local grid_z = math.floor(rel_z / cell_total)
			
			-- Position within the grid cell
			local in_cell_x = rel_x % cell_total
			local in_cell_z = rel_z % cell_total
			
			-- Get this cell's room size
			local room_size = get_room_size(grid_x, grid_z, zone_seed)
			
			-- Determine if we're in a room or corridor
			local in_room = (in_cell_x < room_size and in_cell_z < room_size)
			local in_corridor_x = (in_cell_x >= room_size)  -- East corridor
			local in_corridor_z = (in_cell_z >= room_size)  -- South corridor
			
			-- Check if corridors should exist (deterministic)
			local has_east_corridor = has_corridor(grid_x, grid_z, 0, zone_seed)
			local has_south_corridor = has_corridor(grid_x, grid_z, 1, zone_seed)
			
			-- Determine if this voxel is wall or air
			local is_wall = false
			local is_doorframe = false
			local is_door_center = false
			local door_facing = 0  -- facedir: 0=+z, 1=+x, 2=-z, 3=-x
			
			if in_room then
				-- Room walls (1 block thick on each edge)
				if in_cell_x == 0 or in_cell_z == 0 or 
				   in_cell_x == room_size - 1 or in_cell_z == room_size - 1 then
					is_wall = true
					
					-- Check for doorframe (where room meets corridor) - 1 block wide on all 4 sides!
					local door_center = math.floor(room_size / 2)
					-- Check west side (connects to previous room's east corridor)
					local has_west_corridor = has_corridor(grid_x - 1, grid_z, 0, zone_seed)
					-- Check north side (connects to previous room's south corridor)
					local has_north_corridor = has_corridor(grid_x, grid_z - 1, 1, zone_seed)
					
					if in_cell_x == room_size - 1 and has_east_corridor then
						-- East doorframe (door faces +X direction)
						if in_cell_z == door_center then
							is_doorframe = true
							is_door_center = true
							door_facing = 1  -- +X
						end
					elseif in_cell_z == room_size - 1 and has_south_corridor then
						-- South doorframe (door faces +Z direction)
						if in_cell_x == door_center then
							is_doorframe = true
							is_door_center = true
							door_facing = 0  -- +Z
						end
					elseif in_cell_x == 0 and has_west_corridor then
						-- West doorframe (door faces -X direction)
						if in_cell_z == door_center then
							is_doorframe = true
							is_door_center = true
							door_facing = 3  -- -X
						end
					elseif in_cell_z == 0 and has_north_corridor then
						-- North doorframe (door faces -Z direction)
						if in_cell_x == door_center then
							is_doorframe = true
							is_door_center = true
							door_facing = 2  -- -Z
						end
					end
				end
			elseif in_corridor_x and not in_corridor_z then
				-- East-west corridor
				if not has_east_corridor then
					is_wall = true
				else
					-- Corridor walls on sides (narrower corridors)
					local corridor_start = math.floor((room_size - CORRIDOR_WIDTH) / 2)
					if in_cell_z < corridor_start or in_cell_z >= corridor_start + CORRIDOR_WIDTH then
						is_wall = true
					end
				end
			elseif in_corridor_z and not in_corridor_x then
				-- North-south corridor
				if not has_south_corridor then
					is_wall = true
				else
					-- Corridor walls on sides (narrower corridors)
					local corridor_start = math.floor((room_size - CORRIDOR_WIDTH) / 2)
					if in_cell_x < corridor_start or in_cell_x >= corridor_start + CORRIDOR_WIDTH then
						is_wall = true
					end
				end
			else
				-- Corner/intersection - fill with wall
				is_wall = true
			end
			
			-- Determine max height for this location
			local max_height
			if in_room then
				max_height = base_y + ROOM_HEIGHT
			else
				max_height = base_y + CORRIDOR_HEIGHT  -- Lower ceiling for corridors
			end
			
			-- Generate vertically
			for y = ctx.sub_minp.y, ctx.sub_maxp.y do
				local vi = ctx.area:index(x, y, z)
				
				if y == 0 then
					-- Floor - use beton and bricks
					if (x + z) % 2 == 0 then
						ctx.data[vi] = c_floor_beton
					else
						ctx.data[vi] = c_floor_bricks
					end
				elseif (in_room and y == ceiling_y) or (not in_room and y == base_y + CORRIDOR_HEIGHT + 1) then
					-- Ceiling - different heights for rooms vs corridors
					ctx.data[vi] = c_transparent_beton
				elseif y >= base_y and y <= max_height then
					-- Room/corridor height
					if is_door_center and y == base_y then
						-- Door bottom (only the base has the handle node)
						ctx.data[vi] = c_door
						-- Set door rotation (facedir)
						ctx.param2[vi] = door_facing
					elseif is_doorframe and (y == base_y or y == base_y + 1) then
						-- Doorframe opening (2 blocks tall, air)
						ctx.data[vi] = c_air
					elseif is_doorframe and y <= base_y + DOORFRAME_HEIGHT then
						-- Doorframe top with transparent beton (emits light)
						ctx.data[vi] = c_transparent_beton
					elseif is_wall then
						-- All walls are transparent beton
						ctx.data[vi] = c_transparent_beton
					else
						ctx.data[vi] = c_air
						-- Place ghost triggers near walls (at player eye level, Y=base_y+1)
						if y == base_y + 1 and should_place_ghost(x, z, zone_seed) then
							-- Check if adjacent to a wall
							local has_adjacent_wall = false
							for _, offset in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
								local check_x = x + offset[1]
								local check_z = z + offset[2]
								local check_vi = ctx.area:index(check_x, y, check_z)
								if ctx.data[check_vi] == c_transparent_beton then
									has_adjacent_wall = true
									break
								end
							end
							if has_adjacent_wall then
								ctx.data[vi] = c_ghost_trigger
							end
						end
					end
				end
			end
		end
	end
	
	minetest.log("action", "[labyrinth] Generated hash-based maze at zone (" .. ctx.zx .. ", " .. ctx.zz .. ")")
end

-- Register the generator with the zone system
if temz_zones and temz_zones.register_generator then
	temz_zones.register_generator("labyrinth", {
		y_min = -20,
		y_max = 20,
		generate = labyrinth.generation.generate,
	})
	minetest.log("action", "[labyrinth] Generator registered with zone system!")
else
	minetest.log("error", "[labyrinth] Failed to register - temz_zones not available! temz_zones=" .. tostring(temz_zones))
end

minetest.log("action", "[labyrinth] Generation module loaded")
