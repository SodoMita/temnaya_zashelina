-- Labyrinth generation: rooms, corridors, maze layout

labyrinth.generation = {}

-- Register with zone manager (will be called by dumbgen2)
function labyrinth.generation.generate(ctx)
	-- TODO: Implement maze generation
	-- This will be called by the dumbgen2 orchestrator
	-- ctx contains: vm, data, param2, area, minp, maxp, zone bounds, prng, etc.
	
	minetest.log("action", "[labyrinth] Generation called for zone at " .. 
		minetest.pos_to_string({x = ctx.zx, y = 0, z = ctx.zz}))
end

-- Register the generator with the zone system (once dumbgen2 provides the API)
if temz_zones and temz_zones.register_generator then
	temz_zones.register_generator("labyrinth", {
		y_min = 0,
		y_max = 20,
		generate = labyrinth.generation.generate,
	})
end

minetest.log("action", "[labyrinth] Generation module loaded")
