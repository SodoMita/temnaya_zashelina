-- Progressive locked doors for factory

-- Default required fragment counts (can be overridden in settings)
factory.required_fragments = {
	t1 = tonumber(minetest.settings:get("temz.factory_fragments_t1")) or 3,
	t2 = tonumber(minetest.settings:get("temz.factory_fragments_t2")) or 6,
	t3 = tonumber(minetest.settings:get("temz.factory_fragments_t3")) or 10,
}

-- Consume fragments setting
factory.consume_fragments = minetest.settings:get_bool("temz.factory_consume_fragments", false)

-- Helper function to create door pair
local function register_factory_door(tier, required_count, description, tile)
	local closed_name = "factory:door_t" .. tier .. "_closed"
	local open_name = "factory:door_t" .. tier .. "_open"
	
	-- Closed door
	minetest.register_node(closed_name, {
		description = description .. " (Tier " .. tier .. ")\nRequires " .. required_count .. " fragments",
		tiles = {tile},
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {cracky = 1},
		sounds = default.node_sound_metal_defaults(),
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.125, 0.5, 1.5, 0.125}
		},
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			if not clicker or not clicker:is_player() then
				return itemstack
			end
			
			-- Check if player has enough fragments
			local count = factory.count_key_fragments(clicker, tier)
			
			if count >= required_count then
				-- Open the door
				minetest.sound_play("default_dig_metal", {pos = pos, gain = 0.5, max_hear_distance = 10})
				node.name = open_name
				minetest.set_node(pos, node)
				
				-- Optionally consume fragments
				if factory.consume_fragments then
					local inv = clicker:get_inventory()
					local item_name = "factory:key_fragment_t" .. tier
					inv:remove_item("main", item_name .. " " .. required_count)
					minetest.chat_send_player(clicker:get_player_name(), 
						"Used " .. required_count .. " Tier " .. tier .. " fragments")
				end
				
				-- Auto-close after 10 seconds
				minetest.after(10, function()
					local current_node = minetest.get_node(pos)
					if current_node.name == open_name then
						current_node.name = closed_name
						minetest.set_node(pos, current_node)
						minetest.sound_play("default_dig_metal", {pos = pos, gain = 0.3, max_hear_distance = 10})
					end
				end)
			else
				minetest.chat_send_player(clicker:get_player_name(), 
					"Door locked. Need " .. required_count .. " Tier " .. tier .. 
					" fragments (you have " .. count .. ")")
			end
			
			return itemstack
		end,
	})
	
	-- Open door
	minetest.register_node(open_name, {
		description = description .. " (Open)",
		tiles = {tile .. "^[opacity:128"},
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {cracky = 1, not_in_creative_inventory = 1},
		sounds = default.node_sound_metal_defaults(),
		walkable = false,
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, -0.375, 1.5, 0.5}
		},
		drop = closed_name,
	})
end

-- Register three tiers of doors
register_factory_door(1, factory.required_fragments.t1, "Factory Door T1", "default_steel_block.png")
register_factory_door(2, factory.required_fragments.t2, "Factory Door T2", "default_bronze_block.png")
register_factory_door(3, factory.required_fragments.t3, "Factory Door T3", "default_gold_block.png")

minetest.log("action", "[factory] Doors registered")
