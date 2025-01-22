local fetch_quest = {
    identifier = "fetch_quest",
    title = "Fetch Quest [Vol. 2]",
    theme = THEME.DWELLING,
	world = 2,
	level = 1,
    width = 6,
    height = 3,
    file_name = "fetch_quest.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

fetch_quest.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_SKULL)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.ANY, 0, ENT_TYPE.DECORATION_HANGING_HIDE)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity:give_powerup(ENT_TYPE.ITEM_POWERUP_SPIKE_SHOES)
		entity.flags = set_flag(entity.flags, 6)
		entity.flags = clr_flag(entity.flags, 12)
		entity.flags = clr_flag(entity.flags, 17)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_HORNEDLIZARD)
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOORSTYLED_MINEWOOD)

	--indicators for rope
	local rope_xy = {}
	define_tile_code("unrolled_rope")
	level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
		rope_xy[#rope_xy + 1] = {x,y}
	end, "unrolled_rope")

	local frames = 0
	level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()
		if frames == 0 then
			for i = 1,#rope_xy do
				local rope_uid = spawn_unrolled_player_rope(rope_xy[i][1], rope_xy[i][2], 0, players[1]:get_texture(), 0)
				get_entity(rope_uid).color:set_rgba(100, 100, 100, 235)
				get_entity(rope_uid).flags = clr_flag(get_entity(rope_uid).flags, 9)
			end
		end
        frames = frames + 1
    end, ON.FRAME)

	toast(fetch_quest.title)
end

fetch_quest.unload_level = function()
    if not level_state.loaded then return end
    
    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _, callback in pairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return fetch_quest
