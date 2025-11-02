-- Key fragment system for factory doors

-- Tier 1 key fragment (basic access)
minetest.register_craftitem("factory:key_fragment_t1", {
	description = "Tier 1 Key Fragment\nCollect these to unlock basic factory areas",
	inventory_image = "default_bronze_ingot.png^[colorize:cyan:100",  -- Placeholder
	stack_max = 99,
})

-- Tier 2 key fragment (mid-level access)
minetest.register_craftitem("factory:key_fragment_t2", {
	description = "Tier 2 Key Fragment\nCollect these to unlock deeper factory sections",
	inventory_image = "default_steel_ingot.png^[colorize:yellow:100",  -- Placeholder
	stack_max = 99,
})

-- Tier 3 key fragment (core access)
minetest.register_craftitem("factory:key_fragment_t3", {
	description = "Tier 3 Key Fragment\nCollect these to unlock the factory core",
	inventory_image = "default_gold_ingot.png^[colorize:red:100",  -- Placeholder
	stack_max = 99,
})

-- Helper function to count key fragments in inventory
function factory.count_key_fragments(player, tier)
	if not player or not player:is_player() then
		return 0
	end
	
	local inv = player:get_inventory()
	if not inv then
		return 0
	end
	
	local item_name = "factory:key_fragment_t" .. tier
	local count = 0
	
	-- Count fragments in main inventory
	for i = 1, inv:get_size("main") do
		local stack = inv:get_stack("main", i)
		if stack:get_name() == item_name then
			count = count + stack:get_count()
		end
	end
	
	return count
end

minetest.log("action", "[factory] Key fragment system initialized")
