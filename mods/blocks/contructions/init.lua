minetest.register_node('constructions:beton',{
	description = "Beton block",
	tiles = {"beton.png"},
	is_ground_content = false,
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node('constructions:white_bricks2', {
	description = "White Brick Block",
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {
		"white_bricks2.png^[transformFX",
		"white_bricks2.png",
	},
	is_ground_content = false,
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults(),
})

color_snd = {name="porcelain", footstep="porcelain_place_node", gain=10}

minetest.register_node('constructions:white', {
	description = "White Cube",
	place_param2 = 0,
	tiles = {"white.png"},
	is_ground_content = false,
	groups = {cracky = 3},
-- 	sounds = default.node_sound_stone_defaults(), // TODO: ceramic sound
	sounds = color_snd,
})

minetest.register_node('constructions:wb_tile1', {
	description = "White Black Cube 1",
	place_param2 = 0,
	tiles = {"wb_tile.png"},
	is_ground_content = false,
	groups = {cracky = 3},
-- 	sounds = default.node_sound_stone_defaults(), // TODO: ceramic sound
	sounds = color_snd,
})

minetest.register_node('constructions:bw_tile1', {
	description = "Black White Cube 1",
	place_param2 = 0,
	tiles = {"bw_tile.png"},
	is_ground_content = false,
	groups = {cracky = 3},
-- 	sounds = default.node_sound_stone_defaults(), // TODO: ceramic sound
	sounds = color_snd,
})

minetest.register_node('constructions:wb_tile2', {
	description = "White Black Cube 2",
	place_param2 = 0,
	tiles = {"wb_tile2.png"},
	is_ground_content = false,
	groups = {cracky = 3},
-- 	sounds = default.node_sound_stone_defaults(), // TODO: ceramic sound
	sounds = color_snd,
})

minetest.register_node('constructions:bw_tile2', {
	description = "Black White Cube 2",
	place_param2 = 0,
	tiles = {"bw_tile2.png"},
	is_ground_content = false,
	groups = {cracky = 3},
-- 	sounds = default.node_sound_stone_defaults(), // TODO: ceramic sound
	sounds = color_snd,
})

minetest.register_node('constructions:bw_blink1', {
	description = "BlinkBW",
	place_param2 = 0,
	tiles = {
		{
			name = "white_black_anim1.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 1,
				aspect_h = 1,
				length = 1/120,
			},
		},
	},
	is_ground_content = false,
	groups = {cracky = 3},
-- 	sounds = default.node_sound_stone_defaults(), // TODO: ceramic sound
	sounds = color_snd,
})

minetest.register_node('constructions:bw_blink2', {
	description = "BlinkBW",
	place_param2 = 0,
	tiles = {
		{
			name = "white_black_anim2.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 1,
				aspect_h = 1,
				length = 1/120,
			},
		},
	},
	is_ground_content = false,
	groups = {cracky = 3},
-- 	sounds = default.node_sound_stone_defaults(), // TODO: ceramic sound
	sounds = color_snd,
})

minetest.register_node('constructions:transparent_beton', {
	description = "Transparent Beton",
	tiles = {"transparent_beton.png"},  -- Placeholder texture
	drawtype = "glasslike",
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 10,  -- Emits light
	use_texture_alpha = "blend",
	is_ground_content = false,
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults(),
})
