-- Sliding doors for labyrinth (non-locked, atmospheric)

-- Register ghost trigger node (invisible marker in walls)
minetest.register_node("labyrinth:ghost_trigger", {
	description = "Ghost Trigger (invisible)",
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	groups = {not_in_creative_inventory = 1},
})

-- Register sliding door - closed state
minetest.register_node("labyrinth:slide_door_closed", {
	description = "Sliding Door (Closed)",
	tiles = {"constructions_white.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults(),
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.125, 0.5, 1.5, 0.125}
	},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		-- Play sliding sound
		minetest.sound_play("scary_attack", {pos = pos, gain = 0.3, max_hear_distance = 10})
		
		-- Change to open state
		node.name = "labyrinth:slide_door_open"
		minetest.set_node(pos, node)
		
		-- Auto-close after 5 seconds
		minetest.after(5, function()
			local current_node = minetest.get_node(pos)
			if current_node.name == "labyrinth:slide_door_open" then
				current_node.name = "labyrinth:slide_door_closed"
				minetest.set_node(pos, current_node)
				minetest.sound_play("scary_attack", {pos = pos, gain = 0.2, max_hear_distance = 10})
			end
		end)
		
		return itemstack
	end,
})

-- Register sliding door - open state
minetest.register_node("labyrinth:slide_door_open", {
	description = "Sliding Door (Open)",
	tiles = {"constructions_white.png^[opacity:128"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {cracky = 3, not_in_creative_inventory = 1},
	sounds = default.node_sound_stone_defaults(),
	walkable = false,
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, -0.375, 1.5, 0.5}  -- Door slid to the side
	},
	drop = "labyrinth:slide_door_closed",
})

minetest.log("action", "[labyrinth] Doors registered")
