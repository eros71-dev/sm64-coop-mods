-- name: California Gurls Emote
-- description: This is a simple emote that plays the California Gurls song and makes your character dance.\nHave fun!\n- eros71

--- @param m MarioState
function act_california(m)
    set_mario_animation(m, MARIO_ANIM_RUNNING_UNUSED)
    stationary_ground_step(m)

    -- Vanilla moveset, needs to be rewritten so that the player can get out of the California action
    if (m.input & INPUT_A_PRESSED) ~= 0 then
        return set_jumping_action(m, ACT_JUMP, 0)
    end

    if (m.input & INPUT_OFF_FLOOR) ~= 0 then
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    if (m.input & INPUT_ABOVE_SLIDE) ~= 0 then
        return set_mario_action(m, ACT_BEGIN_SLIDING, 0)
    end

    if (m.input & INPUT_NONZERO_ANALOG) ~= 0 then
        m.faceAngle.y = m.intendedYaw

        return set_mario_action(m, ACT_WALKING, 0)
    end

    if (m.input & INPUT_B_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_PUNCHING, 0)
    end

    if (m.input & INPUT_Z_DOWN) ~= 0 then
        return set_mario_action(m, ACT_START_CROUCHING, 0)
    end
end

ACT_CALIFORNIA = allocate_mario_action(ACT_FLAG_STATIONARY | ACT_FLAG_IDLE)

--- @param m MarioState
function mario_update(m)
    if m.playerIndex ~= 0 then return end

    if (
    (m.controller.buttonPressed & Y_BUTTON) ~= 0 and m.action ~= ACT_CALIFORNIA and (m.action == ACT_IDLE or m.action == ACT_PANTING)
    and (m.action & ACT_FLAG_AIR) == 0
    and (m.action & ACT_FLAG_HANGING) == 0
    and (m.action & ACT_FLAG_SWIMMING_OR_FLYING) == 0
    and (m.action & ACT_RIDING_HOOT) == 0
    and (m.action & ACT_FLAG_RIDING_SHELL) == 0
    and (m.input & INPUT_NONZERO_ANALOG) == 0)
    or
    (m.action ~= ACT_END_WAVING_CUTSCENE and m.action ~= ACT_CALIFORNIA) then
        set_mario_action(m, ACT_CALIFORNIA, 0)
    end
end

-- default value
music = SEQ_SOUND_PLAYER

--- @param m MarioState
function on_set_mario_action(m)
    if m.playerIndex ~= 0 then return end
    if m.action == ACT_CALIFORNIA then
        music = get_current_background_music()
        stop_background_music(music)
        play_music(0, SEQ_LEVEL_SLIDE, 1)
    elseif m.prevAction == ACT_CALIFORNIA then
        stop_background_music(SEQ_LEVEL_SLIDE)
        play_music(0, music, 1)
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_SET_MARIO_ACTION, on_set_mario_action)

hook_mario_action(ACT_CALIFORNIA, act_california, INTERACT_PLAYER)

smlua_audio_utils_replace_sequence(SEQ_LEVEL_SLIDE, 0x0D, 100, "cg")
