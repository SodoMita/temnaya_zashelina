-- Liquids

minetest.register_node("fluffy_forest:water_source", {
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
	liquid_alternative_flowing = "fluffy_forest:water_flowing",
	liquid_alternative_source = "fluffy_forest:water_source",
	liquid_viscosity = 4,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, cools_lava = 1},
	sounds = {name="stable-water1"},
})

minetest.register_node("fluffy_forest:block", {
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

minetest.register_node("fluffy_forest:framed_glass", {
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
minetest.register_node("fluffy_forest:glass", {
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
minetest.register_node("fluffy_forest:purple_glass", {
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
minetest.register_node("fluffy_forest:red_glass", {
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
minetest.register_node("fluffy_forest:green_glass", {
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
minetest.register_node("fluffy_forest:blue_glass", {
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
minetest.register_node("fluffy_forest:yellow_glass", {
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
minetest.register_node("fluffy_forest:cyan_glass", {
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

minetest.register_node("fluffy_forest:leaves", {
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
minetest.register_node("fluffy_forest:tree", {
	description = "Apple Tree",
	tiles = {"default_tree_top.png", "default_tree_top.png", "hnp-bark.jpg"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
-- 	sounds = default.node_sound_wood_defaults(),

	on_place = minetest.rotate_node
})
