-- Factory generation: tall structures, corridors, chess floors, pipes

factory.generation = {}

-- Content IDs (lazy loaded)
local c_air, c_beton, c_wb_tile, c_bw_tile, c_pipe, c_pipe_valve, c_ladder
local c_door_t1, c_door_t2, c_door_t3, c_transparent_beton
local c_exterior_wall, c_entrance_door, c_fence

local function init_content_ids()
	if c_air then return end
	c_air = minetest.get_content_id("air")
	c_beton = minetest.get_content_id("constructions:beton")
	c_wb_tile = minetest.get_content_id("constructions:wb_tile1")
	c_bw_tile = minetest.get_content_id("constructions:bw_tile1")
	c_pipe = minetest.get_content_id("factory:pipe")
	c_pipe_valve = minetest.get_content_id("factory:pipe_valve")
	c_ladder = minetest.get_content_id("default:ladder")
	c_door_t1 = minetest.get_content_id("factory:door_t1_closed")
	c_door_t2 = minetest.get_content_id("factory:door_t2_closed")
	c_door_t3 = minetest.get_content_id("factory:door_t3_closed")
	c_transparent_beton = minetest.get_content_id("constructions:transparent_beton")
	c_exterior_wall = minetest.get_content_id("factory:exterior_wall")
	c_entrance_door = minetest.get_content_id("factory:entrance_door")
	c_fence = minetest.get_content_id("factory:fence")
end

-- Factory generation constants
local FLOOR_SPACING = 8  -- Nodes between floors
local FLOOR_COUNT = 13  -- Number of floors (Y=-16 to Y=88)
local CORRIDOR_WIDTH = 6  -- Width of corridors
local ROOM_MODULE_SIZE = 12  -- Size of room modules
local WALL_THICKNESS = 1
local INSET_MARGIN = 10  -- Margin from zone edge
local FENCE_MARGIN = 5  -- Fence outside building
local CENTRAL_SHAFT_SIZE = 10  -- Central shaft dimensions
local CORNER_SHAFT_SIZE = 5  -- Corner shaft dimensions
local BUILDING_HEIGHT = 88  -- Top of building

-- Hash function for deterministic random values
local function hash_pos(x, y, z, seed)
	local h = seed
	h = (h + x * 374761393) % 2147483647
	h = (h + y * 668265263) % 2147483647
	h = (h + z * 1664525) % 2147483647
	h = (h * 1013904223 + 1) % 2147483647
	return h
end

-- Check if position is in central shaft
local function is_in_central_shaft(rel_x, rel_z, zone_size)
	local center = math.floor(zone_size / 2)
	local shaft_half = math.floor(CENTRAL_SHAFT_SIZE / 2)
	return rel_x >= center - shaft_half and rel_x < center + shaft_half and
	       rel_z >= center - shaft_half and rel_z < center + shaft_half
end

-- Check if position is in a corner shaft
local function is_in_corner_shaft(rel_x, rel_z, zone_size)
	local margin = INSET_MARGIN + 5
	local max_coord = zone_size - margin - CORNER_SHAFT_SIZE
	
	-- Four corners
	if (rel_x >= margin and rel_x < margin + CORNER_SHAFT_SIZE and
	    rel_z >= margin and rel_z < margin + CORNER_SHAFT_SIZE) then
		return true  -- NW corner
	end
	if (rel_x >= max_coord and rel_x < max_coord + CORNER_SHAFT_SIZE and
	    rel_z >= margin and rel_z < margin + CORNER_SHAFT_SIZE) then
		return true  -- NE corner
	end
	if (rel_x >= margin and rel_x < margin + CORNER_SHAFT_SIZE and
	    rel_z >= max_coord and rel_z < max_coord + CORNER_SHAFT_SIZE) then
		return true  -- SW corner
	end
	if (rel_x >= max_coord and rel_x < max_coord + CORNER_SHAFT_SIZE and
	    rel_z >= max_coord and rel_z < max_coord + CORNER_SHAFT_SIZE) then
		return true  -- SE corner
	end
	return false
end

-- Get door tier based on floor level
local function get_door_tier(floor_index)
	if floor_index <= 4 then  -- Floors 0-32
		return 1
	elseif floor_index <= 8 then  -- Floors 32-64
		return 2
	else  -- Floors 64+
		return 3
	end
end

-- Check if position should have a door
local function should_place_door(rel_x, rel_z, floor_index, seed)
	local h = hash_pos(rel_x, floor_index, rel_z, seed + 77777)
	-- More doors on lower floors, fewer on higher floors
	local chance = 10 - math.floor(floor_index / 2)  -- 10% to 3%
	if chance < 3 then chance = 3 end
	return (h % 100) < chance
end

-- Check if position is on corridor grid
local function is_corridor(rel_x, rel_z)
	local grid_x = rel_x % (ROOM_MODULE_SIZE + CORRIDOR_WIDTH)
	local grid_z = rel_z % (ROOM_MODULE_SIZE + CORRIDOR_WIDTH)
	return grid_x >= ROOM_MODULE_SIZE or grid_z >= ROOM_MODULE_SIZE
end

-- Check if position is on building perimeter (exterior wall)
local function is_exterior_wall(rel_x, rel_z, zone_size)
	return rel_x == INSET_MARGIN or rel_x == zone_size - INSET_MARGIN - 1 or
	       rel_z == INSET_MARGIN or rel_z == zone_size - INSET_MARGIN - 1
end

-- Check if position should have an entrance (4 entrances on cardinal sides)
local function is_entrance(rel_x, rel_z, zone_size)
	local center = math.floor(zone_size / 2)
	local entrance_width = 6  -- 3 nodes on each side of center
	
	-- North entrance (Z=INSET_MARGIN)
	if rel_z == INSET_MARGIN and rel_x >= center - entrance_width and rel_x <= center + entrance_width then
		return true, 2  -- Facing south
	end
	-- South entrance
	if rel_z == zone_size - INSET_MARGIN - 1 and rel_x >= center - entrance_width and rel_x <= center + entrance_width then
		return true, 0  -- Facing north
	end
	-- West entrance
	if rel_x == INSET_MARGIN and rel_z >= center - entrance_width and rel_z <= center + entrance_width then
		return true, 1  -- Facing east
	end
	-- East entrance
	if rel_x == zone_size - INSET_MARGIN - 1 and rel_z >= center - entrance_width and rel_z <= center + entrance_width then
		return true, 3  -- Facing west
	end
	
	return false, 0
end

-- Check if position is a wall (perimeter or room boundary)
local function is_wall(rel_x, rel_z, zone_size)
	-- Perimeter walls (but not exterior wall)
	if rel_x < INSET_MARGIN or rel_x >= zone_size - INSET_MARGIN or
	   rel_z < INSET_MARGIN or rel_z >= zone_size - INSET_MARGIN then
		return true
	end
	
	-- Room module boundaries (where corridors meet rooms)
	local grid_x = rel_x % (ROOM_MODULE_SIZE + CORRIDOR_WIDTH)
	local grid_z = rel_z % (ROOM_MODULE_SIZE + CORRIDOR_WIDTH)
	
	-- Wall at room edges adjacent to corridors
	if grid_x == ROOM_MODULE_SIZE - 1 or grid_x == 0 or
	   grid_z == ROOM_MODULE_SIZE - 1 or grid_z == 0 then
		if not is_corridor(rel_x, rel_z) then
			return true
		end
	end
	
	return false
end

-- Check if position is in fence perimeter
local function is_fence(rel_x, rel_z, zone_size)
	local fence_outer = FENCE_MARGIN
	return (rel_x == fence_outer or rel_x == zone_size - fence_outer - 1 or
	        rel_z == fence_outer or rel_z == zone_size - fence_outer - 1) and
	       not (rel_x < INSET_MARGIN - 5 or rel_x >= zone_size - INSET_MARGIN + 5 or
	            rel_z < INSET_MARGIN - 5 or rel_z >= zone_size - INSET_MARGIN + 5)
end

-- Main generation function
function factory.generation.generate(ctx)
	init_content_ids()
	
	local zone_seed = ctx.zx * 374761393 + ctx.zz * 668265263
	local zone_size = 501
	local c_stone = minetest.get_content_id("default:stone")
	
	-- Clear and fill foundation
	minetest.log("action", "[factory] Clearing zone and building foundation...")
	for y = -20, 100 do
		if y >= ctx.sub_minp.y and y <= ctx.sub_maxp.y then
			for z = ctx.sub_minp.z, ctx.sub_maxp.z do
				for x = ctx.sub_minp.x, ctx.sub_maxp.x do
					local vi = ctx.area:index(x, y, z)
					if y < 0 then
						ctx.data[vi] = c_stone
					else
						ctx.data[vi] = c_air
					end
				end
			end
		end
	end
	
	-- Build exterior walls and fence
	minetest.log("action", "[factory] Building exterior walls and fence...")
	for z = ctx.sub_minp.z, ctx.sub_maxp.z do
		for x = ctx.sub_minp.x, ctx.sub_maxp.x do
			local rel_x = x - ctx.zone_minp.x
			local rel_z = z - ctx.zone_minp.z
			
			local is_ext_wall = is_exterior_wall(rel_x, rel_z, zone_size)
			local is_ent, ent_facing = is_entrance(rel_x, rel_z, zone_size)
			local is_fnc = is_fence(rel_x, rel_z, zone_size)
			
			-- Exterior wall (from ground to top of building)
			if is_ext_wall then
				for y = 1, BUILDING_HEIGHT do
					if y >= ctx.sub_minp.y and y <= ctx.sub_maxp.y then
						local vi = ctx.area:index(x, y, z)
						if is_ent and y >= 1 and y <= 3 then
							-- Entrance opening (3 blocks tall)
							if y == 1 then
								-- Door frame at bottom
								ctx.data[vi] = c_entrance_door
								ctx.param2[vi] = ent_facing
							else
								-- Open above
								ctx.data[vi] = c_air
							end
						else
							-- Solid exterior wall
							ctx.data[vi] = c_exterior_wall
						end
					end
				end
			end
			
			-- Fence perimeter
			if is_fnc then
				for y = 1, 2 do  -- 2 blocks tall fence
					if y >= ctx.sub_minp.y and y <= ctx.sub_maxp.y then
						local vi = ctx.area:index(x, y, z)
						ctx.data[vi] = c_fence
					end
				end
			end
		end
	end
	
	-- Generate floor by floor
	minetest.log("action", "[factory] Generating " .. FLOOR_COUNT .. " floors...")
	for floor_idx = 0, FLOOR_COUNT - 1 do
		local floor_y = -16 + floor_idx * FLOOR_SPACING
		local ceiling_y = floor_y + FLOOR_SPACING - 1
		
		if floor_y <= ctx.sub_maxp.y and ceiling_y >= ctx.sub_minp.y then
			for z = ctx.sub_minp.z, ctx.sub_maxp.z do
				for x = ctx.sub_minp.x, ctx.sub_maxp.x do
					local rel_x = x - ctx.zone_minp.x
					local rel_z = z - ctx.zone_minp.z
					
					-- Check if in a shaft
					local in_central_shaft = is_in_central_shaft(rel_x, rel_z, zone_size)
					local in_corner_shaft = is_in_corner_shaft(rel_x, rel_z, zone_size)
					local in_any_shaft = in_central_shaft or in_corner_shaft
					
					-- Determine structure for this position
					local in_wall = is_wall(rel_x, rel_z, zone_size)
					local in_corridor = is_corridor(rel_x, rel_z)
					
					-- Generate vertically for this floor
					for y = floor_y, ceiling_y do
						if y >= ctx.sub_minp.y and y <= ctx.sub_maxp.y then
							local vi = ctx.area:index(x, y, z)
							
							if y == floor_y then
								-- Floor level
								if in_any_shaft then
									-- Shaft: open with ladder on one wall
									if in_central_shaft then
										local shaft_center = math.floor(zone_size / 2)
										if rel_x == shaft_center - 3 then  -- West wall of shaft
											ctx.data[vi] = c_ladder
											ctx.param2[vi] = 4  -- Facing east
										else
											ctx.data[vi] = c_air
										end
									else
										ctx.data[vi] = c_air
									end
								else
									-- Regular floor with chess pattern
									if (rel_x + rel_z) % 2 == 0 then
										ctx.data[vi] = c_wb_tile
									else
										ctx.data[vi] = c_bw_tile
									end
								end
							elseif y == ceiling_y then
								-- Ceiling level
								if in_any_shaft then
									-- Open shaft
									ctx.data[vi] = c_air
								else
									-- Solid ceiling
									ctx.data[vi] = c_beton
								end
							else
								-- Between floor and ceiling
								if in_any_shaft then
									-- Shaft interior
									if in_central_shaft then
										local shaft_center = math.floor(zone_size / 2)
										-- Pipes in center of shaft
										if rel_x >= shaft_center - 1 and rel_x < shaft_center + 1 and
										   rel_z >= shaft_center - 1 and rel_z < shaft_center + 1 then
											if (y - floor_y) % 3 == 0 then
												ctx.data[vi] = c_pipe_valve
											else
												ctx.data[vi] = c_pipe
											end
										else
											-- Ladder on wall
											if rel_x == shaft_center - 3 then
												ctx.data[vi] = c_ladder
												ctx.param2[vi] = 4
											else
												ctx.data[vi] = c_air
											end
										end
									else
										-- Corner shafts - simpler, just air
										ctx.data[vi] = c_air
									end
								elseif in_wall then
									-- Walls
									if y == floor_y + 1 and should_place_door(rel_x, rel_z, floor_idx, zone_seed) then
										-- Place door based on tier
										local tier = get_door_tier(floor_idx)
										if tier == 1 then
											ctx.data[vi] = c_door_t1
										elseif tier == 2 then
											ctx.data[vi] = c_door_t2
										else
											ctx.data[vi] = c_door_t3
										end
										-- Set door facing based on position
										local grid_x = rel_x % (ROOM_MODULE_SIZE + CORRIDOR_WIDTH)
										if grid_x < 2 then
											ctx.param2[vi] = 3  -- Facing west
										else
											ctx.param2[vi] = 1  -- Facing east
										end
									else
										ctx.data[vi] = c_beton
									end
								elseif in_corridor then
									-- Corridors - occasionally place pipes
									local h = hash_pos(rel_x, y, rel_z, zone_seed)
									if y == floor_y + FLOOR_SPACING - 2 and (h % 100) < 20 then
										-- Pipes near ceiling in corridors
										ctx.data[vi] = c_pipe
									else
										ctx.data[vi] = c_air
									end
								else
									-- Room interiors
									ctx.data[vi] = c_air
								end
							end
						end
					end
				end
			end
		end
	end
	
	-- TODO: Defer chest placement with key fragments to deferred queue
	
	minetest.log("action", "[factory] Generated multi-floor factory at zone (" .. ctx.zx .. ", " .. ctx.zz .. ")")
end

-- Register the generator with the zone system (once dumbgen2 provides the API)
if temz_zones and temz_zones.register_generator then
	temz_zones.register_generator("factory", {
		y_min = -20,
		y_max = 100,
		generate = factory.generation.generate,
	})
end

minetest.log("action", "[factory] Generation module loaded")
