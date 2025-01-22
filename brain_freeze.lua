local brain_freeze = {
    identifier = "brain_freeze",
    title = "Brain Freeze [Extras]",
    theme = THEME.NEO_BABYLON,
	world = 2,
	level = 11,
    width = 4,
    height = 4,
    file_name = "brain_freeze.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

brain_freeze.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOORSTYLED_BABYLON)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR)
	
	--Dead Olmite
	define_tile_code("olmite_dead")
	local olmite_dead
	level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
		local block_id = spawn_entity_snapped_to_floor(ENT_TYPE.MONS_OLMITE_NAKED, x, y, layer, 0, 0)
		olmite_dead = get_entity(block_id)
		kill_entity(block_id, false)
		return true
	end, "olmite_dead")
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_SKULL)
	
	toast(brain_freeze.title)
end

brain_freeze.unload_level = function()
    if not level_state.loaded then return end
    
    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _, callback in pairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return brain_freeze