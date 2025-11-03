-- USSR Microdistrict City Generation - Phase 1: Exterior focus with cuboid buildings
-- Simple, clean implementation focusing on paths, recreation zones, and building placement

local city = {}

-- Content IDs (lazy loaded)
local c_air, c_stone, c_ground, c_asphalt, c_sidewalk, c_lamp
local c_beton, c_bricks, c_glass, c_sand
local c_tree

local function init_content_ids()
	if c_air then return end
	c_air = minetest.get_content_id("air")
	c_stone = minetest.get_content_id("default:stone")
	c_ground = minetest.get_content_id("uliza:ground")
	c_asphalt = minetest.get_content_id("uliza:asphalt")
	c_sidewalk = minetest.get_content_id("uliza:sidewalk")
	c_lamp = minetest.get_content_id("uliza:street_lamp")
	c_beton = minetest.get_content_id("constructions:beton")
	c_bricks = minetest.get_content_id("constructions:white_bricks2")
	c_glass = minetest.get_content_id("uliza:framed_glass")
	c_sand = minetest.get_content_id("default:sand")
	c_tree = minetest.get_content_id("uliza:tree1")
end

-- Microdistrict layout constants
local BLOCK_SIZE = 60           -- Microdistrict block size
local PATH_WIDTH = 4            -- Pedestrian path width
local BUILDING_WIDTH = 12       -- Panel building width
local BUILDING_DEPTH = 40       -- Panel building length  
local BUILDING_HEIGHT_5 = 20    -- 5-story building
local BUILDING_HEIGHT_9 = 36    -- 9-story building
local LAMP_SPACING = 16         -- Distance between lamps
local LAMP_HEIGHT = 5           -- Lamp post height

-- Probabilities
local ROAD_PROBABILITY = 20     -- % of paths that are asphalt roads
local RECREATION_PROBABILITY = 25  -- % of blocks that are recreation zones
local TREE_DENSITY = 3          -- % in recreation zones (sparse!)
local PLAYGROUND_DENSITY = 8    -- % in recreation zones (make visible)

-- Hash function for deterministic randomness
local function hash_pos(x, z, seed)
	local h = seed
	h = (h + x * 374761393) % 2147483647
	h = (h + z * 668265263) % 2147483647
	h = (h * 1664525 + 1013904223) % 2147483647
	return h
end

-- Check if this block should have asphalt road
local function has_asphalt_road(block_x, block_z, direction, seed)
	local h = hash_pos(block_x * 3 + direction, block_z * 5, seed + 11111)
	return (h % 100) < ROAD_PROBABILITY
end

-- Check if block should be recreation zone
local function is_recreation(block_x, block_z, seed)
	local h = hash_pos(block_x * 7, block_z * 11, seed + 55555)
	return (h % 100) < RECREATION_PROBABILITY
end

-- Get building orientation (0=N-S, 1=E-W)
local function get_building_orientation(block_x, block_z, seed)
	local h = hash_pos(block_x, block_z, seed + 22222)
	return h % 2
end

-- Get building height
local function get_building_height(block_x, block_z, seed)
	local h = hash_pos(block_x, block_z, seed + 33333)
	return (h % 2 == 0) and BUILDING_HEIGHT_5 or BUILDING_HEIGHT_9
end

-- Main generation function
function city.generate(ctx)
	init_content_ids()
	
	local zone_seed = ctx.zx * 374761393 + ctx.zz * 668265263
	local ground_y = 0
	
	-- Pass 1: Terrain base (fill underground, place ground, clear air)
	for y = -20, 50 do
		if y >= ctx.sub_minp.y and y <= ctx.sub_maxp.y then
			for z = ctx.sub_minp.z, ctx.sub_maxp.z do
				for x = ctx.sub_minp.x, ctx.sub_maxp.x do
					local vi = ctx.area:index(x, y, z)
					if y < 0 then
						ctx.data[vi] = c_stone
					elseif y == 0 then
						ctx.data[vi] = c_ground
					else
						ctx.data[vi] = c_air
					end
				end
			end
		end
	end
	
	-- Pass 2: Infrastructure (paths, roads, lamps)
	for z = ctx.sub_minp.z, ctx.sub_maxp.z do
		for x = ctx.sub_minp.x, ctx.sub_maxp.x do
			local rel_x = x - ctx.zone_minp.x
			local rel_z = z - ctx.zone_minp.z
			local block_x = math.floor(rel_x / BLOCK_SIZE)
			local block_z = math.floor(rel_z / BLOCK_SIZE)
			local in_block_x = rel_x % BLOCK_SIZE
			local in_block_z = rel_z % BLOCK_SIZE
			
			-- Check if in path zone
			local in_path_x = (in_block_x < PATH_WIDTH)
			local in_path_z = (in_block_z < PATH_WIDTH)
			
			if in_path_x or in_path_z then
				-- Place path or road
				local is_road_x = has_asphalt_road(block_x, block_z, 0, zone_seed)
				local is_road_z = has_asphalt_road(block_x, block_z, 1, zone_seed)
				
				if 1 >= ctx.sub_minp.y and 1 <= ctx.sub_maxp.y then
					local vi = ctx.area:index(x, 1, z)
					if (in_path_x and is_road_x) or (in_path_z and is_road_z) then
						ctx.data[vi] = c_asphalt  -- 20% asphalt roads
					else
						ctx.data[vi] = c_sidewalk  -- 80% pedestrian paths
					end
				end
				
				-- Place street lamps
				if (rel_x % LAMP_SPACING == 0 or rel_z % LAMP_SPACING == 0) and 
				   (in_block_x == 1 or in_block_z == 1) then
					for y = 2, LAMP_HEIGHT + 1 do
						if y >= ctx.sub_minp.y and y <= ctx.sub_maxp.y then
							local vi = ctx.area:index(x, y, z)
							if y == LAMP_HEIGHT + 1 then
								ctx.data[vi] = c_lamp
							else
								ctx.data[vi] = c_beton  -- Lamp pole
							end
						end
					end
				end
			end
		end
	end
	
	-- Pass 3: Buildings and recreation zones
	for z = ctx.sub_minp.z, ctx.sub_maxp.z do
		for x = ctx.sub_minp.x, ctx.sub_maxp.x do
			local rel_x = x - ctx.zone_minp.x
			local rel_z = z - ctx.zone_minp.z
			local block_x = math.floor(rel_x / BLOCK_SIZE)
			local block_z = math.floor(rel_z / BLOCK_SIZE)
			local in_block_x = rel_x % BLOCK_SIZE
			local in_block_z = rel_z % BLOCK_SIZE
			
			-- Skip path zones
			local in_path_x = (in_block_x < PATH_WIDTH)
			local in_path_z = (in_block_z < PATH_WIDTH)
			if in_path_x or in_path_z then
				goto continue
			end
			
			-- Building zone coordinates
			local zone_x = in_block_x - PATH_WIDTH
			local zone_z = in_block_z - PATH_WIDTH
			local zone_size = BLOCK_SIZE - PATH_WIDTH
			
			if is_recreation(block_x, block_z, zone_seed) then
				-- Recreation zone: sparse trees + ONE central playground
				local elem_hash = hash_pos(x, z, zone_seed + 7777)
				
				-- Sparse trees around perimeter
				if (elem_hash % 100) < TREE_DENSITY then
					if 1 >= ctx.sub_minp.y and 1 <= ctx.sub_maxp.y then
						local vi = ctx.area:index(x, 1, z)
						ctx.data[vi] = c_tree
					end
				end
				
				-- One central playground (20x20 area in center of block)
				local pg_center_x = math.floor(zone_size / 2)
				local pg_center_z = math.floor(zone_size / 2)
				local pg_x = zone_x - pg_center_x + 10  -- Offset to center
				local pg_z = zone_z - pg_center_z + 10
				
				-- Check if in playground area
				if pg_x >= 0 and pg_x < 20 and pg_z >= 0 and pg_z < 20 then
					-- Sandbox with walls (8x8 in corner)
					if pg_x >= 2 and pg_x < 10 and pg_z >= 2 and pg_z < 10 then
						if 1 >= ctx.sub_minp.y and 1 <= ctx.sub_maxp.y then
							local vi = ctx.area:index(x, 1, z)
							-- Walls around sandbox
							if pg_x == 2 or pg_x == 9 or pg_z == 2 or pg_z == 9 then
								ctx.data[vi] = c_beton
								if 2 >= ctx.sub_minp.y and 2 <= ctx.sub_maxp.y then
									local vi2 = ctx.area:index(x, 2, z)
									ctx.data[vi2] = c_beton  -- Wall height 2
								end
							else
								-- Sand inside
								ctx.data[vi] = c_sand
							end
						end
					-- Benches (3 benches around playground)
					elseif (pg_x >= 12 and pg_x < 14 and pg_z == 3) or
					       (pg_x >= 12 and pg_x < 14 and pg_z == 8) or
					       (pg_x >= 12 and pg_x < 14 and pg_z == 13) then
						if 1 >= ctx.sub_minp.y and 1 <= ctx.sub_maxp.y then
							local vi = ctx.area:index(x, 1, z)
							ctx.data[vi] = c_beton
						end
					-- Carousel (3x3 center post)
					elseif pg_x >= 2 and pg_x < 5 and pg_z >= 12 and pg_z < 15 then
						if pg_x == 3 and pg_z == 13 then
							-- Center pole (4 blocks tall)
							for y = 1, 4 do
								if y >= ctx.sub_minp.y and y <= ctx.sub_maxp.y then
									local vi = ctx.area:index(x, y, z)
									ctx.data[vi] = c_beton
								end
							end
						else
							-- Base platform
							if 1 >= ctx.sub_minp.y and 1 <= ctx.sub_maxp.y then
								local vi = ctx.area:index(x, 1, z)
								ctx.data[vi] = c_bricks
							end
						end
					-- Slide (diagonal 6 blocks)
					elseif pg_x >= 15 and pg_x < 18 and pg_z >= 5 and pg_z < 11 then
						local slide_h = math.floor((pg_z - 5) / 2) + 1
						for y = 1, slide_h do
							if y >= ctx.sub_minp.y and y <= ctx.sub_maxp.y then
								local vi = ctx.area:index(x, y, z)
								ctx.data[vi] = c_bricks
							end
						end
					-- Swings (3 swing sets: 2 poles + crossbar)
					elseif pg_z >= 15 and pg_z < 18 then
						if (pg_x == 5 or pg_x == 7 or pg_x == 10 or pg_x == 12 or pg_x == 15 or pg_x == 17) then
							-- Poles (3 blocks tall)
							for y = 1, 3 do
								if y >= ctx.sub_minp.y and y <= ctx.sub_maxp.y then
									local vi = ctx.area:index(x, y, z)
									ctx.data[vi] = c_beton
								end
							end
						elseif (pg_x >= 5 and pg_x <= 7) or (pg_x >= 10 and pg_x <= 12) or (pg_x >= 15 and pg_x <= 17) then
							-- Crossbar
							if 3 >= ctx.sub_minp.y and 3 <= ctx.sub_maxp.y and pg_z == 16 then
								local vi = ctx.area:index(x, 3, z)
								ctx.data[vi] = c_beton
							end
						end
					end
				end
			else
				-- Residential zone: place cuboid building
				local orientation = get_building_orientation(block_x, block_z, zone_seed)
				local bldg_w, bldg_d = BUILDING_WIDTH, BUILDING_DEPTH
				if orientation == 1 then
					bldg_w, bldg_d = bldg_d, bldg_w  -- Rotate 90 degrees
				end
				
				local bldg_height = get_building_height(block_x, block_z, zone_seed)
				local wall_material = ((block_x + block_z) % 2 == 0) and c_beton or c_bricks
				
				-- Center building in zone
				local bldg_start_x = math.floor((zone_size - bldg_w) / 2)
				local bldg_start_z = math.floor((zone_size - bldg_d) / 2)
				
				-- Check if current position is inside building footprint
				if zone_x >= bldg_start_x and zone_x < bldg_start_x + bldg_w and
				   zone_z >= bldg_start_z and zone_z < bldg_start_z + bldg_d then
					
					local bx = zone_x - bldg_start_x
					local bz = zone_z - bldg_start_z
					
					-- Check if on perimeter (exterior walls)
					local on_perimeter = (bx == 0 or bx == bldg_w - 1 or bz == 0 or bz == bldg_d - 1)
					
					-- Generate building vertically
					for y = 1, bldg_height do
						if y >= ctx.sub_minp.y and y <= ctx.sub_maxp.y then
							local vi = ctx.area:index(x, y, z)
							
							if on_perimeter then
								-- Exterior wall with windows
								local floor_y = (y - 1) % 4
								local is_window_height = (floor_y == 2)  -- Windows at 2nd node of each floor
								local is_window_col = ((bx % 3 == 1 and bz > 0 and bz < bldg_d - 1) or
								                       (bz % 3 == 1 and bx > 0 and bx < bldg_w - 1))
								
								if is_window_height and is_window_col then
									ctx.data[vi] = c_glass  -- Window
								else
									ctx.data[vi] = wall_material  -- Wall
								end
							else
								-- Interior: hollow (air)
								ctx.data[vi] = c_air
							end
						end
					end
				end
			end
			
			::continue::
		end
	end
	
	minetest.log("action", "[dumbgen2:city] Generated USSR microdistrict zone (" .. ctx.zx .. ", " .. ctx.zz .. ")")
end

-- Register generator
if temz_zones and temz_zones.register_generator then
	temz_zones.register_generator("city", {
		y_min = -20,
		y_max = 50,
		generate = city.generate,
	})
end

return city
