-- Factory mod: Tall structures with pipes, chess floors, and progressive key system
-- Y-level: -20 to 100

factory = {}

local modpath = minetest.get_modpath("factory")

-- Load components
dofile(modpath .. "/keys.lua")
dofile(modpath .. "/doors.lua")
dofile(modpath .. "/pipes.lua")
dofile(modpath .. "/generation.lua")

minetest.log("action", "[factory] Factory mod loaded")
