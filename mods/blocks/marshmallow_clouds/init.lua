
-- Define marshmallow node
minetest.register_node("marshmallow_clouds:marshmallow", {
    description = "Marshmallow",
    tiles = {"marshmallow1.png"},
    paramtype = "light",
    sunlight_propagates = true,
    -- walkable = false,
    use_texture_alpha = "blend",
    groups = {snappy = 3, cracky = 1},
    on_construct = function(pos)
        minetest.log("action", "[Marshmallow] Node constructed at position: " .. minetest.pos_to_string(pos))
    end,

})


-- Register crafting recipe for marshmallow
minetest.register_craft({
    type = "shapeless",
    output = "marshmallow_clouds:marshmallow 4",
    recipe = {"group:food_sugar", "group:food_sugar", "group:food_sugar", "group:food_sugar"},
})

-- Print a message to indicate that the marshmallow node has been registered
-- minetest.log("action", "[" .. minetest.get_current_modname() .. "] Marshmallow node registered")

minetest.register_entity("marshmallow_clouds:rainbow", {
    physical = false,
    visual = "mesh",
    mesh = "rainbow_small.obj",
    -- visual_size = {x = 0.5, y = 0.5},
    textures = {"rainbow.png"},
    -- use_texture_alpha = true,
    glow = 15,
})

minetest.register_tool("marshmallow_clouds:rainbow_spawn", {
	description = "rainbow spawn",
	inventory_image = "rainbow.png",
	on_use = function(itemstack, user, pointed_thing)
        new_entity = minetest.add_entity(user:getpos(), "marshmallow_clouds:rainbow")
        local yaw = user:get_look_horizontal()
        new_entity:set_yaw(yaw+135)
	end,
})


