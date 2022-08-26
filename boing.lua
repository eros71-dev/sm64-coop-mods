-- name: super boing 64
-- description: boing
-- yes this really is my first released mod
local boingActions = {
    ACT_JUMP, ACT_DOUBLE_JUMP, ACT_TRIPLE_JUMP, ACT_BACKFLIP, ACT_JUMP_KICK,
ACT_LONG_JUMP, ACT_SIDE_FLIP, ACT_WATER_JUMP, ACT_STEEP_JUMP, ACT_METAL_WATER_JUMP, ACT_RIDING_SHELL_JUMP,
ACT_SPECIAL_TRIPLE_JUMP, ACT_DIVE, ACT_DIVE_SLIDE, ACT_EMERGE_FROM_PIPE, ACT_PUNCHING, ACT_MOVE_PUNCHING,
ACT_WALL_KICK_AIR, ACT_THROWING, ACT_THROWN_BACKWARD, ACT_THROWN_FORWARD, ACT_AIR_THROW, ACT_HEAVY_THROW,
ACT_WATER_THROW, ACT_HOLD_JUMP, ACT_TOP_OF_POLE_JUMP, ACT_WALL_KICK_AIR
}
function mario_on_set_action(m)
    if isInTable(m, boingActions) then
        play_mario_sound(m, CHAR_SOUND_TWIRL_BOUNCE, CHAR_SOUND_TWIRL_BOUNCE)
    end
end

function isInTable(m, table)
    for key, value in pairs(boingActions) do
        if m.action == value then
            return true
        end
    end
    return false
end

hook_event(HOOK_ON_SET_MARIO_ACTION, mario_on_set_action)