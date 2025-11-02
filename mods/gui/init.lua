-- Load new systems! ✨
local modpath = minetest.get_modpath(minetest.get_current_modname())

-- Experience and leveling system 🌟
dofile(modpath .. "/experience_system.lua")

-- Achievement system 🏆 (load before tracking)
dofile(modpath .. "/achievement_system.lua")

-- Achievement definitions 🏆
dofile(modpath .. "/achievement_definitions.lua")

-- Achievement tracking 📊
dofile(modpath .. "/achievement_tracking.lua")

-- Button-based crafting system 🔨
dofile(modpath .. "/crafting_system.lua")

-- Ability tree and stat points system 🌳
dofile(modpath .. "/ability_system.lua")

-- NEW Advanced ability system with graph! ⚡
dofile(modpath .. "/ability_system_new.lua")

-- Unified inventory with tabs 📋
dofile(modpath .. "/unified_inventory.lua")

-- Old broken GUI (disabled)
-- dofile(modpath .. "/player_gui.lua")

minetest.log("action", "[gui] Custom GUI systems loaded! ✨")

