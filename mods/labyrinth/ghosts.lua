-- Ghost entities for labyrinth: spawn in walls, slide out with scary sounds

-- Track triggered ghost spawners to avoid repeats
labyrinth.triggered_ghosts = {}

-- Register ghost entity
minetest.register_entity("labyrinth:ghost", {
	initial_properties = {
		physical = false,
		collide_with_objects = false,
		collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3},
		visual = "sprite",
		textures = {"scary_mob_texture.png"},
		visual_size = {x = 1, y = 1},
		glow = 5,
		static_save = false,
	},
	
	slide_direction = {x = 0, y = 0, z = 0},
	lifetime = 0,
	max_lifetime = 3,  -- Despawn after 3 seconds
	slide_speed = 2,
	
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
			self.object:remove()
			return
		end
		
		-- Slide in the specified direction
		local pos = self.object:get_pos()
		if pos and self.slide_direction then
			local new_pos = vector.add(pos, vector.multiply(self.slide_direction, self.slide_speed * dtime))
			self.object:set_pos(new_pos)
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
							
							if dir_str and dir_str ~= "" then
								slide_dir = minetest.deserialize(dir_str)
							else
								-- Random direction if not specified
								local angle = math.random() * math.pi * 2
								slide_dir = {x = math.cos(angle), y = 0, z = math.sin(angle)}
							end
							
							-- Spawn ghost slightly inside the wall
							local spawn_pos = vector.add(check_pos, vector.multiply(slide_dir, -0.5))
							local ghost = minetest.add_entity(spawn_pos, "labyrinth:ghost")
							
							if ghost then
								local lua_ent = ghost:get_luaentity()
								if lua_ent then
									lua_ent.slide_direction = slide_dir
								end
							end
						end
					end
				end
			end
		end
		
		::continue::
	end
end)

minetest.log("action", "[labyrinth] Ghost system initialized")
