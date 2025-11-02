-- Set the coordinates of the starting point of the pillar
local x = 0
local y = 0
local z = 0

-- Set the name of the block to be used
local block_name = "default:wood"

-- Loop indefinitely and set the block at each coordinate
-- while true do
--     minetest.set_node({x = x, y = y, z = z}, {name = block_name})
--     y = y + 1
-- end

--[[
-- Initialize tables
local positions = {}
-- local names = {}

-- Fill tables
for i=-300,300 do
    positions[i] = {x=0, y=i, z=0}
--     names[i] = block_name
end

local function build_pillar(argument)
    minetest.bulk_set_node(positions, {name = block_name})
    print("pillar2 must work")
    minetest.set_node({x=0,y=0,z=0},"default:mese")
end

-- minetest.register_on_mapgen_init(build_pillar)
minetest.register_on_newplayer(build_pillar)]]

-- Load the Voxel Manipulator with the area of interest
local vm = VoxelManip({x = 0, y = 0, z = 0}, {x = 0, y = 100, z = 0})
local minp, maxp = vm:read_from_map({x = 0, y = 0, z = 0}, {x = 0, y = 100, z = 0})

-- Get the data from the Voxel Manipulator
local area = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
local data = vm:get_data()

-- Define the node you want to use for the pillar
local c_node = minetest.get_content_id("default:stone")

-- Loop over the area in Y direction (upwards)
for y = minp.y, maxp.y do
    -- Calculate the index for the current position
    local i = area:index(0, y, 0)
    -- Set the node at the current position to the defined node
    data[i] = c_node
end

-- Write the manipulated data back to the Voxel Manipulator
vm:set_data(data)
-- Write the data from the Voxel Manipulator back to the map
vm:write_to_map()
