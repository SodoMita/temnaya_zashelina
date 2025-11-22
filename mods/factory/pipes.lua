-- Pipe nodes for factory decoration

-- Basic pipe segment
minetest.register_node("factory:pipe", {
	description = "Factory Pipe",
	tiles = {"default_steel_block.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_metal_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},  -- Vertical pipe
		}
	},
})

-- Pipe valve
minetest.register_node("factory:pipe_valve", {
	description = "Factory Pipe Valve",
	tiles = {
		"default_steel_block.png",
		"default_steel_block.png",
		"default_bronze_block.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_metal_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},  -- Pipe
			{-0.375, -0.125, -0.375, 0.375, 0.125, 0.375},  -- Valve wheel
		}
	},
})

-- Floor grate
minetest.register_node("factory:grate", {
	description = "Factory Grate",
	tiles = {"default_steel_block.png^[sheet:2x2:0,0"},
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_metal_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5},  -- Thin grate
		}
	},
})

-- Exterior fence
minetest.register_node("factory:fence", {
	description = "Factory Fence",
	tiles = {"default_steel_block.png"},
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_metal_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125},  -- Vertical post
			{-0.5, 0.25, -0.0625, 0.5, 0.375, 0.0625},  -- Top rail
			{-0.5, -0.125, -0.0625, 0.5, 0, 0.0625},  -- Bottom rail
		}
	},
})

-- Exterior wall (darker, industrial)
minetest.register_node("factory:exterior_wall", {
	description = "Factory Exterior Wall",
	tiles = {"default_stone.png^[colorize:#404040:120"},
	is_ground_content = false,
	groups = {cracky = 1, level = 2},
	sounds = default.node_sound_stone_defaults(),
})

-- Entrance door (always open/accessible)
minetest.register_node("factory:entrance_door", {
	description = "Factory Entrance Door",
	tiles = {"default_steel_block.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_metal_defaults(),
	walkable = false,  -- Can walk through
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.125, -0.375, 0.5, 0.125},  -- Left frame
			{0.375, -0.5, -0.125, 0.5, 0.5, 0.125},  -- Right frame
			{-0.5, 0.375, -0.125, 0.5, 0.5, 0.125},  -- Top frame
		}
	},
})

-- Alias factory crate to default chest for now
minetest.register_alias("factory:crate", "default:chest")

minetest.log("action", "[factory] Pipes and decorations registered")
