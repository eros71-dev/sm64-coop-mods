-- name: Loose cap
-- description: Your cap is not sautered onto your skull correctly anymore.\n\nSpecial thanks to Agent X, mod by eros71.

local triggerActions = {
    ACT_TRIPLE_JUMP, ACT_RELEASING_BOWSER,
    ACT_SOFT_BONK, ACT_DEATH_ON_BACK,
    ACT_THROWN_BACKWARD, ACT_FALL_AFTER_STAR_GRAB
}

local localMario = gMarioStates[0];

function mario_on_set_action(m)

    if (
        m.action == ACT_TRIPLE_JUMP or 
        m.action == ACT_RELEASING_BOWSER or 
        m.action == ACT_SOFT_BONK or 
        m.action == ACT_DEATH_ON_BACK or
        m.action == ACT_THROWN_BACKWARD or
        m.action == ACT_FALL_AFTER_STAR_GRAB
    ) then
        mario_blow_off_cap(m, 5) -- Not sure why, but it only seems to work if you jump into a wall. Just jump, no actual bonking into it.
        mario_set_flag(~MARIO_CAP_ON_HEAD)
        play_character_sound(m, CHAR_SOUND_WHOA)
    end

end

-- Should give Mario his cap back if he exits the level, non-functional right now.
function on_pause_exit()
    mario_retrieve_cap(localMario)
end

-- Retrieve cap command, non-functional right now, as always.
function on_retrieve_command()
    if (localMario.flags & ~MARIO_CAP_ON_HEAD) then --if the retrieve command is executed and mario is not wearing a cap
        mario_retrieve_cap(localMario)
        return true
    elseif (localMario.flags & MARIO_CAP_ON_HEAD) then -- if Mario is wearing his cap
        djui_chat_message_create('You already have your cap on.')
        return true
    end
    return false
end

-- hooks --
hook_event(HOOK_ON_SET_MARIO_ACTION, mario_on_set_action)
hook_chat_command('retrieve', "- Gives you your cap back.", on_retrieve_command)