-- Labyrinth mod: Tutorial zone, workshops, ghosts, and maze generation
-- Y-level: 0 to 20

labyrinth = {}

local modpath = minetest.get_modpath("labyrinth")

-- Load components
dofile(modpath .. "/doors.lua")
dofile(modpath .. "/ghosts.lua")
dofile(modpath .. "/generation.lua")

minetest.log("action", "[labyrinth] Labyrinth mod loaded")
