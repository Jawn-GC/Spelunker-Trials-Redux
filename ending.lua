local ending = {
    identifier = "Ending",
    title = "Ending",
    theme = THEME.EGGPLANT_WORLD,
	world = 4,
	level = 15,
    width = 4,
    height = 4,
    file_name = "Egg.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

ending.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		local crown_id = spawn(ENT_TYPE.ITEM_PICKUP_CROWN, entity.x, entity.y+2.07, entity.layer, 0, 0)
		local crown = get_entity(crown_id)
		crown.flags = set_flag(crown.flags, 28)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.ITEM_EMPRESS_GRAVE)

	local bow
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		bow = entity
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.ITEM_HOUYIBOW)

	define_tile_code("PoG")
	level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
		local block_id = spawn(ENT_TYPE.ITEM_POTOFGOLD, x, y, layer, 0, 0)
		entity = get_entity(block_id)
		entity.flags = set_flag(entity.flags, 28)
	end, "PoG")

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_GENERIC)
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOORSTYLED_PAGODA)

	local frames = 0
	local arrow_uid
	local arrow
	level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()
		if frames == 0 then
			arrow_uid = get_entities_by(ENT_TYPE.ITEM_METAL_ARROW, MASK.ANY, 0)
			for i = 1,#arrow_uid do
				arrow = get_entity(arrow_uid[i])
				arrow.animation_frame = 169
			end
		end
		if frames == 1 then
			bow.flags = set_flag(bow.flags, 28)
			bow.flags = clr_flag(bow.flags, 18)
		end
		frames = frames + 1
    end, ON.FRAME)
	
	toast("Congratulations!")
end

ending.unload_level = function()
    if not level_state.loaded then return end
    
    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _, callback in pairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return ending