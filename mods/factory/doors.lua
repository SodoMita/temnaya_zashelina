-- Progressive locked doors for factory, converted to sliding entities
local S = minetest.get_translator("factory")

-- Default required fragment counts (can be overridden in settings)
factory.required_fragments = {
	t1 = tonumber(minetest.settings:get("temz.factory_fragments_t1")) or 3,
	t2 = tonumber(minetest.settings:get("temz.factory_fragments_t2")) or 6,
	t3 = tonumber(minetest.settings:get("temz.factory_fragments_t3")) or 10,
}

-- Consume fragments setting
factory.consume_fragments = minetest.settings:get_bool("temz.factory_consume_fragments", false)

-- Collider entity for sliding doors
minetest.register_entity("factory:sliding_door_collider", {
	initial_properties = {
		visual = "sprite",
		textures = {"blank.png"},
		collisionbox = {-0.5, 0.0, -0.125, 0.5, 2.0, 0.125},
		physical = true,
		pointable = false,
		static_save = false,
	},
	on_activate = function(self)
		minetest.after(0, function()
			if not self.object:get_attach() then self.object:remove() end
		end)
	end,
	on_step = function(self)
		if not self.object:get_attach() then self.object:remove() end
	end,
})

-- Sliding door entity definition
minetest.register_entity("factory:sliding_door_entity", {
	initial_properties = {
		visual = "mesh",
		mesh = "door.obj",
		visual_size = vector.new(10,10,10),
		collisionbox = {-0.5, -0.5, -0.125, 0.5, 1.5, 0.125},
		physical = false,
		pointable = false,
		static_save = true,
	},
	_state = "closed",
	_animating = false,
	_dir = {x=1,y=0,z=0},
	_speed = 3,
	_target_pos = nil,
	_last_toggle = 0,
	_auto_at = nil,

	on_activate = function(self, staticdata)
		local data = minetest.deserialize(staticdata or "") or {}
		self.anchor_pos = data.pos or self.object:get_pos()
		self.tier = data.tier or 1

		local node = minetest.get_node(self.anchor_pos)
		local param2 = node.param2 or 0
		local rot = param2 % 4
		if rot == 0 or rot == 2 then
			self._dir = {x=1,y=0,z=0}
			self.object:set_yaw(0)
		else
			self._dir = {x=0,y=0,z=1}
			self.object:set_yaw(math.pi/2)
		end

		if #self.object:get_children() == 0 then
			local cb = minetest.add_entity(self.object:get_pos(), "factory:sliding_door_collider")
			if cb then cb:set_attach(self.object) end
		end

		local base = vector.add(self.anchor_pos, {x=0,y=-0.5,z=0})
		if minetest.get_meta(self.anchor_pos):get_string("open") == "true" then
			local open_pos = vector.add(base, vector.multiply(self._dir, 0.850))
			self.object:set_pos(open_pos)
			self._state = "open"
		else
			self.object:set_pos(base)
			self._state = "closed"
		end

		-- Set texture based on tier
		local texture = "default_steel_block.png"
		if self.tier == 2 then
			texture = "default_bronze_block.png"
		elseif self.tier == 3 then
			texture = "default_gold_block.png"
		end
		self.object:set_properties({textures={texture}})
	end,

	get_staticdata = function(self)
		return minetest.serialize({pos = self.anchor_pos, tier = self.tier})
	end,

	on_step = function(self, dtime)
		self._anchor_check = (self._anchor_check or 0) + dtime
		if self._anchor_check > 0.5 then
			self._anchor_check = 0
			local n = minetest.get_node(self.anchor_pos)
			if not n or not string.find(n.name, "factory:door_t") then
				for _, ch in ipairs(self.object:get_children() or {}) do ch:remove() end
				self.object:remove()
				return
			end
		end

		if not self._target_pos then return end
		local pos = self.object:get_pos()
		local to_target = vector.subtract(self._target_pos, pos)
		local dist = vector.length(to_target)
		local step = self._speed * dtime
		if dist < 0.01 or step >= dist then
			self.object:set_pos(self._target_pos)
			self._target_pos = nil
			self._animating = false
		else
			local dir_norm = vector.normalize(to_target)
			local delta = vector.multiply(dir_norm, step)
			self.object:set_pos(vector.add(pos, delta))
		end
	end,

	_try_auto_close = function(self)
		if not self.object or self._state ~= "open" then return end

		if self._auto_at and minetest.get_gametime() < self._auto_at then
			minetest.after(1, function() if self and self._try_auto_close then self:_try_auto_close() end end)
			return
		end

		local pos = self.anchor_pos
		local objs = minetest.get_objects_inside_radius(pos, 1.5)
		local can_close = true
		for _, obj in ipairs(objs) do
			local le = obj:get_luaentity()
			if obj:is_player() or (le and not string.find(le.name, "factory:sliding_door")) then
				can_close = false
				break
			end
		end

		if can_close then
			self:_close()
		else
			self._auto_at = minetest.get_gametime() + 1
			minetest.after(1, function() if self and self._try_auto_close then self:_try_auto_close() end end)
		end
	end,

	_open = function(self, force)
		local now = minetest.get_gametime()
		if (self._state == "open" and not force) or (not force and now - self._last_toggle < 0.2) then return end
		self._last_toggle = now
		self._animating = true
		minetest.sound_play("default_dig_metal", {pos = self.object:get_pos(), gain = 0.5, max_hear_distance = 10})
		self._target_pos = vector.add(vector.add(self.anchor_pos, {x=0,y=-0.5,z=0}), vector.multiply(self._dir, 0.850))
		self._state = "open"
		minetest.get_meta(self.anchor_pos):set_string("open", "true")
		self._auto_at = now + 8
		minetest.after(8, function() if self and self._try_auto_close then self:_try_auto_close() end end)
	end,

	_close = function(self, force)
		local now = minetest.get_gametime()
		if (self._state == "closed" and not force) or (not force and now - self._last_toggle < 0.2) then return end
		self._last_toggle = now
		self._animating = true
		minetest.sound_play("default_dig_metal", {pos = self.object:get_pos(), gain = 0.3, max_hear_distance = 10})
		self._target_pos = vector.add(self.anchor_pos, {x=0,y=-0.5,z=0})
		self._state = "closed"
		minetest.get_meta(self.anchor_pos):set_string("open", "false")
		self._auto_at = nil
	end,
})

-- Helper to register a tiered door anchor
local function register_factory_door_anchor(tier, required_count, description, tile)
	local name = "factory:door_t" .. tier
	minetest.register_node(name, {
		description = description,
		tiles = {"blank.png"},
		drawtype = "airlike",
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {dig_immediate=2},
		selection_box = {
			type = "fixed",
			fixed = { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 },
		},

		on_construct = function(pos)
			minetest.add_entity(pos, "factory:sliding_door_entity", minetest.serialize{pos=pos, tier=tier})
		end,

	on_destruct = function(pos)
			pcall(function()
				for _, obj in pairs(minetest.get_objects_inside_radius(pos, 2.5)) do
					if not obj then goto continue end
					local le = obj:get_luaentity()
					if le and le.name == "factory:sliding_door_entity" and le.anchor_pos and vector.equals(le.anchor_pos, pos) then
						for _, ch in ipairs(obj:get_children() or {}) do 
							if ch then pcall(function() ch:remove() end) end
						end
						pcall(function() obj:remove() end)
					end
					::continue::
				end
			end)
	end,

		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			if not clicker or not clicker:is_player() then return end
			
			local player_name = clicker:get_player_name()
			if not player_name then return end
			
			local count = factory.count_key_fragments(clicker, tier)
			if count >= required_count then
				for _, obj in pairs(minetest.get_objects_inside_radius(pos, 2.1)) do
					local e = obj:get_luaentity()
					if e and e.name == "factory:sliding_door_entity" then
						if e._state == "open" then e:_close(true) else e:_open(true) end
						break
					end
				end

				if factory.consume_fragments and not minetest.get_meta(pos):get_string("unlocked") then
					local inv = clicker:get_inventory()
					if inv then
						inv:remove_item("main", "factory:key_fragment_t"..tier.." "..required_count)
						minetest.chat_send_player(player_name, S("Used @1 Tier @2 fragments", tostring(required_count), tostring(tier)))
						minetest.get_meta(pos):set_string("unlocked", "true")
					end
				end
			else
				minetest.chat_send_player(player_name,
					S("Door locked. Need @1 Tier @2 fragments (you have @3)",
						tostring(required_count), tostring(tier), tostring(count)))
			end
		end,
	})
end

-- Register three tiers of doors
register_factory_door_anchor(1, factory.required_fragments.t1, "Factory Door T1", "default_steel_block.png")
register_factory_door_anchor(2, factory.required_fragments.t2, "Factory Door T2", "default_bronze_block.png")
register_factory_door_anchor(3, factory.required_fragments.t3, "Factory Door T3", "default_gold_block.png")

minetest.register_lbm({
	label = "Spawn factory sliding door entities",
	name = "factory:spawn_sliding_door_entities",
	nodenames = {"factory:door_t1", "factory:door_t2", "factory:door_t3"},
	run_at_every_load = true,
	action = function(pos, node)
		local name_parts = string.split(node.name, "_")
		local tier = tonumber(name_parts[#name_parts])
		if not tier then return end

		local param2 = (node.param2 or 0) % 4
		local dir = (param2 == 0 or param2 == 2) and {x=1,y=0,z=0} or {x=0,y=0,z=1}
		local base = vector.add(pos, {x=0,y=-0.5,z=0})
		local open_pos = vector.add(base, vector.multiply(dir, 0.9))
		local minp = vector.new(math.min(base.x, open_pos.x)-0.6, base.y-0.1, math.min(base.z, open_pos.z)-0.6)
		local maxp = vector.new(math.max(base.x, open_pos.x)+0.6, base.y+2.1, math.max(base.z, open_pos.z)+0.6)

		local matches = {}
		for _, obj in ipairs(minetest.get_objects_in_area(minp, maxp)) do
			local le = obj and obj:get_luaentity()
			if le and le.name == "factory:sliding_door_entity" and le.anchor_pos and vector.equals(le.anchor_pos, pos) then
				table.insert(matches, obj)
			end
		end

		if #matches == 0 then
			minetest.add_entity(pos, "factory:sliding_door_entity", minetest.serialize{pos=pos, tier=tier})
		elseif #matches > 1 then
			for i=2, #matches do
				for _, ch in ipairs(matches[i]:get_children() or {}) do ch:remove() end
				matches[i]:remove()
			end
		end
	end
})

minetest.log("action", "[factory] Sliding doors registered")
