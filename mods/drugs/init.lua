minetest.register_node("drugs:beer_bottle", {
	description = "Beer Bottle",
	drawtype = "mesh",
	mesh = "bottle_sep.obj",
	textures = {"colors.png", "mark.png"},
	tiles = {"colors.png", "mark.png"},
	use_texture_alpha = "blend",
	-- inventory_image = "vessels_glass_bottle.png",
	-- wield_image = "vessels_glass_bottle.png",
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.025, -0.5, -0.025, 0.025, -0.3, 0.025}
	},
	groups = {vessel = 1, dig_immediate = 3, attached_node = 1},
	-- sounds = default.node_sound_glass_defaults(),
	on_use = function(itemstack, user, pointed_thing)
        -- Yummy! It makes you happy~ UwU
        minetest.item_eat(0, "drugs:effect_happiness")
        -- Leave behind an empty bottle
				itemstack:take_item()
        user:get_inventory():add_item("main", "drugs:shattered_beer_bottle")
        return itemstack
    end,
	on_punch = function(pos, node, puncher, pointed_thing)
			minetest.set_node(pos, {name = "drugs:shattered_beer_bottle"})  -- *CRASH!* It broke!
	end,
})

-- Shattered Bottle (Careful, it's dangerous!)
minetest.register_node("drugs:shattered_beer_bottle", {
    description = "Shattered Beer Bottle",
    drawtype = "mesh",
    mesh = "bottle_shattered.obj",  -- Oopsie! It's broken now!
    tiles = {"colors.png"},
    paramtype = "light",
    is_ground_content = true,  -- Watch your step! It's on the ground now.
    walkable = false,
    damage_per_second = 2,  -- Ouch! It hurts if you step on it.
		selection_box = {
			type = "fixed",
			fixed = {-0.025, -0.5, -0.025, 0.025, -0.3, 0.025}
		},
    groups = {vessel = 1, dig_immediate = 3, attached_node = 1},
    -- sounds = default.node_sound_glass_defaults(),
	on_use = function(itemstack, user, pointed_thing)
        user:punch(user, 1.0, {
            full_punch_interval = 1.0,
            damage_groups = {fleshy = 2},  -- Extra ouch for using it!
        }, nil)
        return itemstack
    end,
})
