-- Nyaa~! Infinite Hollow Pillars Mapgen for Minetest UwU

-- Define pillar parameters
local pillar_radius = 10
local pillar_material = "default:stone"

local bulk_pos = {}
local bulk_name = {}
local pos = {x = 8, y = 0, z = 8}
-- Iterate through the pillar's radius
for x = pos.x - pillar_radius, pos.x + pillar_radius do
    for z = pos.z - pillar_radius, pos.z + pillar_radius do
        local distance = math.abs(x - pos.x) + math.abs(z - pos.z)

        -- Check if the node is within the pillar's outer radius
        if distance <= pillar_radius then
            -- Check if the node is within the pillar's inner radius to create a hollow effect
            local node_name = "air"
            if distance >= pillar_radius - 1 then
                node_name = pillar_material
            end

            -- Add node data to bulk_data
            for y = pos.y - 32, pos.y + 32 do
                table.insert(bulk_pos, {x = x, y = y, z = z})
                table.insert(bulk_name, {node_name})
            end
        end
    end
end

-- Function to generate a hollow pillar at a given position
local function generate_hollow_pillar(pillar_pos)
    local offset_bulk_pos = {}

    -- Add pillar_pos to each value in bulk_pos
    for _, value in ipairs(bulk_pos) do
        table.insert(offset_bulk_pos, {
            x = value.x + pillar_pos.x,
            y = value.y + pillar_pos.y,
            z = value.z + pillar_pos.z
        })
    end

    -- Batch set nodes
    minetest.bulk_set_node(offset_bulk_pos, bulk_name)
end



-- Mapgen function
minetest.register_on_generated(function(minp, maxp, seed)
    -- Calculate pillar position
    local pillar_pos = {
        x = minp.x + 8,
        y = minp.y,
        z = minp.z + 8
    }

    -- Generate hollow pillar at the calculated position
    generate_hollow_pillar(pillar_pos)
end)
