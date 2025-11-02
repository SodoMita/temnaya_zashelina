minetest.register_node("kawaii_village:ladder_wood", {
	description = "Wooden Ladder",
	drawtype = "signlike",
	tiles = {"ladder1.png"},
	inventory_image = "ladder1.png",
	wield_image = "ladder1.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	climbable = true,
	is_ground_content = false,
	selection_box = {
		type = "wallmounted",
		--wall_top = = <default>
		--wall_bottom = = <default>
		--wall_side = = <default>
	},
	groups = {choppy = 2, oddly_breakable_by_hand = 3, flammable = 2},
	legacy_wallmounted = true,
	-- sounds = default.node_sound_wood_defaults(),
})
