-- name: Bouncy Brother
-- description: Funny plumber go boing.\n\nSimilar to bunny-hopping,\nexcept wackier.\n\nMade by eros71.\n\nSpecial thanks to:\nAgent X\n\nv1.0
local boingActions = {
    ACT_JUMP_LAND, ACT_LAVA_BOOST_LAND, ACT_TWIRL_LAND, ACT_BACKFLIP_LAND, ACT_FREEFALL_LAND,
    ACT_AIR_THROW_LAND, ACT_LONG_JUMP_LAND, ACT_HOLD_JUMP_LAND, ACT_SIDE_FLIP_LAND, ACT_DOUBLE_JUMP_LAND,
    ACT_TRIPLE_JUMP_LAND, ACT_HOLD_FREEFALL_LAND, ACT_GROUND_BONK
}

local defaultPeakHeight = 341.61328125
gGlobalSyncTable.fallDamage = true
local bounce = true

function mario_on_set_action(m)
    if isInTable(m, boingActions) and bounce then
        m.action = ACT_JUMP
        m.vel.y = -m.vel.y
        play_mario_sound(m, CHAR_SOUND_TWIRL_BOUNCE, CHAR_SOUND_TWIRL_BOUNCE)
    end

    if m.action == ACT_JUMP_KICK then
        bounce = false
    end

    if m.action == ACT_IDLE or m.action == ACT_WALKING and bounce == false then
        bounce = true
    end
end

function mario_update_local(m)
    if m.action == ACT_JUMP then
        -- set facing direction, taken from Character Movesets
        m.faceAngle.y = m.intendedYaw
    end
end

function mario_update(m)
        if not gGlobalSyncTable.fallDamage then
            m.peakHeight = m.pos.y
        end
end

function on_fallDamage_command(msg)
	local syncTable = gPlayerSyncTable[0]
	if msg == "off" then
        djui_chat_message_create("Gamerule doFallDamage is now set to: false")
        syncTable.fallDamage = false
        return true
    elseif msg == "on" then
        djui_chat_message_create("Gamerule doFallDamage is now set to: true")
        syncTable.fallDamage = true
        return true
    end
	return false
end

function isInTable(m, table)
    for key, value in pairs(boingActions) do
        if m.action == value then
            return true
        end
    end
    return false
end

hook_chat_command("fallDamage", "[on|off] Enable/disable fall damage.", on_fallDamage_command)
hook_event(HOOK_ON_SET_MARIO_ACTION, mario_on_set_action)
hook_event(HOOK_MARIO_UPDATE, mario_update_local)
hook_event(HOOK_MARIO_UPDATE, mario_update)