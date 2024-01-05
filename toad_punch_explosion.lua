-- name: Toad punch explosion: The mod (R)
-- description: What the name says :)))))\nBy eros71

local timerBeforeExplosion = 0.2 * 30
local timerBeforeExplosionDefault = timerBeforeExplosion
local runTimer = false

---comment
---@param interactor MarioState
---@param interactee any
function on_interact(interactor, interactee)
    if interactor.playerIndex ~= 0 then return end
    local bhvId = get_id_from_behavior(interactee.behavior)
    if bhvId ~= id_bhvToadMessage then return end
    --djui_chat_message_create(bhvId.." toad")

    if interactor.action == ACT_PUNCHING
    or interactor.action == ACT_MOVE_PUNCHING
    or interactor.action == ACT_JUMP_KICK
    or interactor.action == ACT_GROUND_POUND
    or interactor.action == ACT_DIVE then
        runTimer = true
        --play_sound_with_freq_scale(SOUND_GENERAL_BOING1, interactor.marioObj.header.gfx.cameraToObject, 0.5)
        --play_far_fall_sound(interactor)
        --obj_mark_for_deletion(interactee)
    end
end

---comment
---@param m MarioState
function mario_update_local(m)
    if m.playerIndex ~= 0 then return end

    if runTimer then
        timerBeforeExplosion = timerBeforeExplosion - 1
        if timerBeforeExplosion <= 0 then
            timerBeforeExplosion = timerBeforeExplosionDefault
            runTimer = false
            obj_explode_and_spawn_coins(80, 1)
            obj_spawn_yellow_coins(m.marioObj, 1)
            play_sound(SOUND_GENERAL2_BOBOMB_EXPLOSION, m.marioObj.header.gfx.cameraToObject)
            stop_background_music(get_current_background_music())
            stop_sounds_from_source(m.pos)
        end
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update_local)
hook_event(HOOK_ON_INTERACT, on_interact)