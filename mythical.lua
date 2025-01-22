local mythical = {
    identifier = "mythical",
    title = "Mythical [C-Sides]",
    theme = THEME.NEO_BABYLON,
	world = 4,
	level = 12,
    width = 5,
    height = 5,
    file_name = "mythical.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

mythical.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOORSTYLED_BABYLON)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_GENERIC)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_FORCEFIELD)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_FORCEFIELD_TOP)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_SKELETON)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.ANY, 0, ENT_TYPE.ITEM_SKULL)
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.ANY, 0, ENT_TYPE.ITEM_BONES)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_THORN_VINE)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
        entity:tame(true)
		entity.health = 1
		entity.x = entity.x + 0.5
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MOUNT_QILIN)

	local laser_trap
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		laser_trap = entity
	end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_LASER_TRAP)

	local frames = 0
	level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()
		
		--Reset Laser Trap Quicker
		if laser_trap.phase_2 == false and laser_trap.reset_timer == 0 then
			laser_trap.reset_timer = 254
		elseif laser_trap.phase_2 == true and laser_trap.reset_timer == 0 then
			laser_trap.reset_timer = 90
		end
		frames = frames + 1
    end, ON.FRAME)
	
	toast(mythical.title)
end

mythical.unload_level = function()
    if not level_state.loaded then return end
    
    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _, callback in pairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return mythical