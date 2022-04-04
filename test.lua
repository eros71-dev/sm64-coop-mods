-- name: test
-- description: test
-- unfinished
--- @param m MarioState
function mario_on_set_action(m)
    if (m.action == ACT_JUMP) then -- if mario jumps
        set_mario_animation(m, MARIO_ANIM_TRIPLE_JUMP_LAND)
        print("jumped")
    end

    if (m.action == ACT_DOUBLE_JUMP) then -- if mario double jumps
        set_mario_animation(m, MARIO_ANIM_TRIPLE_JUMP_LAND)
        print("double jumped")
    end

    if (m.action == ACT_TRIPLE_JUMP) then -- if mario triple jumps
        set_mario_animation(m, MARIO_ANIM_TRIPLE_JUMP_LAND)
        print("triple jumped")
    end

    if (m.action == ACT_LONG_JUMP) then -- if mario long jumps
        set_mario_animation(m, MARIO_ANIM_TRIPLE_JUMP_LAND)
        print("long jumped")
    end
end

-- hooks --
hook_event(HOOK_ON_SET_MARIO_ACTION, mario_on_set_action)