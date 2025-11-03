-- Advanced Ability System with Visual Graph! ⚡✨
-- Stat-based abilities with min/max unlocks + Boolean toggles

-- Pan step for D-pad navigation (pixels per button press)
local PAN_STEP = 150

-- Ability definitions with graph positions
local abilities = {
    -- MOVEMENT BRANCH (top-left)
    {
        id = "walk_speed",  -- ORIGINAL - keeping for compatibility
        name = "Walk Speed",
        type = "stat",
        icon = "🚶",
        description = "Increases walk speed",
        category = "movement",
        cost = 1,
        max_level = 5,
        requires = nil,
        graph_x = 0,
        graph_y = 0,
        stat_key = "speed",
        base_min = 1.0,
        base_max = 1.0,
        unlock_per_level = 0.2,
    },
    {
        id = "run_speed",  -- ORIGINAL
        name = "Run Speed",
        type = "stat",
        icon = "🏃",
        description = "Sprint even faster",
        category = "movement",
        cost = 1,
        max_level = 5,
        requires = "walk_speed",
        graph_x = 1,
        graph_y = 0,
        stat_key = "speed",
        unlock_per_level = 0.3,
    },
    {
        id = "jump_height",  -- ORIGINAL
        name = "Jump Height",
        type = "stat",
        icon = "⬆️",
        description = "Jump higher",
        category = "movement",
        cost = 1,
        max_level = 5,
        requires = "walk_speed",
        graph_x = 0,
        graph_y = 1,
        stat_key = "jump",
        base_min = 1.0,
        base_max = 1.0,
        unlock_per_level = 0.25,
    },
    {
        id = "super_jump",  -- ORIGINAL
        name = "Super Jump",
        type = "toggle",
        icon = "🦘",
        description = "Leap incredible distances",
        category = "movement",
        cost = 2,
        max_level = 1,
        requires = "jump_height",
        graph_x = 1,
        graph_y = 1,
        priv = nil,  -- Placeholder toggle
    },
    {
        id = "move_dash",
        name = "Dash",
        type = "toggle",
        icon = "💨",
        description = "Quick burst of speed",
        category = "movement",
        cost = 2,
        max_level = 1,
        requires = "run_speed",
        graph_x = 2,
        graph_y = 0,
        priv = nil,
    },
    {
        id = "fly_enable",  -- ORIGINAL
        name = "Flight",
        type = "toggle",
        icon = "🕊️",
        description = "Soar through the sky",
        category = "movement",
        cost = 3,
        max_level = 1,
        requires = "super_jump",
        graph_x = 2,
        graph_y = 1,
        priv = "fly",
    },
    {
        id = "fly_speed",  -- ORIGINAL
        name = "Fly Speed",
        type = "stat",
        icon = "✈️",
        description = "Fly faster (unclamped)",
        category = "movement",
        cost = 2,
        max_level = 5,
        requires = "fly_enable",
        graph_x = 3,
        graph_y = 1,
        stat_key = "speed",
        unlock_per_level = 0.4,
        unclamped = true,
    },
    {
        id = "noclip",  -- ORIGINAL
        name = "No-Clip",
        type = "toggle",
        icon = "👻",
        description = "Phase through walls",
        category = "movement",
        cost = 3,
        max_level = 1,
        requires = "fly_enable",
        graph_x = 3,
        graph_y = 2,
        priv = "noclip",
    },
    
    -- COMBAT BRANCH (middle-left)
    {
        id = "combat_melee_damage",
        name = "Melee Damage",
        type = "stat",
        icon = "⚔️",
        description = "Increase melee attack power",
        category = "combat",
        cost = 1,
        max_level = 5,
        requires = nil,
        graph_x = 0,
        graph_y = 3,
        stat_key = "melee_damage",
        base_min = 1.0,
        base_max = 1.0,
        unlock_per_level = 0.2,
    },
    {
        id = "combat_attack_speed",
        name = "Attack Speed",
        type = "stat",
        icon = "💥",
        description = "Strike faster",
        category = "combat",
        cost = 2,
        max_level = 3,
        requires = "combat_melee_damage",
        graph_x = 1,
        graph_y = 3,
        stat_key = "attack_speed",
        base_min = 1.0,
        base_max = 1.0,
        unlock_per_level = 0.15,
    },
    {
        id = "combat_defense",
        name = "Defense",
        type = "stat",
        icon = "🛡️",
        description = "Take less damage",
        category = "combat",
        cost = 1,
        max_level = 5,
        requires = "combat_melee_damage",
        graph_x = 0,
        graph_y = 4,
        stat_key = "defense",
        base_min = 1.0,
        base_max = 1.0,
        unlock_per_level = 0.1,
    },
    {
        id = "combat_critical_chance",
        name = "Critical Hit",
        type = "stat",
        icon = "🎯",
        description = "Chance for bonus damage",
        category = "combat",
        cost = 2,
        max_level = 3,
        requires = "combat_attack_speed",
        graph_x = 2,
        graph_y = 3,
        stat_key = "crit_chance",
        base_min = 0.0,
        base_max = 0.0,
        unlock_per_level = 0.1,
    },
    {
        id = "combat_ranged_damage",
        name = "Ranged Damage",
        type = "stat",
        icon = "🏹",
        description = "Boost projectile damage",
        category = "combat",
        cost = 2,
        max_level = 3,
        requires = "combat_attack_speed",
        graph_x = 2,
        graph_y = 4,
        stat_key = "ranged_damage",
        base_min = 1.0,
        base_max = 1.0,
        unlock_per_level = 0.2,
    },
    {
        id = "combat_weapon_durability",
        name = "Weapon Mastery",
        type = "stat",
        icon = "🔨",
        description = "Weapons last longer",
        category = "combat",
        cost = 1,
        max_level = 5,
        requires = "combat_defense",
        graph_x = 1,
        graph_y = 4,
        stat_key = "durability",
        base_min = 1.0,
        base_max = 1.0,
        unlock_per_level = 0.2,
    },
    
    -- SURVIVAL BRANCH (top-center)
    {
        id = "survival_max_health",
        name = "Max Health",
        type = "stat",
        icon = "❤️",
        description = "Increase maximum HP",
        category = "survival",
        cost = 1,
        max_level = 5,
        requires = nil,
        graph_x = 4,
        graph_y = 0,
        stat_key = "hp_max",
        base_min = 20,
        base_max = 20,
        unlock_per_level = 2,
    },
    {
        id = "survival_health_regen",
        name = "Regeneration",
        type = "stat",
        icon = "💚",
        description = "Heal over time",
        category = "survival",
        cost = 2,
        max_level = 3,
        requires = "survival_max_health",
        graph_x = 5,
        graph_y = 0,
        stat_key = "hp_regen",
        base_min = 0.0,
        base_max = 0.0,
        unlock_per_level = 0.5,
    },
    {
        id = "survival_hunger_resistance",
        name = "Hunger Resist",
        type = "stat",
        icon = "🍖",
        description = "Slower hunger drain",
        category = "survival",
        cost = 1,
        max_level = 5,
        requires = "survival_max_health",
        graph_x = 4,
        graph_y = 1,
        stat_key = "hunger_resist",
        base_min = 1.0,
        base_max = 1.0,
        unlock_per_level = 0.15,
    },
    {
        id = "survival_poison_resistance",
        name = "Poison Resist",
        type = "stat",
        icon = "☠️",
        description = "Resist toxic damage",
        category = "survival",
        cost = 2,
        max_level = 3,
        requires = "survival_health_regen",
        graph_x = 6,
        graph_y = 0,
        stat_key = "poison_resist",
        base_min = 0.0,
        base_max = 0.0,
        unlock_per_level = 0.3,
    },
    {
        id = "survival_fire_resistance",
        name = "Fire Resist",
        type = "stat",
        icon = "🔥",
        description = "Resist fire damage",
        category = "survival",
        cost = 2,
        max_level = 3,
        requires = "survival_poison_resistance",
        graph_x = 7,
        graph_y = 0,
        stat_key = "fire_resist",
        base_min = 0.0,
        base_max = 0.0,
        unlock_per_level = 0.3,
    },
    {
        id = "survival_armor_efficiency",
        name = "Armor Expert",
        type = "stat",
        icon = "👚",
        description = "Armor is more effective",
        category = "survival",
        cost = 2,
        max_level = 3,
        requires = "survival_hunger_resistance",
        graph_x = 5,
        graph_y = 1,
        stat_key = "armor_bonus",
        base_min = 1.0,
        base_max = 1.0,
        unlock_per_level = 0.15,
    },
    
    -- SWIMMING BRANCH (bottom-left)
    {
        id = "swim_speed",  -- ORIGINAL - repositioned
        name = "Swim Speed",
        type = "stat",
        icon = "🏊",
        description = "Swim faster",
        category = "swimming",
        cost = 1,
        max_level = 5,
        requires = nil,
        graph_x = 0,
        graph_y = 6,
        stat_key = "swim_speed",
        base_min = 1.0,
        base_max = 1.0,
        unlock_per_level = 0.2,
    },
    {
        id = "swim_underwater_breathing",
        name = "Water Breathing",
        type = "toggle",
        icon = "🐠",
        description = "Breathe underwater",
        category = "swimming",
        cost = 2,
        max_level = 1,
        requires = "swim_speed",
        graph_x = 1,
        graph_y = 6,
        priv = nil,
    },
    {
        id = "swim_water_vision",
        name = "Clear Sight",
        type = "toggle",
        icon = "👁️",
        description = "See clearly underwater",
        category = "swimming",
        cost = 2,
        max_level = 1,
        requires = "swim_underwater_breathing",
        graph_x = 2,
        graph_y = 6,
        priv = nil,
    },
    {
        id = "swim_dive_depth",
        name = "Deep Diver",
        type = "stat",
        icon = "⬇️",
        description = "Dive deeper",
        category = "swimming",
        cost = 1,
        max_level = 5,
        requires = "swim_underwater_breathing",
        graph_x = 1,
        graph_y = 7,
        stat_key = "dive_depth",
        base_min = 0.0,
        base_max = 0.0,
        unlock_per_level = 5.0,
    },
    {
        id = "swim_dolphin_grace",
        name = "Dolphin Grace",
        type = "toggle",
        icon = "🐬",
        description = "Swift underwater movement",
        category = "swimming",
        cost = 3,
        max_level = 1,
        requires = "swim_water_vision",
        graph_x = 3,
        graph_y = 6,
        priv = nil,
    },
    {
        id = "swim_water_maneuver",
        name = "Aqua Agility",
        type = "stat",
        icon = "🌊",
        description = "Better water control",
        category = "swimming",
        cost = 2,
        max_level = 3,
        requires = "swim_dive_depth",
        graph_x = 2,
        graph_y = 7,
        stat_key = "water_agility",
        base_min = 1.0,
        base_max = 1.0,
        unlock_per_level = 0.2,
    },
    
    -- STEALTH BRANCH (middle-center)
    {
        id = "stealth_silent_footsteps",
        name = "Silent Steps",
        type = "toggle",
        icon = "👣",
        description = "Move without sound",
        category = "stealth",
        cost = 2,
        max_level = 1,
        requires = nil,
        graph_x = 4,
        graph_y = 5,
        priv = nil,
    },
    {
        id = "stealth_reduced_aggro",
        name = "Reduced Aggro",
        type = "stat",
        icon = "👀",
        description = "Mobs detect you less",
        category = "stealth",
        cost = 2,
        max_level = 3,
        requires = "stealth_silent_footsteps",
        graph_x = 5,
        graph_y = 5,
        stat_key = "aggro_range",
        base_min = 1.0,
        base_max = 1.0,
        unlock_per_level = -0.15,
    },
    {
        id = "stealth_night_vision",
        name = "Night Vision",
        type = "toggle",
        icon = "🌙",
        description = "See in darkness",
        category = "stealth",
        cost = 2,
        max_level = 1,
        requires = "stealth_silent_footsteps",
        graph_x = 4,
        graph_y = 6,
        priv = nil,
    },
    {
        id = "stealth_camouflage",
        name = "Camouflage",
        type = "toggle",
        icon = "🦎",
        description = "Blend with surroundings",
        category = "stealth",
        cost = 2,
        max_level = 1,
        requires = "stealth_reduced_aggro",
        graph_x = 6,
        graph_y = 5,
        priv = nil,
    },
    {
        id = "stealth_invisibility",
        name = "Invisibility",
        type = "toggle",
        icon = "🕳️",
        description = "Become invisible",
        category = "stealth",
        cost = 3,
        max_level = 1,
        requires = "stealth_camouflage",
        graph_x = 7,
        graph_y = 5,
        priv = nil,
    },
    {
        id = "stealth_shadow_step",
        name = "Shadow Step",
        type = "toggle",
        icon = "🌑",
        description = "Teleport short distances",
        category = "stealth",
        cost = 3,
        max_level = 1,
        requires = "stealth_night_vision",
        graph_x = 5,
        graph_y = 6,
        priv = nil,
    },
    
    -- MOBILITY BRANCH (fall damage & parkour, bottom-center)
    {
        id = "mobility_feather_falling",
        name = "Feather Falling",
        type = "stat",
        icon = "🪶",
        description = "Reduce fall damage",
        category = "mobility",
        cost = 1,
        max_level = 5,
        requires = nil,
        graph_x = 4,
        graph_y = 8,
        stat_key = "fall_damage",
        base_min = 1.0,
        base_max = 1.0,
        unlock_per_level = -0.15,
    },
    {
        id = "mobility_safe_landing",
        name = "Safe Landing",
        type = "toggle",
        icon = "🪂",
        description = "No damage from any height",
        category = "mobility",
        cost = 2,
        max_level = 1,
        requires = "mobility_feather_falling",
        graph_x = 5,
        graph_y = 8,
        priv = nil,
    },
    {
        id = "mobility_roll_recovery",
        name = "Roll Recovery",
        type = "toggle",
        icon = "🤸",
        description = "Roll to absorb impact",
        category = "mobility",
        cost = 2,
        max_level = 1,
        requires = "mobility_feather_falling",
        graph_x = 4,
        graph_y = 9,
        priv = nil,
    },
    {
        id = "mobility_parkour_expert",
        name = "Parkour Expert",
        type = "toggle",
        icon = "🤺",
        description = "Master of movement",
        category = "mobility",
        cost = 3,
        max_level = 1,
        requires = "mobility_safe_landing",
        graph_x = 6,
        graph_y = 8,
        priv = nil,
    },
    {
        id = "mobility_bounce_pads",
        name = "Bounce Pads",
        type = "toggle",
        icon = "🪁",
        description = "Place bouncy platforms",
        category = "mobility",
        cost = 3,
        max_level = 1,
        requires = "mobility_roll_recovery",
        graph_x = 5,
        graph_y = 9,
        priv = nil,
    },
    {
        id = "mobility_wall_run",
        name = "Wall Run",
        type = "toggle",
        icon = "🧗",
        description = "Run along walls",
        category = "mobility",
        cost = 3,
        max_level = 1,
        requires = "mobility_roll_recovery",
        graph_x = 4,
        graph_y = 10,
        priv = nil,
    },
    
    -- UTILITY BRANCH (top-right)
    {
        id = "util_build_speed",
        name = "Build Speed",
        type = "stat",
        icon = "🛠️",
        description = "Place blocks faster",
        category = "utility",
        cost = 1,
        max_level = 5,
        requires = nil,
        graph_x = 8,
        graph_y = 0,
        stat_key = "build_speed",
        base_min = 1.0,
        base_max = 1.0,
        unlock_per_level = 0.2,
    },
    {
        id = "util_reach_distance",
        name = "Reach Distance",
        type = "stat",
        icon = "👋",
        description = "Reach further",
        category = "utility",
        cost = 2,
        max_level = 3,
        requires = "util_build_speed",
        graph_x = 9,
        graph_y = 0,
        stat_key = "reach_distance",
        base_min = 5.0,
        base_max = 5.0,
        unlock_per_level = 1.0,
    },
    {
        id = "util_inventory_size",
        name = "Bigger Bags",
        type = "stat",
        icon = "🎒",
        description = "Carry more items",
        category = "utility",
        cost = 2,
        max_level = 3,
        requires = "util_reach_distance",
        graph_x = 10,
        graph_y = 0,
        stat_key = "inventory_size",
        base_min = 32,
        base_max = 32,
        unlock_per_level = 8,
    },
    {
        id = "fast_dig",  -- ORIGINAL - repositioned
        name = "Fast Digging",
        type = "stat",
        icon = "⛏️",
        description = "Dig blocks faster",
        category = "utility",
        cost = 2,
        max_level = 3,
        requires = "util_build_speed",
        graph_x = 8,
        graph_y = 1,
        stat_key = "dig_speed",
        base_min = 1.0,
        base_max = 1.0,
        unlock_per_level = 0.3,
    },
    {
        id = "util_light_source",
        name = "Light Source",
        type = "toggle",
        icon = "💡",
        description = "Emit light around you",
        category = "utility",
        cost = 2,
        max_level = 1,
        requires = "fast_dig",
        graph_x = 9,
        graph_y = 1,
        priv = nil,
    },
    {
        id = "teleport",  -- ORIGINAL - repositioned
        name = "Teleportation",
        type = "toggle",
        icon = "🌀",
        description = "Teleport to waypoints",
        category = "utility",
        cost = 3,
        max_level = 1,
        requires = "util_light_source",
        graph_x = 10,
        graph_y = 1,
        priv = "teleport",
    },
    
    -- CRAFTING BRANCH (bottom-right)
    {
        id = "craft_unlock_recipes",
        name = "Recipe Book",
        type = "toggle",
        icon = "📖",
        description = "Unlock hidden recipes",
        category = "crafting",
        cost = 1,
        max_level = 1,
        requires = nil,
        graph_x = 8,
        graph_y = 8,
        priv = nil,
    },
    {
        id = "craft_craft_speed",
        name = "Craft Speed",
        type = "stat",
        icon = "⏱️",
        description = "Craft faster",
        category = "crafting",
        cost = 2,
        max_level = 3,
        requires = "craft_unlock_recipes",
        graph_x = 9,
        graph_y = 8,
        stat_key = "craft_speed",
        base_min = 1.0,
        base_max = 1.0,
        unlock_per_level = 0.3,
    },
    {
        id = "craft_bulk_crafting",
        name = "Bulk Crafting",
        type = "toggle",
        icon = "📦",
        description = "Craft multiple items",
        category = "crafting",
        cost = 2,
        max_level = 1,
        requires = "craft_craft_speed",
        graph_x = 10,
        graph_y = 8,
        priv = nil,
    },
    {
        id = "craft_resource_efficiency",
        name = "Efficiency",
        type = "stat",
        icon = "♻️",
        description = "Use fewer resources",
        category = "crafting",
        cost = 2,
        max_level = 3,
        requires = "craft_craft_speed",
        graph_x = 9,
        graph_y = 9,
        stat_key = "craft_efficiency",
        base_min = 1.0,
        base_max = 1.0,
        unlock_per_level = 0.1,
    },
    {
        id = "craft_auto_repair",
        name = "Auto-Repair",
        type = "toggle",
        icon = "🔧",
        description = "Tools repair slowly",
        category = "crafting",
        cost = 3,
        max_level = 1,
        requires = "craft_resource_efficiency",
        graph_x = 10,
        graph_y = 9,
        priv = nil,
    },
    {
        id = "craft_master_crafter",
        name = "Master Crafter",
        type = "toggle",
        icon = "✨",
        description = "Craft legendary items",
        category = "crafting",
        cost = 3,
        max_level = 1,
        requires = "craft_bulk_crafting",
        graph_x = 10,
        graph_y = 10,
        priv = nil,
    },
    
    -- LEGACY: Keep crouch_speed for backward compat but move off-grid
    {
        id = "crouch_speed",  -- ORIGINAL - moved to corner
        name = "Sneak Speed",
        type = "stat",
        icon = "🐢",
        description = "Move faster while crouching",
        category = "utility",
        cost = 1,
        max_level = 3,
        requires = nil,
        graph_x = 0,
        graph_y = 2,
        stat_key = "sneak_speed",
        base_min = 0.3,
        base_max = 0.3,
        unlock_per_level = 0.15,
    },
}

-- Build lookup tables
local ability_by_id = {}
for _, ability in ipairs(abilities) do
    ability_by_id[ability.id] = ability
end

-- Get player ability data
local function get_ability_data(player)
    local meta = player:get_meta()
    local data_str = meta:get_string("abilities_v2")
    if data_str == "" then data_str = "{}" end
    local data = minetest.deserialize(data_str) or {}
    
    if not data.unlocked then
        data.unlocked = {}  -- {ability_id = level}
        data.stat_points = 0
        data.stat_values = {}  -- {stat_key = value}
        data.toggles = {}  -- {ability_id = true/false}
        data.scroll_x = 0  -- Horizontal scroll position (0-1000)
        data.scroll_y = 0  -- Vertical scroll position (0-1000)
    end
    data.scroll_x = data.scroll_x or 0
    data.scroll_y = data.scroll_y or 0
    
    return data
end

-- Save ability data
local function save_ability_data(player, data)
    local meta = player:get_meta()
    meta:set_string("abilities_v2", minetest.serialize(data))
end

-- Calculate stat range based on unlocked abilities
local function get_stat_range(player, stat_key)
    local data = get_ability_data(player)
    local min_val = 1.0
    local max_val = 1.0
    local unclamped = false
    
    for _, ability in ipairs(abilities) do
        if ability.type == "stat" and ability.stat_key == stat_key then
            local level = data.unlocked[ability.id] or 0
            if level > 0 then
                if ability.base_min then
                    min_val = math.min(min_val, ability.base_min)
                end
                if ability.base_max then
                    max_val = math.max(max_val, ability.base_max + (ability.unlock_per_level * level))
                end
                if ability.unclamped then
                    unclamped = true
                end
            end
        end
    end
    
    return min_val, max_val, unclamped
end

-- Apply stat values to player
local function apply_stats(player)
    local data = get_ability_data(player)
    
    -- Apply speed
    local speed = data.stat_values.speed or 1.0
    local jump = data.stat_values.jump or 1.0
    
    player:set_physics_override({
        speed = speed,
        jump = jump,
    })
end

-- Apply toggle abilities
local function apply_toggles(player)
    local data = get_ability_data(player)
    local privs = minetest.get_player_privs(player:get_player_name())
    
    for _, ability in ipairs(abilities) do
        if ability.type == "toggle" and ability.priv then
            local level = data.unlocked[ability.id] or 0
            if level > 0 then
                -- Ability unlocked, check toggle state
                if data.toggles[ability.id] then
                    privs[ability.priv] = true
                else
                    privs[ability.priv] = nil
                end
            end
        end
    end
    
    minetest.set_player_privs(player:get_player_name(), privs)
end

-- Generate ability graph formspec
function get_ability_formspec_new(player)
    local data = get_ability_data(player)
    local exp = tonumber(player:get_meta():get_string("experience")) or 0
    local level = math.floor(exp / 100) + 1
    
    -- Get player model info
    local player_textures = player_api.get_textures(player) or {"character.png"}
    
    local formspec = {
        "formspec_version[4]",
        "size[14,11]",
        "bgcolor[#0a0a0aff;true]",
        
        -- 3D Player Model Preview (square, static)
        "box[0.2,0.3;1.5,1.5;#1a1a1aff]",
        "model[0.3,0.4;1.3,1.3;player_preview;character.b3d;" .. table.concat(player_textures, ",") .. ";0,170;false;true;0,0]",
        
        -- Header
        "box[0.2,2;13.6,0.6;#2a2a2aff]",
        "label[0.5,2.3;⚡ Abilities - Level " .. level .. "]",
        "label[10,2.3;Stat Points: " .. data.stat_points .. "]",
    }
    
    -- LEFT SIDE: Stat Sliders & Toggle List
    table.insert(formspec, "box[0.2,2.8;4.5,7.9;#1a1a1aff]")
    table.insert(formspec, "label[0.5,3.1;📊 Stats & Abilities]")
    
    local y = 3.5
    
    -- Stat sliders for each stat type
    local stat_types = {
        {key = "speed", label = "Movement Speed", icon = "🏃"},
        {key = "jump", label = "Jump Height", icon = "⬆️"},
        {key = "sneak_speed", label = "Crouch Speed", icon = "🐢"},
        {key = "swim_speed", label = "Swim Speed", icon = "🏊"},
    }
    
    for _, stat in ipairs(stat_types) do
        local min_val, max_val, unclamped = get_stat_range(player, stat.key)
        local current = data.stat_values[stat.key] or 1.0
        
        -- Clamp current value to range (unless unclamped)
        if not unclamped then
            current = math.max(min_val, math.min(max_val, current))
        end
        
        table.insert(formspec, string.format("label[0.5,%f;%s %s]", y, stat.icon, stat.label))
        table.insert(formspec, string.format("field[0.5,%f;1.8,0.5;stat_%s;;%.2f]", y + 0.3, stat.key, current))
        table.insert(formspec, string.format("field_close_on_enter[stat_%s;false]", stat.key))
        table.insert(formspec, string.format("button[2.4,%f;1,0.5;set_%s;Set]", y + 0.3, stat.key))
        
        if unclamped then
            table.insert(formspec, string.format("label[3.5,%f;∞]", y + 0.5))
        else
            table.insert(formspec, string.format("label[3.5,%f;%.1f-%.1f]", y + 0.5, min_val, max_val))
        end
        
        y = y + 1
    end
    
    -- Toggle abilities list
    y = y + 0.3
    table.insert(formspec, string.format("label[0.5,%f;🔘 Toggle Abilities]", y))
    y = y + 0.4
    
    for _, ability in ipairs(abilities) do
        if ability.type == "toggle" then
            local level = data.unlocked[ability.id] or 0
            if level > 0 then
                local enabled = data.toggles[ability.id] or false
                local checkbox = enabled and "☑" or "☐"
                table.insert(formspec, string.format("button[0.5,%f;4,0.5;toggle_%s;%s %s %s]", 
                    y, ability.id, checkbox, ability.icon, ability.name))
                y = y + 0.6
            end
        end
    end
    
    -- RIGHT SIDE: Ability Graph
    table.insert(formspec, "box[4.9,2.8;8.9,7.9;#0a0a0aff]")
    table.insert(formspec, "label[5.2,3.1;🗺️ Ability Tree (Use D-pad to pan)]")
    
    -- Graph rendering area
    local graph_x = 5.1
    local graph_y = 3.5
    local graph_w = 8.2
    local graph_h = 7.0
    local node_size = 0.8
    local grid_spacing_x = 2.0
    local grid_spacing_y = 1.8
    
    -- Calculate total graph size
    local max_x = 0
    local max_y = 0
    for _, ability in ipairs(abilities) do
        max_x = math.max(max_x, ability.graph_x)
        max_y = math.max(max_y, ability.graph_y)
    end
    local total_width = (max_x + 1) * grid_spacing_x + node_size
    local total_height = (max_y + 1) * grid_spacing_y + node_size
    
    -- Get current scroll offsets (0-1000 range from scrollbar)
    local scroll_x = tonumber(data.scroll_x) or 0
    local scroll_y = tonumber(data.scroll_y) or 0
    
    -- Convert to pixel offsets
    local max_offset_x = math.max(0, total_width - graph_w)
    local max_offset_y = math.max(0, total_height - graph_h)
    local offset_x = -(scroll_x / 1000) * max_offset_x
    local offset_y = -(scroll_y / 1000) * max_offset_y
    
    -- Clip box for graph area
    table.insert(formspec, string.format("box[%f,%f;%f,%f;#0a0a2aff]", graph_x, graph_y, graph_w, graph_h))
    
    -- Draw edges first (so nodes are on top)
    for _, ability in ipairs(abilities) do
        if ability.requires then
            local parent = ability_by_id[ability.requires]
            if parent then
                local unlocked = (data.unlocked[ability.id] or 0) > 0
                local parent_unlocked = (data.unlocked[parent.id] or 0) > 0
                
                local x1 = graph_x + offset_x + parent.graph_x * grid_spacing_x + node_size / 2
                local y1 = graph_y + offset_y + parent.graph_y * grid_spacing_y + node_size / 2
                local x2 = graph_x + offset_x + ability.graph_x * grid_spacing_x + node_size / 2
                local y2 = graph_y + offset_y + ability.graph_y * grid_spacing_y + node_size / 2
                
                -- Only draw if visible in viewport
                if x1 >= graph_x - 0.5 and x1 <= graph_x + graph_w + 0.5 and
                   y1 >= graph_y - 0.5 and y1 <= graph_y + graph_h + 0.5 then
                    -- Draw line as series of boxes
                    local steps = 20
                    for i = 0, steps do
                        local t = i / steps
                        local x = x1 + (x2 - x1) * t
                        local y = y1 + (y2 - y1) * t
                        
                        local color = (unlocked and parent_unlocked) and "#4a9a4aff" or "#3a3a3aff"
                        table.insert(formspec, string.format("box[%f,%f;0.05,0.05;%s]", x, y, color))
                    end
                end
            end
        end
    end
    
    -- Draw nodes
    for _, ability in ipairs(abilities) do
        local x = graph_x + offset_x + ability.graph_x * grid_spacing_x
        local y = graph_y + offset_y + ability.graph_y * grid_spacing_y
        
        -- Only draw if visible in viewport
        if x + node_size >= graph_x + 0.7  and x <= graph_x + graph_w and
           y + node_size >= graph_y + 0.7 and y <= graph_y + graph_h - 0.7 then
            
            local level = data.unlocked[ability.id] or 0
            local unlocked = level > 0
            
            -- Check if can unlock
            local can_unlock = true
            if ability.requires then
                local req_level = data.unlocked[ability.requires] or 0
                can_unlock = req_level > 0
            end
            can_unlock = can_unlock and data.stat_points >= (ability.cost or 1)
            
            -- Node background
            local bg_color
            if unlocked then
                bg_color = "#2a5a2aff"  -- Green
            elseif can_unlock then
                bg_color = "#5a5a2aff"  -- Yellow
            else
                bg_color = "#2a2a2aff"  -- Gray
            end
            
            table.insert(formspec, string.format("box[%f,%f;%f,%f;%s]", x, y, node_size, node_size, bg_color))
            
            -- Node button with icon
            table.insert(formspec, string.format("button[%f,%f;%f,%f;node_%s;%s]", 
                x, y, node_size, node_size, ability.id, ability.icon))
            
            -- Level indicator
            if unlocked then
                if ability.max_level and ability.max_level > 1 then
                    table.insert(formspec, string.format("label[%f,%f;%d/%d]", 
                        x + 0.05, y + node_size - 0.2, level, ability.max_level))
                else
                    table.insert(formspec, string.format("label[%f,%f;✓]", 
                        x + 0.3, y + node_size - 0.2))
                end
            end
        end
    end
    
    -- D-pad navigation controls (5-button cross layout)
    -- Position inside left side of map to avoid overlap
    local dp_cx = graph_x + 0.75
    local dp_cy = 1
    local btn_size = 0.7
    local btn_gap = 0.8
    
    -- D-pad buttons
    table.insert(formspec, string.format("button[%f,%f;%f,%f;nav_up;↑]", 
        dp_cx, dp_cy - btn_gap, btn_size, btn_size))
    table.insert(formspec, string.format("button[%f,%f;%f,%f;nav_down;↓]", 
        dp_cx, dp_cy + btn_gap, btn_size, btn_size))
    table.insert(formspec, string.format("button[%f,%f;%f,%f;nav_left;←]", 
        dp_cx - btn_gap, dp_cy, btn_size, btn_size))
    table.insert(formspec, string.format("button[%f,%f;%f,%f;nav_right;→]", 
        dp_cx + btn_gap, dp_cy, btn_size, btn_size))
    table.insert(formspec, string.format("button[%f,%f;%f,%f;nav_reset;⊚]", 
        dp_cx, dp_cy, btn_size, btn_size))
    
    -- Tooltip area (click nodes to see info here)
    table.insert(formspec, "box[0.2,10.5;13.6,0.3;#2a2a2aff]")
    local tooltip_text = data.tooltip or "Click nodes for info"
    table.insert(formspec, string.format("label[0.5,10.7;%s]", minetest.formspec_escape(tooltip_text)))
    
    return table.concat(formspec, "")
end

-- Handle formspec input
minetest.register_on_player_receive_fields(function(player, formname, fields)
    -- Handle both standalone and unified inventory
    if formname ~= "ability_tree_new" and formname ~= "" and formname ~= "unified_inventory" then
        return
    end
    
    -- Only process if we're on abilities tab in unified inventory
    if (formname == "" or formname == "unified_inventory") then
        local current_tab = player:get_meta():get_string("current_tab")
        if current_tab ~= "abilities" then
            return
        end
    end
    
    if fields.quit then
        return
    end
    
    local data = get_ability_data(player)
    local name = player:get_player_name()
    local changed = false
    
    -- Handle stat value changes
    for _, stat in ipairs({{"speed"}, {"jump"}, {"sneak_speed"}, {"swim_speed"}}) do
        local key = stat[1]
        if fields["set_" .. key] and fields["stat_" .. key] then
            local value = tonumber(fields["stat_" .. key])
            if value then
                local min_val, max_val, unclamped = get_stat_range(player, key)
                
                -- Clamp unless unclamped
                if not unclamped then
                    value = math.max(min_val, math.min(max_val, value))
                end
                
                data.stat_values[key] = value
                changed = true
                apply_stats(player)
            end
        end
    end
    
    -- Handle toggle abilities
    for _, ability in ipairs(abilities) do
        if ability.type == "toggle" and fields["toggle_" .. ability.id] then
            data.toggles[ability.id] = not (data.toggles[ability.id] or false)
            changed = true
            apply_toggles(player)
        end
    end
    
    -- Handle node clicks (unlock/upgrade or show tooltip)
    for _, ability in ipairs(abilities) do
        if fields["node_" .. ability.id] then
            local current_level = data.unlocked[ability.id] or 0
            local max_level = ability.max_level or 1
            
            -- Build tooltip text
            local tooltip = string.format("%s %s | Cost: %d SP | Level: %d/%d", 
                ability.icon, ability.name, ability.cost or 1, current_level, max_level or 1)
            if ability.requires then
                tooltip = tooltip .. " | Requires: " .. ability_by_id[ability.requires].name
            end
            tooltip = tooltip .. " | " .. ability.description
            data.tooltip = tooltip
            changed = true
            
            -- Try to unlock if shift-clicked or right-clicked
            if current_level < max_level then
                -- Check requirements
                local can_unlock = true
                if ability.requires then
                    local req_level = data.unlocked[ability.requires] or 0
                    if req_level == 0 then
                        can_unlock = false
                        minetest.chat_send_player(name, "❌ Requires: " .. ability_by_id[ability.requires].name)
                    end
                end
                
                -- Check stat points
                local cost = ability.cost or 1
                if data.stat_points < cost then
                    can_unlock = false
                    minetest.chat_send_player(name, "❌ Need " .. cost .. " stat points!")
                end
                
                if can_unlock then
                    data.unlocked[ability.id] = current_level + 1
                    data.stat_points = data.stat_points - cost
                    changed = true
                    
                    minetest.chat_send_player(name, "✨ Unlocked: " .. ability.name .. " Level " .. (current_level + 1) .. "!")
                    data.tooltip = string.format("✨ Unlocked %s to Level %d!", ability.name, current_level + 1)
                    
                    -- Grant achievement for first ability
                    if achievement_progress then
                        achievement_progress(player, "unlock_first_ability", 1)
                    end
                end
            end
        end
    end
    
    -- Handle D-pad navigation for graph panning
    if fields.nav_up then
        data.scroll_y = math.max(0, data.scroll_y - PAN_STEP)
        changed = true
    elseif fields.nav_down then
        -- Calculate max scroll based on graph size
        local max_x = 0
        local max_y = 0
        for _, ability in ipairs(abilities) do
            max_x = math.max(max_x, ability.graph_x)
            max_y = math.max(max_y, ability.graph_y)
        end
        local grid_spacing_y = 1.8
        local graph_h = 7.0
        local total_height = (max_y + 1) * grid_spacing_y + 0.8
        local max_offset_y = math.max(0, total_height - graph_h)
        local max_scroll_y = 1000
        
        data.scroll_y = math.min(max_scroll_y, data.scroll_y + PAN_STEP)
        changed = true
    elseif fields.nav_left then
        data.scroll_x = math.max(0, data.scroll_x - PAN_STEP)
        changed = true
    elseif fields.nav_right then
        -- Calculate max scroll based on graph size
        local max_x = 0
        for _, ability in ipairs(abilities) do
            max_x = math.max(max_x, ability.graph_x)
        end
        local grid_spacing_x = 2.0
        local graph_w = 8.2
        local total_width = (max_x + 1) * grid_spacing_x + 0.8
        local max_offset_x = math.max(0, total_width - graph_w)
        local max_scroll_x = 1000
        
        data.scroll_x = math.min(max_scroll_x, data.scroll_x + PAN_STEP)
        changed = true
    elseif fields.nav_reset then
        data.scroll_x = 0
        data.scroll_y = 0
        changed = true
    end
    
    if changed then
        save_ability_data(player, data)
    end
    
    -- Refresh formspec (use unified inventory if that's where we are)
    if formname == "" or formname == "unified_inventory" then
        if get_unified_inventory then
            player:set_inventory_formspec(get_unified_inventory(player))
        end
    else
        minetest.show_formspec(name, "ability_tree_new", get_ability_formspec_new(player))
    end
end)

-- Chat command to open new abilities screen
minetest.register_chatcommand("abilities2", {
    description = "Open new advanced abilities screen",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if player then
            minetest.show_formspec(name, "ability_tree_new", get_ability_formspec_new(player))
            return true, "Opening abilities!"
        end
        return false, "Player not found"
    end
})

-- Hook into experience system to grant stat points on level up
local original_give_experience = give_experience
if original_give_experience then
    function give_experience(player, amount)
        local name = player:get_player_name()
        local meta = player:get_meta()
        local old_exp = tonumber(meta:get_string("experience")) or 0
        local old_level = math.floor(old_exp / 100) + 1
        
        -- Call original function
        local leveled_up = original_give_experience(player, amount)
        
        if leveled_up then
            -- Grant 3 stat points per level (generous for the big tree!)
            local data = get_ability_data(player)
            data.stat_points = data.stat_points + 3
            save_ability_data(player, data)
            
            minetest.chat_send_player(name, 
                "🌟 Gained 3 stat points! Press I and click the ⚡ tab to spend them!")
        end
        
        return leveled_up
    end
end

-- Admin command to give stat points directly
minetest.register_chatcommand("givestatpoints", {
    params = "<player> <amount>",
    description = "Give stat points to a player",
    privs = {server = true},
    func = function(name, param)
        local target_name, amount_str = param:match("^(%S+)%s+(%S+)$")
        if not target_name or not amount_str then
            return false, "Usage: /givestatpoints <player> <amount>"
        end
        
        local amount = tonumber(amount_str)
        if not amount then
            return false, "Invalid amount"
        end
        
        local target = minetest.get_player_by_name(target_name)
        if not target then
            return false, "Player not found"
        end
        
        local data = get_ability_data(target)
        data.stat_points = data.stat_points + amount
        save_ability_data(target, data)
        
        minetest.chat_send_player(target_name, 
            string.format("✨ You received %d stat points!", amount))
        return true, string.format("Gave %d stat points to %s", amount, target_name)
    end
})

-- Apply abilities on join
minetest.register_on_joinplayer(function(player)
    minetest.after(1, function()
        if minetest.get_player_by_name(player:get_player_name()) then
            apply_stats(player)
            apply_toggles(player)
        end
    end)
end)

minetest.log("action", "[ability_system_new] Advanced ability system with 48 abilities loaded! ⚡✨")
