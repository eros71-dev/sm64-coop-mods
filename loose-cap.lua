-- name: Loose cap
-- description: Your cap is not sautered onto your skull correctly anymore.\n\nSpecial thanks to Agent X for the name, mod by eros71.

local capDropped = false;
local localMario = gMarioStates[0];

function mario_on_set_action(m)

    if (m.action == ACT_START_CROUCHING and m.flags & ~MARIO_CAP_IN_HAND) then
        cutscene_put_cap_on(localMario)
    end

    if (
        m.action == ACT_RELEASING_BOWSER or 
        m.action == ACT_SOFT_BONK or 
        m.action == ACT_DEATH_ON_BACK or
        m.action == ACT_THROWN_BACKWARD or
        m.action == ACT_FALL_AFTER_STAR_GRAB or
        m.action == ACT_DISAPPEARED or
        m.action == ACT_FREEFALL
    ) then
        mario_blow_off_cap(localMario, 5)
        capDropped = true;
        --TODO: Figure out how to make the player not take the cap back right away as soon as it gets off their head.
        play_character_sound(localMario, CHAR_SOUND_WHOA)
    end

end

-- Retrieve cap command, non-functional right now.
function on_retrieve_command()
    --TODO: Check if cap was dropped already from the player's head, and if so, make this remove *this player's* cap from the floor.
    -- Not that it matters too much right now since probably nothing is networked yet.
    if capDropped then
        
    end
    if (localMario.flags & ~MARIO_CAP_ON_HEAD) then --if the retrieve command is executed and mario is not wearing a cap
        mario_retrieve_cap(localMario)
        cutscene_put_cap_on(localMario)
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