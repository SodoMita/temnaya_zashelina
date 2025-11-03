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
		"black.png",
		"black.png",
		"black.png",
		"black.png",
		"ghost_back.png",  -- Back
		"ghost_front.png",  -- Front
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		-- Full width (1 node = -0.5 to 0.5), placed at wall edge (back against wall)
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, -0.4},
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, -0.4},
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 2},
	is_ground_content = false,
	sounds = default.node_sound_defaults(),
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 14,  -- Fullbright - emits maximum light
})

-- Register ghost entity
minetest.register_entity("labyrinth:ghost", {
	initial_properties = {
		physical = false,
		collide_with_objects = false,
		collisionbox = {-0.5, -0.5, -0.05, 0.5, 0.5, 0.05},
		visual = "cube",
		textures = {
			"black.png",        -- top
			"black.png",        -- bottom
			"black.png",        -- right
			"black.png",        -- left
			"ghost_back.png",   -- back (away from wall)
			"ghost_front.png",  -- front (toward wall)
		},
		visual_size = {x = 1, y = 1, z = 0.1},
		static_save = false,
		visual_offset = {x = 0, y = 0, z = 0},
		shaded = false,  -- Disable shading for fullbright appearance
		glow = 14,  -- Match node's light level
	},
	
	slide_direction = {x = 0, y = 0, z = 0},
	lifetime = 0,
	max_lifetime = 4,  -- Total lifetime before despawn
	slide_speed = 0.5,
	total_distance = 0,
	max_distance = 1,  -- Move only 1 node
	trigger_pos = nil,  -- Store trigger position for replacement
	wall_offset = nil,  -- Store wall offset for sign placement
	bounce_start_time = nil,  -- When bounce animation starts
	bounce_duration = 1,  -- Duration of bounce animation
	wait_duration = 0.3,  -- Wait time after bounce before despawn
	despawn_delay = 0.1,  -- Extra delay after spawning sign before removing entity
	initial_pos = nil,  -- Starting position for bounce
	sign_spawned = false,  -- Track if sign has been spawned
	sign_spawn_time = nil,  -- When sign was spawned
	
	on_activate = function(self, staticdata, dtime_s)
		-- Play scary sound on spawn
		local pos = self.object:get_pos()
		if pos then
			minetest.sound_play("boo", {pos = pos, gain = 1.0, max_hear_distance = 15})
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
		local pos = self.object:get_pos()
		if not pos then return end
		
		-- Check if we should start bouncing
		if not self.bounce_start_time and self.total_distance >= self.max_distance then
			self.bounce_start_time = self.lifetime
			-- Calculate perpendicular offset (toward wall, perpendicular to movement)
			-- Entity visual is centered, sign back is at edge, so offset by 0.05 toward wall
			local perp_offset = {x = 0, y = 0, z = 0}
			if math.abs(self.slide_direction.x) > 0.5 then
				-- Moving in X direction, offset in Z perpendicular
				perp_offset.z = -0.05
			else
				-- Moving in Z direction, offset in X perpendicular  
				perp_offset.x = -0.05
			end
			local adjusted_pos = vector.add(pos, perp_offset)
			self.object:set_pos(adjusted_pos)
			self.initial_pos = adjusted_pos
			
			-- Debug: log final position (should be at wall edge)
			if self.trigger_pos and self.wall_offset then
				local expected_pos = {x = self.trigger_pos.x + 0.5 - self.slide_direction.x * 0.5, 
				                      y = self.trigger_pos.y, 
				                      z = self.trigger_pos.z + 0.5 - self.slide_direction.z * 0.5}
				minetest.log("action", string.format("[labyrinth] Ghost reached (%.2f, %.2f, %.2f), expected wall edge (%.2f, %.2f, %.2f), offset: %.2f",
					pos.x, pos.y, pos.z,
					expected_pos.x, expected_pos.y, expected_pos.z,
					math.sqrt((pos.x - expected_pos.x)^2 + (pos.z - expected_pos.z)^2)))
			end
		end
		
		-- Bounce animation
		if self.bounce_start_time then
			local bounce_elapsed = self.lifetime - self.bounce_start_time
			local total_duration = self.bounce_duration + self.wait_duration
			
			if bounce_elapsed >= total_duration then
				-- Wait complete - spawn sign first
				if not self.sign_spawned and self.trigger_pos then
					local node = minetest.get_node(self.trigger_pos)
					if node.name == "labyrinth:ghost_trigger" then
						-- Calculate facedir from slide direction (rotated 90 degrees)
						local facedir = 0
						if self.slide_direction.x > 0.5 then
							facedir = 2  -- +X -> facedir 2
						elseif self.slide_direction.x < -0.5 then
							facedir = 0  -- -X -> facedir 0
						elseif self.slide_direction.z > 0.5 then
							facedir = 3  -- +Z -> facedir 3
						else
							facedir = 1  -- -Z -> facedir 1
						end
						-- Place node and record time
						minetest.set_node(self.trigger_pos, {name = "labyrinth:ghost_sign", param2 = facedir})
						self.sign_spawned = true
						self.sign_spawn_time = self.lifetime
					end
				end
				
				-- Wait for delay after sign spawn before removing entity
				if self.sign_spawned and self.sign_spawn_time and (self.lifetime - self.sign_spawn_time) >= self.despawn_delay then
					self.object:remove()
					return
				end
			
			elseif bounce_elapsed < self.bounce_duration then
				-- Spring bounce animation with damped oscillation
				local progress = bounce_elapsed / self.bounce_duration
				
				-- Damped spring oscillation formula
				local frequency = 8  -- Higher frequency = more bounces
				local damping = 4  -- How quickly amplitude decreases
				
				-- Exponential decay envelope
				local envelope = math.exp(-damping * progress)
				
				-- Oscillation (sine wave with increasing frequency)
				local oscillation = math.sin(frequency * math.pi * progress)
				
				-- Combined spring motion (horizontal along slide direction)
				local horizontal_amplitude = 0.2
				local horizontal_offset = horizontal_amplitude * envelope * oscillation
				
				-- Vertical bounce (also damped)
				local vertical_amplitude = 0.15
				local vertical_offset = vertical_amplitude * envelope * math.abs(oscillation)
				
				-- Apply both horizontal and vertical offsets
				local bounce_offset = vector.multiply(self.slide_direction, horizontal_offset)
				bounce_offset.y = vertical_offset
				
				local new_pos = vector.add(self.initial_pos, bounce_offset)
				self.object:set_pos(new_pos)
			else
				-- Wait period - ensure entity stays at exact initial position
				self.object:set_pos(self.initial_pos)
			end
			return
		end
		
		-- Slide in the specified direction (but limit to 1 node)
		if self.slide_direction then
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
						-- Round to block position for unique key
						local block_pos = vector.round(check_pos)
						local trigger_key = minetest.pos_to_string(block_pos)
						
							-- Only trigger once
							if not labyrinth.triggered_ghosts[trigger_key] then
								labyrinth.triggered_ghosts[trigger_key] = true
								
								-- Award achievement progress
								if achievement_progress then
									achievement_progress(player, "first_ghost", 1)
									achievement_progress(player, "ghost_hunter", 1)
									achievement_progress(player, "ghost_veteran", 1)
								end
							
							-- Get metadata for slide direction (default to random)
							local meta = minetest.get_meta(check_pos)
							local dir_str = meta:get_string("slide_direction")
							local slide_dir
							
							local debug_nodes = {}
							local wall_offset = nil
							
							if dir_str and dir_str ~= "" then
								slide_dir = minetest.deserialize(dir_str)
							else
								-- Determine direction from adjacent wall (block_pos already rounded above)
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
							
				-- Spawn ghost INSIDE the wall (1.1 blocks into wall, closer to destination)
				-- Add 0.5 to center in XZ plane
				local spawn_pos = vector.add(block_pos, vector.multiply(wall_offset, 1.1))
				spawn_pos.x = spawn_pos.x + 0.5
				spawn_pos.z = spawn_pos.z + 0.5
							local ghost = minetest.add_entity(spawn_pos, "labyrinth:ghost")
							
							if ghost then
								local lua_ent = ghost:get_luaentity()
								if lua_ent then
									lua_ent.slide_direction = slide_dir
									lua_ent.trigger_pos = block_pos
									
									-- Calculate destination: at wall edge, not block center
									-- The sign will be placed against the wall, entity should end up there too
									local trigger_world = {x = block_pos.x + 0.5, y = spawn_pos.y, z = block_pos.z + 0.5}
									local dx = trigger_world.x - spawn_pos.x
									local dz = trigger_world.z - spawn_pos.z
									local distance = math.sqrt(dx*dx + dz*dz) - 0.5  -- Stop 0.5 blocks short (at wall edge)
									lua_ent.max_distance = distance
									
									-- Store wall offset for sign placement
									lua_ent.wall_offset = wall_offset
									
									-- Debug log
									minetest.log("action", string.format("[labyrinth] Ghost spawn at (%.2f, %.2f, %.2f), destination at (%.2f, %.2f, %.2f), distance: %.2f",
										spawn_pos.x, spawn_pos.y, spawn_pos.z,
										trigger_world.x - slide_dir.x * 0.5, trigger_world.y, trigger_world.z - slide_dir.z * 0.5,
										distance))
									
									-- Set ghost rotation based on slide direction (flip 180 to face outward)
									local yaw = 0
									if slide_dir.x > 0.5 then
										yaw = math.pi  -- +X (east)
									elseif slide_dir.x < -0.5 then
										yaw = 0  -- -X (west)
									elseif slide_dir.z > 0.5 then
										yaw = math.pi / 2  -- +Z (south)
									else
										yaw = -math.pi / 2  -- -Z (north)
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
