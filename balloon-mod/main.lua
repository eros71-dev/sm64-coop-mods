-- name: Balloon Mod
-- description: Kinda an alternative to Moonjumping.\n\nBy eros\\#6fb900\\71\\#ffffff\\\n\nSpecial credits to Agent\\#ec7731\\X\\#ffffff\\.\n\nThis wouldn't exist without his help and his sticker library.


E_MODEL_BALLOON = smlua_model_util_get_id("balloon_geo")
local canHaveBalloon = true

function mario_update_local(m)
    --if not the local player, ignore the rest of the function
    if m.playerIndex ~= 0 then return end

    if does_mario_have_normal_cap_on_head(m) ~= 1 then
        canHaveBalloon = false
        if sticker ~= nil then
            despawn_sticker()
        end
    end

    if (m.action & ACT_FLAG_AIR) == 0 and sticker == nil then
        spawn_sticker(m, E_MODEL_BALLOON, 180, 1)
        canHaveBalloon = false
    end

    if sticker == nil and canHaveBalloon then
        spawn_sticker(m, E_MODEL_BALLOON, 180, 1)
        canHaveBalloon = false
    end

    -- if player is in the air, their position is lower than the jump peak, and they press a/jump
    if (m.action & ACT_FLAG_AIR) ~= 0
    and m.pos.y < (m.peakHeight - 8)
    and (m.input & INPUT_A_PRESSED) ~= 0
    and does_mario_have_normal_cap_on_head(m) ~= 0
    and sticker ~= nil
    then
            --shitty workaround to force the next animation
            --doesn't even work sometimes
        if m.action == ACT_LONG_JUMP or m.animation == MARIO_ANIM_FAST_LONGJUMP then
            set_mario_animation(m, MARIO_ANIM_CROUCH_FROM_FAST_LONGJUMP)
        else   
            set_mario_animation(m, MARIO_ANIM_FAST_LONGJUMP)
        end
        --make the player jump
        play_character_sound(m, CHAR_SOUND_PUNCH_WAH)
        play_sound(SOUND_GENERAL_SWISH_AIR, m.pos)
        m.action = ACT_LONG_JUMP
        m.vel.y = 20.2
        
    end

    -- if using the balloon
    if (m.action & ACT_FLAG_AIR) ~= 0 and sticker ~= nil or m.action == ACT_LONG_JUMP then
        canHaveBalloon = false
		m.faceAngle.y = m.intendedYaw
        --limit speed
        if m.forwardVel > 26 then
            m.forwardVel = 26
        end
        --lower gravity
        m.vel.y = m.vel.y + 0.8
        --drop the balloon when diving
        if (m.input & INPUT_B_PRESSED) ~= 0 then
            m.action = ACT_DIVE
            despawn_sticker()
            canHaveBalloon = false
        end
    end

    if m.animation == ACT_SLEEPING and sticker ~= nil then
        m.vel.y = 20.2
    end
end

--checks if the mario action passed as an argument is in a table
function isInTable(m, table)
    for key, value in pairs(table) do
        if m.action == value then
            return true
        end
    end
    return false
end

--if player lands, and doesn't already have a balloon
function mario_on_set_action(m)
    --if not the local player, ignore the rest of the function
    if m.playerIndex ~= 0 then return end
    if sticker == nil and canHaveBalloon then
        spawn_sticker(m, E_MODEL_BALLOON, 180, 1)
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update_local)
hook_event(HOOK_ON_SET_MARIO_ACTION, mario_on_set_action)