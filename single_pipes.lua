-- single tile pipes, don't put these next to other pipe tiles
define_tile_code("pipe_horizontal")
set_pre_tile_code_callback(function(x, y, layer)
    local uid = spawn_grid_entity(ENT_TYPE.FLOOR_PIPE, x, y, layer)
    set_timeout(function()
        local pipe = get_entity(uid)
        pipe.animation_frame = 140
        pipe.direction_type = 3
        pipe.end_pipe = true
        local deco_uid = spawn_entity_over(ENT_TYPE.DECORATION_PIPE, pipe.uid, -0.5,
        0)
        local deco = get_entity(deco_uid)
        deco.animation_frame = 143
        deco.width = -1
        deco.height = 1
        deco_uid = spawn_entity_over(ENT_TYPE.DECORATION_PIPE, pipe.uid, 0.5,
        0)
        deco = get_entity(deco_uid)
        deco.animation_frame = 143
        deco.width = 1
        deco.height = 1
    end, 1)
end, "pipe_horizontal")

define_tile_code("pipe_vertical")
set_pre_tile_code_callback(function(x, y, layer)
    local uid = spawn_grid_entity(ENT_TYPE.FLOOR_PIPE, x, y, layer)
    set_timeout(function()
        local pipe = get_entity(uid)
        pipe.animation_frame = 128
        pipe.direction_type = 12
        pipe.end_pipe = true
        local deco_uid = spawn_entity_over(ENT_TYPE.DECORATION_PIPE, pipe.uid, 0,
        -0.5)
        local deco = get_entity(deco_uid)
        deco.animation_frame = 131
        deco.width = 1
        deco.height = -1
        deco_uid = spawn_entity_over(ENT_TYPE.DECORATION_PIPE, pipe.uid, 0,
        0.5)
        deco = get_entity(deco_uid)
        deco.animation_frame = 131
        deco.width = 1
        deco.height = 1
    end, 1)
end, "pipe_vertical")