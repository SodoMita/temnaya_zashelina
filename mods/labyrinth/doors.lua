-- Sliding doors for labyrinth (non-locked, atmospheric)

-- Register ghost trigger node (invisible marker in walls)
minetest.register_node("labyrinth:ghost_trigger", {
	description = "Ghost Trigger (invisible)",
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	groups = {not_in_creative_inventory = 1},
})

-- Register sliding door - closed state
minetest.register_node("labyrinth:slide_door_anchor", {
	description = "Sliding Door Anchor",
	drawtype = "airlike",
	walkable = false,
	pointable = true,
	sunlight_propagates = true,
	paramtype = "light",
	selection_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 }, -- 2 nodes tall for easy clicking
	},
	groups = {dig_immediate=2},
	on_construct = function(pos)
		minetest.add_entity(pos, "labyrinth:sliding_door_entity", minetest.serialize{pos = pos})
	end,
on_destruct = function(pos)
		-- Remove any door entities bound to this anchor, whether closed or slid open
		for _, obj in pairs(minetest.get_objects_inside_radius(pos, 2.5)) do
			local le = obj:get_luaentity()
			if le and le.name == "labyrinth:sliding_door_entity" and le.anchor_pos and vector.equals(le.anchor_pos, pos) then
				for _, ch in ipairs(obj:get_children() or {}) do ch:remove() end
				obj:remove()
			end
		end
	end,
	-- Toggle on click or punch
on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		for _, obj in pairs(minetest.get_objects_inside_radius(pos, 2.1)) do
			local e = obj:get_luaentity()
			if e and e.name == "labyrinth:sliding_door_entity" then
				if e._state == "open" then e:_close(true) else e:_open(true) end
				break
			end
		end
	end,
on_punch = function(pos, node, puncher, pointed_thing)
		-- no-op to avoid double-toggles from punch events
	end,
})

-- Collider entity to provide blocking while visual is non-physical
minetest.register_entity(":labyrinth:sliding_door_collider", {
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

minetest.register_entity(":labyrinth:sliding_door_entity", {
	initial_properties = {
		visual = "mesh",
		mesh = "door.obj",
		textures = {"door.png"},
		visual_size = vector.new(10,10,10),
		collisionbox = {-0.5, -0.5, -0.125, 0.5, 1.5, 0.125},
		physical = false,
		pointable = false,
		static_save = true,
	},
_state = "closed",
	_animating = false,
	_dir = {x=1,y=0,z=0},
	_speed = 2, -- nodes per second
	_target_pos = nil,
	_last_toggle = 0,
	_auto_at = nil,

on_activate = function(self, staticdata)
		local data = minetest.deserialize(staticdata or "") or {}
		self.anchor_pos = data.pos or self.object:get_pos()
		-- Determine direction and yaw from node facedir
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
		-- Spawn collider child once
		local children = self.object:get_children()
		if not children or #children == 0 then
			local cb = minetest.add_entity(self.object:get_pos(), "labyrinth:sliding_door_collider")
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
	end,

	get_staticdata = function(self)
		return minetest.serialize({pos = self.anchor_pos})
	end,

on_step = function(self, dtime)
		-- If anchor node no longer exists, remove this entity
		self._anchor_check = (self._anchor_check or 0) + dtime
		if self._anchor_check > 0.5 then
			self._anchor_check = 0
			local n = minetest.get_node(self.anchor_pos)
			if n.name ~= "labyrinth:slide_door_anchor" then
				for _, ch in ipairs(self.object:get_children() or {}) do ch:remove() end
				self.object:remove()
				return
			end
		end
		if not self._target_pos then return end
		local pos = self.object:get_pos()
		local to_target = vector.subtract(self._target_pos, pos)
		local dist = vector.length(to_target)
		if dist < 0.001 then
			self.object:set_pos(self._target_pos)
			self._target_pos = nil
			self._animating = false
			return
		end
		local step = self._speed * dtime
		if step >= dist then
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
		if not self.object or self._state ~= "open" then
			return
		end

		if self._auto_at and minetest.get_gametime() < self._auto_at then
			minetest.after(1, function()
				if self and self._try_auto_close then
					self:_try_auto_close()
				end
			end)
			return
		end

		local pos = self.anchor_pos
		local objs = minetest.get_objects_inside_radius(pos, 1.5)
		local can_close = true
		for _, obj in ipairs(objs) do
			local le = obj:get_luaentity()
			if obj:is_player() or (le and le.name ~= "labyrinth:sliding_door_entity" and le.name ~= "labyrinth:sliding_door_collider") then
				can_close = false
				break
			end
		end

		if can_close then
			self:_close()
		else
			self._auto_at = minetest.get_gametime() + 1
			minetest.after(1, function()
				if self and self._try_auto_close then
					self:_try_auto_close()
				end
			end)
		end
	end,

	_open = function(self, force)
		local now = minetest.get_gametime()
		if (self._state == "open" and not force) or (not force and now - (self._last_toggle or 0) < 0.2) then return end
		self._last_toggle = now
		self._animating = true
		minetest.sound_play("scary_attack", {pos = self.object:get_pos(), gain = 0.3, max_hear_distance = 10})
		self._target_pos = vector.add(vector.add(self.anchor_pos, {x=0,y=-0.5,z=0}), vector.multiply(self._dir, 0.850))
		self._state = "open"
		minetest.get_meta(self.anchor_pos):set_string("open", "true")
		self._auto_at = now + 5
		minetest.after(5, function()
			if self and self._try_auto_close then
				self:_try_auto_close()
			end
		end)
	end,

_close = function(self, force)
		local now = minetest.get_gametime()
		if (self._state == "closed" and not force) or (not force and now - (self._last_toggle or 0) < 0.2) then return end
		self._last_toggle = now
		self._animating = true
		minetest.sound_play("scary_attack", {pos = self.object:get_pos(), gain = 0.2, max_hear_distance = 10})
		self._target_pos = vector.add(self.anchor_pos, {x=0,y=-0.5,z=0})
		self._state = "closed"
		minetest.get_meta(self.anchor_pos):set_string("open", "false")
		self._auto_at = nil
	end,
})

minetest.register_alias("labyrinth:slide_door_closed", "labyrinth:slide_door_anchor")
minetest.register_alias("labyrinth:slide_door_open", "labyrinth:slide_door_anchor")

-- Ensure entities exist for existing maps and at load
minetest.register_lbm({
	label = "Spawn sliding door entities",
	name = "labyrinth:spawn_sliding_door_entities",
	nodenames = {"labyrinth:slide_door_anchor", "labyrinth:slide_door_closed"},
	run_at_every_load = true,
	action = function(pos, node)
		-- Determine slide axis from facedir to build a search box that includes open offset
		local param2 = (node.param2 or 0) % 4
		local dir = (param2 == 0 or param2 == 2) and {x=1,y=0,z=0} or {x=0,y=0,z=1}
		local base = vector.add(pos, {x=0,y=-0.5,z=0})
		local open_pos = vector.add(base, vector.multiply(dir, 0.9))
		local minp = vector.new(
			math.min(base.x, open_pos.x) - 0.6,
			base.y - 0.1,
			math.min(base.z, open_pos.z) - 0.6
		)
		local maxp = vector.new(
			math.max(base.x, open_pos.x) + 0.6,
			base.y + 2.1,
			math.max(base.z, open_pos.z) + 0.6
		)
		local matches = {}
		for _, obj in ipairs(minetest.get_objects_in_area(minp, maxp)) do
			local le = obj and obj:get_luaentity()
			if le and le.name == "labyrinth:sliding_door_entity" and le.anchor_pos and vector.equals(le.anchor_pos, pos) then
				table.insert(matches, obj)
			end
		end
		if #matches == 0 then
			minetest.add_entity(pos, "labyrinth:sliding_door_entity", minetest.serialize{pos = pos})
		elseif #matches > 1 then
			-- Keep the first, remove extras
			for i = 2, #matches do
				for _, ch in ipairs(matches[i]:get_children() or {}) do ch:remove() end
				matches[i]:remove()
			end
		end
		-- Normalize node name to anchor
		if node.name ~= "labyrinth:slide_door_anchor" then
			node.name = "labyrinth:slide_door_anchor"
			minetest.set_node(pos, node)
		end
	end
})

minetest.log("action", "[labyrinth] Doors registered")
