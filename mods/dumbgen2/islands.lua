-- Nyaa~! Improved Layered Floating Islands Mapgen for Minetest UwU

-- Define island parameters
local island_radius = 7
local island_materials = {
    ["surface"] = "uliza:ground",
    ["subsurface"] = "uliza:ground",
    ["interior"] = {"constructions:beton"}
}

local foliage_nodes = {"fluffy_forest:leaves", "flowers:rose", "flowers:dandelion_yellow", "flowers:dandelion_white"} -- TODO: our flowers

local treedef = {
    axiom = "FFFFFAFFBF",
    rules_a = "[&&&FFFFF&&FFFF][&&&++++FFFFF&&FFFF][&&&----FFFFF&&FFFF][&&&F&&FFFF]",
    rules_b = "[&&&++FFFFF&&FFFF][&&&--FFFFF&&FFFF][&&&------FFFFF&&FFFF][&&&F&&FFFF][&&&+++F&&FFFF][&&&----F&&FFFF]",
	rules_c="[F][+CF][-CF]",
	trunk="fluffy_forest:tree",
	leaves="fluffy_forest:leaves",
	angle=30,
	iterations=2,
	random_level=1,
	trunk_type="single",
	thin_branches=true,
	fruit_chance=10,
	fruit="food:apple"
}

local function select_random(table)
    return table[math.random(1, #table)]
end

local function distance_to_center(pos, center)
    return math.sqrt((pos.x - center.x)^2 + (pos.y - center.y)^2 + (pos.z - center.z)^2)
end

-- Function to fill a circle with blocks
function fillCircle(pos, radius, node_name)
    for x = -radius, radius do
        y = 0
        for z = -radius, radius do
            local distance = vector.length(vector.new(x, y, z))
            if distance <= radius then
                local target_pos = vector.add(pos, vector.new(x, y, z))
                minetest.set_node(target_pos, {name = node_name})
            end
        end
    end
end

-- Function to fill a circle with blocks and add decorations
function fillCircleAndDecor(pos, radius, block_name, decor_nodes)
    for x = -radius, radius do
        y = 0
        for z = -radius, radius do
            local distance = vector.length(vector.new(x, y, z))
            if distance <= radius then
                local target_pos = vector.add(pos, vector.new(x, y, z))
                minetest.set_node(target_pos, {name = block_name})

                -- Add random foliage on top of the grass layer
                local foliage_pos = {x = target_pos.x, y = target_pos.y + 1, z = target_pos.z}
                local node_above_foliage = {x = target_pos.x, y = target_pos.y + 2, z = target_pos.z}
                if minetest.get_node(foliage_pos).name == "air" and minetest.get_node(node_above_foliage).name == "air" and math.random() < 0.2 then
                    -- Spawn tree, or not tree
                    if math.random() < 0.01 then
                        minetest.spawn_tree(foliage_pos, treedef)
                    else
                        minetest.set_node(foliage_pos, {name = select_random(decor_nodes)})
                    end
                end
            end
        end
    end
end


-- Function to generate a ball-shaped floating island at a given position
local function generate_ball_island(pos)

    local center = {x = pos.x, y = pos.y + island_radius, z = pos.z}

    -- Fill the upper half with a circle of grass
    fillCircleAndDecor({x = pos.x, y = pos.y + 1, z = pos.z}, island_radius-1, island_materials["surface"], foliage_nodes)
    fillCircle(pos, island_radius, island_materials["surface"])

    for x = pos.x - island_radius, pos.x + island_radius do
        for y = pos.y - island_radius, pos.y - 1 do
            for z = pos.z - island_radius, pos.z + island_radius do
                local distance = vector.distance({x = pos.x, y = pos.y, z = pos.z}, {x = x, y = y, z = z})
                local node_name

                if distance <= island_radius then
                    local height_factor = 1 - (distance / island_radius)
                    local cpos = {x = x, y = y, z = z}
                    if height_factor < 0.6 then
                        node_name = island_materials["subsurface"]
                    else
                        node_name = select_random(island_materials["interior"])
                    end
                    minetest.set_node(cpos, {name = node_name})
                end
            end
        end
    end

    -- Add random foliage on top of the grass layer
--     local top_pos = {x = pos.x, y = pos.y + island_radius, z = pos.z}
--     for _, foliage_name in ipairs(foliage_nodes) do
--         local offset = {x = math.random(-island_radius, island_radius), y = math.random(1, island_radius), z = math.random(-island_radius, island_radius)}
--         local node_above_top = vector.add(top_pos, {x = offset.x, y = offset.y + 1, z = offset.z})
--         if minetest.get_node(top_pos).name == "candy_canyon:sprinkles" and minetest.get_node(node_above_top).name == "air" then
--             minetest.set_node(node_above_top, {name = foliage_name})
--         end
--     end
end

-- Mapgen function
minetest.register_on_generated(function(minp, maxp, seed)
    -- Calculate island position
    local island_pos = {
        x = math.random(minp.x + island_radius, maxp.x - island_radius),
        y = math.random(minp.y + island_radius, maxp.y - island_radius),
        z = math.random(minp.z + island_radius, maxp.z - island_radius)
    }

    -- Generate ball-shaped floating island at the calculated position
    if math.random() < 0.001 then
        generate_ball_island(island_pos)
        -- Fix lighting after generation! ✨
        minetest.fix_light(minp, maxp)
    end
end)
