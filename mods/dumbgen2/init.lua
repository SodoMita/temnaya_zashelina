-- Load zone management system first
dofile(minetest.get_modpath("dumbgen2") .. "/zones.lua")

-- Load city generation
dofile(minetest.get_modpath("dumbgen2") .. "/city.lua")

-- Load generation orchestrator (VoxelManip-based, handles all zones)
dofile(minetest.get_modpath("dumbgen2") .. "/orchestrator.lua")

-- Floating islands generation (TEMPORARILY DISABLED - will re-enable after zone gen works)
-- dofile(minetest.get_modpath("dumbgen2") .. "/islands.lua")
-- dofile(minetest.get_modpath("dumbgen2") .. "/pillars.lua")
-- dofile(minetest.get_modpath("dumbgen2") .. "/pillar2.lua")
