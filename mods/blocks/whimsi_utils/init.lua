-- Updated function to load and rotate a schematic using Minetest's vector.rotate function OwO 🌈🔄
local function load_and_rotate_schematic(pos, filename, rotation)
    local schematic = minetest.get_modpath("whimsi_utils") .. "/" .. filename -- Adjust modname and path accordingly 📁

    local schem = minetest.read_schematic(schematic, {})
    if not schem then
        minetest.log("error", "Failed to load schematic: " .. filename)
        return
    end

    for y = 1, schem.size.y do
        for z = 1, schem.size.z do
            for x = 1, schem.size.x do
                local node_name = schem.data[x + (z - 1) * schem.size.x + (y - 1) * schem.size.x * schem.size.z].name
                local rotated_pos = vector.rotate(vector.new(x - 1, y - 1, z - 1), rotation)
                rotated_pos.x = rotated_pos.x + pos.x
                rotated_pos.y = rotated_pos.y + pos.y
                rotated_pos.z = rotated_pos.z + pos.z
                print(rotated_pos.x, rotated_pos.y, rotated_pos.z)
                print(node_name)
                minetest.set_node(rotated_pos, {name = node_name})
            end
        end
    end
end

-- TODO: generate something else
-- function make_candy()
--     -- Example usage: Load a candy stick schematic and rotate it! OwO 🍭🔄
--     local candy_position = {x = 0, y = 200, z = 0}
--     local candy_rotation = {x = 0, y = 0, z = 0} -- Adjust rotation angles as needed! UwU 🔄
--
--     load_and_rotate_schematic(candy_position, "candy_stick.mts", candy_rotation)
-- end
-- There you go, sweetie! Load your schematic, rotate it, and enjoy your adorable candy stick! 🍬✨

-- Meow~ Nya~ UwU 🐾💕


-- minetest.register_on_generated(make_candy)


-- Mapgen settings
local box_types = {
--     { name = "Red Box", node = "default:steelblock", size = { x = 5, y = 3, z = 7 } },
    { name = "Panel House", node = "constructions:beton", size = { x = 40, y = 15, z = 10 } },
--     { name = "Blue Box", node = "default:glass", size = { x = 3, y = 7, z = 5 } },
    { name = "Brick House", node = "constructions:white_bricks2", size = { x = 25, y = 40, z = 20 } },
}
local foliage_nodes = {
--     "flowers:dandelion_yellow",
--     "flowers:dandelion_white",
--     "flowers:rose",
--     "flowers:tulip",
--     "flowers:viola",
--     "flowers:geranium",
--     "default:grass_1",
--     "default:grass_2",
--     "default:grass_3",
--     "default:grass_4",
--     "default:grass_5",
    "uliza:tree1",
}
local x_spacing = 80 -- Distance between boxes in x direction
local z_spacing = 40 -- Distance between box lines in z direction
local ground_level = 0    -- Height of the flat dirt
local flower_density = 0.005 -- Probability of a flower per dirt node

minetest.register_on_generated(function(minp, maxp, seed)
    -- Skip generation in labyrinth and factory zones
    if temz_zones then
        local skip = false
        temz_zones.for_each_zone_overlapping(minp, maxp, function(zx, zz, zone_min, zone_max)
            local zone_type = temz_zones.get_zone_type(zx, zz)
            if zone_type == "labyrinth" or zone_type == "factory" then
                skip = true
            end
        end)
        if skip then return end
    end
    
    -- Check if this chunk contains the ground level
    if minp.y > ground_level or maxp.y < ground_level then
        return
    end

    local vm = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map(minp, maxp)
    local a = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
    local data = vm:get_data()

    -- Content IDs
    local c_dirt = minetest.get_content_id("uliza:ground")
    local c_air = minetest.get_content_id("air")
    local c_foliage = {}
    for _, node in ipairs(foliage_nodes) do
        table.insert(c_foliage, minetest.get_content_id(node))
    end
    local c_boxes = {}
    for _, box in ipairs(box_types) do
        table.insert(c_boxes, minetest.get_content_id(box.node))
    end

    -- Function to check if a position is within any box area
    local function is_in_box_area(x, z)
        local box_row = math.floor(z / z_spacing)
        local box_x = math.floor(x / x_spacing)
        local box_index = (box_x % #box_types) + 1

        if box_index > #box_types then return false end

        local box = box_types[box_index]
        local box_start_x = box_x * x_spacing
        local box_start_z = box_row * z_spacing

        return x >= box_start_x and x < box_start_x + box.size.x and
               z >= box_start_z and z < box_start_z + box.size.z
    end

    -- Create flat dirt layer
    for z = minp.z, maxp.z do
        for x = minp.x, maxp.x do
            local vi = a:index(x, ground_level, z)
            data[vi] = c_dirt
        end
    end

    -- Place foliage (avoiding box areas)
    for z = minp.z, maxp.z do
        for x = minp.x, maxp.x do
            if not is_in_box_area(x, z) and math.random() <= flower_density then
                local vi = a:index(x, ground_level + 1, z)
                data[vi] = c_foliage[math.random(#c_foliage)]
            end
        end
    end

    -- Place boxes
    for z = minp.z, maxp.z, z_spacing do
        for x = minp.x, maxp.x, x_spacing do
            local box_index = (math.floor(x / x_spacing) % #box_types) + 1
            local box = box_types[box_index]

            -- Skip if box would be outside maxp
            if x + box.size.x > maxp.x or z + box.size.z > maxp.z then
                goto continue
            end

            -- Place box
            for y = 0, box.size.y - 1 do
                for bz = 0, box.size.z - 1 do
                    for bx = 0, box.size.x - 1 do
                        local vi = a:index(x + bx, ground_level + 1 + y, z + bz)
                        data[vi] = c_boxes[box_index]
                    end
                end
            end

            ::continue::
        end
    end

    vm:set_data(data)
    vm:write_to_map(true)
end)
