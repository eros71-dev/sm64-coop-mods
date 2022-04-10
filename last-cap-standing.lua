-- name: Cap stealer
-- description: Don't let anyone steal your cap or you will lose!\n\nSpecial thanks to Agent X, mod by eros71.

local localPlayer = gMarioStates[0]
gPlayerSyncTable.hasLostCap = false

function on_hurt(a, v) --modified from the hide-and-seek mod
    -- this code runs when a player attacks another player
    local attacker = gMarioStates[a]
    local victim = gMarioStates[v]

    print(attacker .. "attacked" .. victim)

    -- only consider local player
    if victim.playerIndex ~= 0 then
        return
    end

    -- if the attacker has lost their cape and the person attacked has not
    if attacker.hasLostCap == true and victim.hasLostCap == false then
        victim.hasLostCap = true
        attacker.hasLostCap = false
    end

    if victim.hasLostCap then
        mario_blow_off_cap(victim, 100)
    end
end

-- hooks --
hook_event(HOOK_ON_PVP_ATTACK, on_hurt)