-- the one and only kaizo block
define_tile_code("kaizo_block")
set_pre_tile_code_callback(function(x, y, layer)
    local ent = get_entity(spawn(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0))
    ent.flags = set_flag(ent.flags, ENT_FLAG.NO_GRAVITY)
    ent.more_flags = set_flag(ent.more_flags, ENT_MORE_FLAG.DISABLE_INPUT)
    ent.flags = set_flag(ent.flags, ENT_FLAG.INVISIBLE)
    ent.flags = clr_flag(ent.flags, ENT_FLAG.SOLID)
    local trigger = get_entity(spawn_over(ENT_TYPE.LOGICAL_TENTACLE_TRIGGER, ent.uid, 0, 0))
    trigger.x = 0
    trigger.y = -0.5
    trigger.hitboxx = 0.22
    trigger.hitboxy = 0.05
    trigger.offsetx = 0
    trigger.offsety = 0
    set_pre_collision2(trigger.uid, function(self, collidee)
        local bx, by, bl = get_position(ent.uid)
        local cx, cy, cl = get_position(collidee.uid)
        if test_flag(ent.flags, ENT_FLAG.INVISIBLE) and collidee.velocityy > 0 and cy < y-0.3 then
            ent.flags = clr_flag(ent.flags, ENT_FLAG.INVISIBLE)
            ent.flags = set_flag(ent.flags, ENT_FLAG.SOLID)
            collidee.velocityy = -0.1
            spawn(ENT_TYPE.ITEM_GOLDCOIN, bx, by+0.6, bl, 0, 0.2)
            self:destroy()
        end
        return true
    end)
    return true
end, "kaizo_block")