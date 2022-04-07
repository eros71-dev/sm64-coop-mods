-- name: Loose cap
-- description: Your cap is not sautered onto your skull correctly anymore.\n\nSpecial thanks to Agent X for the name, mod by eros71.

local localMario = gMarioStates[0];

function mario_on_set_action(localMario)

    if (localMario.action == ACT_START_CROUCHING and localMario.flags & MARIO_CAP_IN_HAND) then --aways exectutes when the player crouches, no idea why
        cutscene_put_cap_on(localMario)
    end

    if (
        localMario.action == ACT_RELEASING_BOWSER or 
        localMario.action == ACT_SOFT_BONK or 
        localMario.action == ACT_DEATH_ON_BACK or
        localMario.action == ACT_THROWN_BACKWARD or
        localMario.action == ACT_FALL_AFTER_STAR_GRAB or
        localMario.action == ACT_DISAPPEARED or
        localMario.action == ACT_FREEFALL
        and localMario.flags & ~MARIO_CAP_IN_HAND
    ) then
        mario_blow_off_cap(localMario, 5);
        play_character_sound(localMario, CHAR_SOUND_WHOA);
    end

end

-- Retrieve cap command.
function on_retrieve_command(localMario)
    if (localMario.flags & ~MARIO_CAP_ON_HEAD) then --if the retrieve command is executed and mario is not wearing a cap
        obj_mark_for_deletion(cap) --TODO: Delete the cap from the level once it's given back to the player. How do I actually mark the cap?
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