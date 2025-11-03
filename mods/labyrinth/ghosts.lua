-- Ghost entities for labyrinth: spawn in walls, slide out with scary sounds

-- Track triggered ghost spawners to avoid repeats
labyrinth.triggered_ghosts = {}

-- Register invisible ghost trigger node (placed in walls)
minetest.register_node("labyrinth:ghost_trigger", {
	description = "Ghost Trigger (invisible)",
	tiles = {"labyrinth_ghost_trigger.png"},  -- Invisible/debug texture
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	is_ground_content = false,
	groups = {not_in_creative_inventory = 1},
})

-- Register ghost sign node (replaces trigger after spawn)
minetest.register_node("labyrinth:ghost_sign", {
	description = "Ghost Sign",
	tiles = {
		"labyrinth_ghost_sign_back.png",  -- Back (where it came from)
		"labyrinth_ghost_sign_front.png",  -- Front (where it moved to)
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {-0.4, -0.5, -0.05, 0.4, 0.5, 0.05},
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.4, -0.5, -0.05, 0.4, 0.5, 0.05},
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 2},
	is_ground_content = false,
	sounds = default.node_sound_defaults(),
	walkable = false,
	glow = 3,
})

-- Register ghost entity
minetest.register_entity("labyrinth:ghost", {
	initial_properties = {
		physical = false,
		collide_with_objects = false,
		collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3},
		visual = "upright_sprite",
		textures = {"scary_mob_texture.png"},
		visual_size = {x = 1, y = 1},
		glow = 5,
		static_save = false,
	},
	
	slide_direction = {x = 0, y = 0, z = 0},
	lifetime = 0,
	max_lifetime = 3,  -- Despawn after 3 seconds
	slide_speed = 2,
	total_distance = 0,
	max_distance = 1,  -- Move only 1 node
	trigger_pos = nil,  -- Store trigger position for replacement
	
	on_activate = function(self, staticdata, dtime_s)
		-- Play scary sound on spawn
		local pos = self.object:get_pos()
		if pos then
			minetest.sound_play("scary_attack", {pos = pos, gain = 1.0, max_hear_distance = 15})
		end
		
		-- Parse slide direction from staticdata if provided
		if staticdata and staticdata ~= "" then
			local dir = minetest.deserialize(staticdata)
			if dir then
				self.slide_direction = dir
			end
		end
	end,
	
	on_step = function(self, dtime)
		self.lifetime = self.lifetime + dtime
		
		-- Despawn after max lifetime
		if self.lifetime >= self.max_lifetime then
			-- Replace trigger with ghost sign before despawning
			if self.trigger_pos then
				local node = minetest.get_node(self.trigger_pos)
				if node.name == "labyrinth:ghost_trigger" then
					-- Calculate facedir from slide direction
					local facedir = 0
					if self.slide_direction.x > 0.5 then
						facedir = 3  -- +X
					elseif self.slide_direction.x < -0.5 then
						facedir = 1  -- -X
					elseif self.slide_direction.z > 0.5 then
						facedir = 2  -- +Z
					else
						facedir = 0  -- -Z
					end
					minetest.set_node(self.trigger_pos, {name = "labyrinth:ghost_sign", param2 = facedir})
				end
			end
			self.object:remove()
			return
		end
		
		-- Slide in the specified direction (but limit to 1 node)
		local pos = self.object:get_pos()
		if pos and self.slide_direction then
			local move_dist = self.slide_speed * dtime
			
			-- Check if we've moved far enough
			if self.total_distance + move_dist > self.max_distance then
				move_dist = self.max_distance - self.total_distance
			end
			
			if move_dist > 0 then
				local new_pos = vector.add(pos, vector.multiply(self.slide_direction, move_dist))
				self.object:set_pos(new_pos)
				self.total_distance = self.total_distance + move_dist
			end
		end
	end,
})

-- Globalstep to check for players near ghost triggers
local check_timer = 0
local check_interval = 0.5  -- Check every 0.5 seconds

minetest.register_globalstep(function(dtime)
	check_timer = check_timer + dtime
	if check_timer < check_interval then
		return
	end
	check_timer = 0
	
	-- Check each connected player
	for _, player in ipairs(minetest.get_connected_players()) do
		local ppos = player:get_pos()
		if not ppos then goto continue end
		
		-- Check nodes in a small radius around player
		for dx = -2, 2 do
			for dy = -1, 2 do
				for dz = -2, 2 do
					local check_pos = vector.add(ppos, {x = dx, y = dy, z = dz})
					local node = minetest.get_node(check_pos)
					
					if node.name == "labyrinth:ghost_trigger" then
						-- Create unique key for this trigger position
						local trigger_key = minetest.pos_to_string(check_pos)
						
						-- Only trigger once
						if not labyrinth.triggered_ghosts[trigger_key] then
							labyrinth.triggered_ghosts[trigger_key] = true
							
							-- Get metadata for slide direction (default to random)
							local meta = minetest.get_meta(check_pos)
							local dir_str = meta:get_string("slide_direction")
							local slide_dir
							
							local debug_nodes = {}
							local wall_offset = nil
							
							if dir_str and dir_str ~= "" then
								slide_dir = minetest.deserialize(dir_str)
							else
								-- Determine direction from adjacent wall
								-- Round to block position first!
								local block_pos = vector.round(check_pos)
								for _, offset in ipairs({{1,0,0},{-1,0,0},{0,0,1},{0,0,-1}}) do
									local check_wall = vector.add(block_pos, {x=offset[1], y=offset[2], z=offset[3]})
									local wall_node = minetest.get_node(check_wall)
									table.insert(debug_nodes, wall_node.name)
									if wall_node.name == "constructions:transparent_beton" then
										wall_offset = {x=offset[1], y=offset[2], z=offset[3]}
										break
									end
								end
								
								if wall_offset then
									-- Slide direction is opposite of wall offset (out from wall)
									slide_dir = {x = -wall_offset.x, y = 0, z = -wall_offset.z}
								else
									-- Fallback random direction
									local angle = math.random() * math.pi * 2
									slide_dir = {x = math.cos(angle), y = 0, z = math.sin(angle)}
									wall_offset = {x = -slide_dir.x, y = 0, z = -slide_dir.z}
								end
							end
							
							-- Safety check: make sure wall_offset exists
							if not wall_offset then
								local block_pos = vector.round(check_pos)
								minetest.log("warning", "[labyrinth] Ghost trigger at " .. minetest.pos_to_string(check_pos) .. 
									" (block: " .. minetest.pos_to_string(block_pos) .. ")" ..
									" has no wall_offset! Adjacent nodes: " .. table.concat(debug_nodes, ", "))
								goto skip_ghost
							end
							
							-- Spawn ghost INSIDE the wall (1.5 blocks into wall)
							-- Use block_pos for spawning too
							local block_pos = vector.round(check_pos)
							local spawn_pos = vector.add(block_pos, vector.multiply(wall_offset, 1.5))
							local ghost = minetest.add_entity(spawn_pos, "labyrinth:ghost")
							
							if ghost then
								local lua_ent = ghost:get_luaentity()
								if lua_ent then
									lua_ent.slide_direction = slide_dir
									lua_ent.trigger_pos = block_pos
									
									-- Set ghost rotation based on slide direction
									local yaw = 0
									if slide_dir.x > 0.5 then
										yaw = math.pi / 2  -- +X (east)
									elseif slide_dir.x < -0.5 then
										yaw = -math.pi / 2  -- -X (west)
									elseif slide_dir.z > 0.5 then
										yaw = 0  -- +Z (south)
									else
										yaw = math.pi  -- -Z (north)
									end
									ghost:set_yaw(yaw)
								end
							end
							
							::skip_ghost::
						end
					end
				end
			end
		end
		
		::continue::
	end
end)

minetest.log("action", "[labyrinth] Ghost system initialized")
