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

-- Alias factory crate to default chest for now
minetest.register_alias("factory:crate", "default:chest")

minetest.log("action", "[factory] Pipes and decorations registered")
