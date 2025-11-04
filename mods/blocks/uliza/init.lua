-- Liquids

minetest.register_node("uliza:water_source", {
	description = "Fluffy Water Source",
	drawtype = "liquid",
	waving = 3,
	tiles = {
		{
			name = "wat_source_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 8.0,
			},
		},
		{
			name = "wat_source_inside.png",
			backface_culling = true,
		},
	},
	use_texture_alpha = "blend",
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "uliza:water_flowing",
	liquid_alternative_source = "uliza:water_source",
	liquid_viscosity = 4,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, cools_lava = 1},
	sounds = {name="stable-water1"},
})

minetest.register_node("uliza:block", {
	description = "Just Block",
	drawtype = "glasslike_framed",

	tiles = {"just_block.png", "just_block_detail.png"},
	inventory_image = minetest.inventorycube("just_block.png"),

	paramtype = "light",
	sunlight_propagates = true, -- Sunlight can shine through block
	is_ground_content = false, -- Stops caves from being generated over this node.

	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	-- sounds = default.node_sound_glass_defaults()
})

minetest.register_node("uliza:framed_glass", {
	description = "Framed Glass",
	drawtype = "glasslike_framed_optional",
	tiles = {"glass.png", "glass_detail.png"},
	inventory_image = minetest.inventorycube("glass.png"),
	use_texture_alpha = "blend",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	-- sounds = "glass",
})
minetest.register_node("uliza:glass", {
	description = "Glass",
	drawtype = "glasslike",
	tiles = {"whiteA25.png"},
	inventory_image = minetest.inventorycube("whiteA25.png"),
	use_texture_alpha = "blend",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	-- sounds = "glass",
})
minetest.register_node("uliza:purple_glass", {
	description = "Purple Glass",
	drawtype = "glasslike",
	tiles = {"purpleA25.png"},
	inventory_image = minetest.inventorycube("purpleA25.png"),
	use_texture_alpha = "blend",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	-- sounds = "glass",
})
minetest.register_node("uliza:red_glass", {
	description = "Red Glass",
	drawtype = "glasslike",
	tiles = {"redA25.png"},
	inventory_image = minetest.inventorycube("redA25.png"),
	use_texture_alpha = "blend",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	-- sounds = "glass",
})
minetest.register_node("uliza:green_glass", {
	description = "Green Glass",
	drawtype = "glasslike",
	tiles = {"greenA25.png"},
	inventory_image = minetest.inventorycube("greenA25.png"),
	use_texture_alpha = "blend",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	-- sounds = "glass",
})
minetest.register_node("uliza:blue_glass", {
	description = "Blue Glass",
	drawtype = "glasslike",
	tiles = {"blueA25.png"},
	inventory_image = minetest.inventorycube("blueA25.png"),
	use_texture_alpha = "blend",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	-- sounds = "glass",
})
minetest.register_node("uliza:yellow_glass", {
	description = "Yellow Glass",
	drawtype = "glasslike",
	tiles = {"yellowA25.png"},
	inventory_image = minetest.inventorycube("yellowA25.png"),
	use_texture_alpha = "blend",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	-- sounds = "glass",
})
minetest.register_node("uliza:cyan_glass", {
	description = "Cyan Glass",
	drawtype = "glasslike",
	tiles = {"cyanA25.png"},
	inventory_image = minetest.inventorycube("cyanA25.png"),
	use_texture_alpha = "blend",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	-- sounds = "glass",
})

minetest.register_node("uliza:leaves", {
	description = "Apple Tree Leaves",
	drawtype = "allfaces_optional",
	waving = 1,
	tiles = {"hnp-leaves.png"},
-- 	special_tiles = {"default_leaves_simple.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy = 3, leafdecay = 3, flammable = 2, leaves = 1},
-- 	drop = {
-- 		max_items = 1,
-- 		items = {
-- 			{
-- 				-- player will get sapling with 1/20 chance
-- 				items = {"default:sapling"},
-- 				rarity = 20,
-- 			},
-- 			{
-- 				-- player will get leaves only if he get no saplings,
-- 				-- this is because max_items is 1
-- 				items = {"default:leaves"},
-- 			}
-- 		}
-- 	},
-- 	sounds = default.node_sound_leaves_defaults(),

-- 	after_place_node = after_place_leaves,
})
minetest.register_node("uliza:tree", {
	description = "Winter Apple Tree",
	tiles = {"uliza_tree_top.png", "uliza_tree_top.png", "hnp-bark.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),

	on_place = minetest.rotate_node
})

minetest.register_node("uliza:ground", {
	description = "Ground",
	tiles = {"ground.png"},
	is_ground_content = true,
	groups = {crumbly = 3, soil = 1},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("uliza:tree1", {
	description = "Bare Tree",
	physical = true,
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, flammable = 2},
	selection_box = {
        type = "fixed",
        fixed = {
			-- Mushroom cap
-- 			{-0.5, 14.0, -0.5, 0.5, 15.0, 0.5},  -- Cap top
-- 			{-0.5, 13.0, -0.5, 0.5, 14.0, 0.5},  -- Cap middle
-- 			{-0.5, 12.0, -0.5, 0.5, 13.0, 0.5},  -- Cap bottom

			-- Mushroom stem
			{-.4, -1.0, -.4, .4, 13.0, .4},   -- Stem
		},
	},
	collision_box = {
        type = "fixed",
        fixed = {
			-- Mushroom cap
-- 			{-0.5, 14.0, -0.5, 0.5, 15.0, 0.5},  -- Cap top
-- 			{-0.5, 13.0, -0.5, 0.5, 14.0, 0.5},  -- Cap middle
-- 			{-0.5, 12.0, -0.5, 0.5, 13.0, 0.5},  -- Cap bottom

			-- Mushroom stem
			{-.4, -1.0, -.4, .4, 1.0, .4},   -- Stem
			{-.4, 1.0, -.4, .4, 3.0, .4},   -- Stem
		},
	},
	node_box = {
        type = "fixed",
        fixed = {
			-- Mushroom cap
-- 			{-0.5, 14.0, -0.5, 0.5, 15.0, 0.5},  -- Cap top
-- 			{-0.5, 13.0, -0.5, 0.5, 14.0, 0.5},  -- Cap middle
-- 			{-0.5, 12.0, -0.5, 0.5, 13.0, 0.5},  -- Cap bottom

			-- Mushroom stem
			{-.4, -1.0, -.4, .4, 1.0, .4},   -- Stem
			{-.4, 1.0, -.4, .4, 3.0, .4},   -- Stem
		},
	},
	drawtype = "mesh",
	paramtype = 'light',
	paramtype2 = 'facedir',
	visual = "mesh",
	mesh = "tree1.b3d",
	tiles = {"tree_bark.png"},
	use_texture_alpha = false,
	sounds = default.node_sound_wood_defaults(),
})

local bench_box =  {
        type = "fixed",
        fixed = {
			{-0.5, 0.06, -1.5, 0.5, 0, 1.5},
			{-0.375, 0, -1.5, -0.5, 1.15, 1.5},
		},
}

minetest.register_node("uliza:bench1", {
	description = "Park Bench",
	physical = true,
	is_ground_content = false,
	groups = {choppy = 2, flammable = 2},
	selection_box = bench_box,
	collision_box = bench_box,
	node_box = bench_box,
	drawtype = "mesh",
	paramtype = 'light',
	paramtype2 = 'facedir',
	visual = "mesh",
	mesh = "bench1.obj",
	tiles = {"bench1.png"},
	use_texture_alpha = false,
	sounds = default.node_sound_wood_defaults(),
})
-- City nodes for generation
minetest.register_node("uliza:asphalt", {
	description = "Asphalt Road",
	tiles = {"ground.png^[colorize:#1a1a1a:180"},
	is_ground_content = false,
	groups = {cracky = 3, stone = 1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("uliza:sidewalk", {
	description = "Concrete Sidewalk",
	tiles = {"ground.png^[colorize:#808080:120"},
	is_ground_content = false,
	groups = {cracky = 2, stone = 1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("uliza:street_lamp", {
	description = "Street Lamp",
	tiles = {"ground.png^[colorize:#ffff00:100"},
	paramtype = "light",
	light_source = 14,
	is_ground_content = false,
	groups = {cracky = 2, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("uliza:concrete", {
	description = "Concrete Block",
	tiles = {"ground.png^[colorize:#606060:150"},
	is_ground_content = false,
	groups = {cracky = 1, stone = 1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("uliza:brick_red", {
	description = "Red Brick",
	tiles = {"ground.png^[colorize:#8B4513:160"},
	is_ground_content = false,
	groups = {cracky = 2, stone = 1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("uliza:plaster_white", {
	description = "White Plaster",
	tiles = {"ground.png^[colorize:#f0f0f0:100"},
	is_ground_content = false,
	groups = {cracky = 2, stone = 1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("uliza:roof_tile", {
	description = "Roof Tiles",
	tiles = {"ground.png^[colorize:#654321:180"},
	is_ground_content = false,
	groups = {cracky = 2, stone = 1},
	sounds = default.node_sound_stone_defaults(),
})

-- Thin roof slabs for flat roofs
minetest.register_node("uliza:roof_slab_concrete", {
	description = "Concrete Roof Slab",
	tiles = {"ground.png^[colorize:#606060:150"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.375, 0.5},
	},
	is_ground_content = false,
	groups = {cracky = 1, stone = 1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("uliza:roof_slab_gravel", {
	description = "Gravel Roof Slab",
	tiles = {"ground.png^[colorize:#3a3a3a:120"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.375, 0.5},
	},
	is_ground_content = false,
	groups = {crumbly = 2},
	sounds = default.node_sound_gravel_defaults(),
})

-- Flat overlay quads (slightly above ground)
local leaf_overlay_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.49, -0.5, 0.5, -0.48, 0.5},
		},
}

minetest.register_node("uliza:ground_leaves", {
	description = "Ground Leaves",
	drawtype = "nodebox",
	tiles = {"ground_leaves.png"},
	use_texture_alpha = "blend",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	groups = {snappy = 3, oddly_breakable_by_hand = 3, attached_node = 1},
	node_box = leaf_overlay_box,
	selection_box = leaf_overlay_box,
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("uliza:ground_leaves2", {
	description = "Ground Leaves 2",
	drawtype = "nodebox",
	tiles = {"ground_leaves2.png"},
	use_texture_alpha = "blend",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	groups = {snappy = 3, oddly_breakable_by_hand = 3, attached_node = 1},
	node_box = leaf_overlay_box,
	selection_box = leaf_overlay_box,
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("uliza:ground_leaves2_0", {
	description = "Ground Leaves 2_0",
	drawtype = "nodebox",
	tiles = {"ground_leaves2_0.png"},
	use_texture_alpha = "blend",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	groups = {snappy = 3, oddly_breakable_by_hand = 3, attached_node = 1},
	node_box = leaf_overlay_box,
	selection_box = leaf_overlay_box,
	sounds = default.node_sound_leaves_defaults(),
})
