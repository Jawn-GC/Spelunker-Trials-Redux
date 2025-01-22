local betrayal = {
    identifier = "betrayal",
    title = "Betrayal [B-Sides]",
    theme = THEME.TIDE_POOL,
    world = 3,
	level = 8,
    width = 6,
    height = 5,
    file_name = "betrayal.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

betrayal.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_SKULL)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOORSTYLED_PAGODA)
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_GENERIC)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
        -- Remove Hermitcrabs
        local x, y, layer = get_position(entity.uid)
        local floor = get_entities_at(0, MASK.ANY, x, y, layer, 1)
        if #floor > 0 then
            entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
            entity:destroy()
        end
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_HERMITCRAB)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
        entity:tame(true)
		entity.health = 1
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MOUNT_AXOLOTL)

	local switch
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		switch = entity
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.ITEM_SLIDINGWALL_SWITCH)

	--Sliding Wall
	define_tile_code("wall")
	local wall
	level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
		local block_id = spawn_entity(ENT_TYPE.FLOOR_SLIDINGWALL_CEILING, x, y, layer, 0, 0)		
		wall = get_entity(block_id)
		wall.state = 1
		return true
	end, "wall")

	--Axo Traitor
	define_tile_code("traitor")
	local traitor_uid
	local axo_x
	local axo_y
	level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
		traitor_uid = spawn_entity(ENT_TYPE.MOUNT_AXOLOTL, x, y, layer, 0, 0)		
		get_entity(traitor_uid).health = 1
		get_entity(traitor_uid).flags = set_flag(get_entity(traitor_uid).flags, ENT_FLAG.FACING_LEFT)
		axo_x = x
		axo_y = y
		return true
	end, "traitor")

	local frames = 0
	local switch_on = false
	local traitor_tamed = false
	level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()
		
		if frames == 1 then
			get_entity(traitor_uid):tame(false)		
		end

		if switch_on == false and switch.timer == 90 then
			switch_on = true
			wall.state = 0
		elseif switch_on == true and switch.timer == 90 then
			switch_on = false
			wall.state = 1
		end
		
		if #players ~= 0 and get_entity(traitor_uid) ~= nil and test_flag(get_entity(traitor_uid).flags, ENT_FLAG.DEAD) ~= true then
			if get_entity(traitor_uid).rider_uid == players[1].uid and traitor_tamed == false then
				get_entity(traitor_uid):tame(true)
				traitor_tamed = true
			end
		end

		frames = frames + 1
    end, ON.FRAME)
	
	toast(betrayal.title)
end

betrayal.unload_level = function()
    if not level_state.loaded then return end
    
    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _, callback in pairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return betrayal