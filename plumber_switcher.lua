-- name: Plumber Switcher
-- description: This mod will randomly switch your pos with another player.

-- initialize round info
ROUND_STATE_WAIT   = 0
ROUND_STATE_ACTIVE = 1
ROUND_TIME_AMOUNT  = 1800

-- vars
gGlobalSyncTable.roundState = ROUND_STATE_ACTIVE -- has the round started?
roundTime = ROUND_TIME_AMOUNT -- 30 seconds, 30 seconds * 30 frames per second
gGlobalSyncTable.roundTimer = roundTime -- Actual countdown

lastRandomPlayerIndex = 0

function update()
    if (network_player_connected_count() > 1) and gGlobalSyncTable.roundState == ROUND_STATE_ACTIVE then
        gGlobalSyncTable.roundTimer = gGlobalSyncTable.roundTimer - 1
    end
end

--- @param m MarioState
function mario_update(m)
    if gGlobalSyncTable.roundTimer <= 0 and (network_player_connected_count() > 1) then
        lastRandomPlayerIndex = math.random(1, network_player_connected_count() - 1)
        m.pos.x = gMarioStates[lastRandomPlayerIndex].pos.x
        m.pos.y = gMarioStates[lastRandomPlayerIndex].pos.y
        m.pos.z = gMarioStates[lastRandomPlayerIndex].pos.z
        m.faceAngle.x = gMarioStates[lastRandomPlayerIndex].faceAngle.x
        m.faceAngle.y = gMarioStates[lastRandomPlayerIndex].faceAngle.y
        m.faceAngle.z = gMarioStates[lastRandomPlayerIndex].faceAngle.z
        m.action = gMarioStates[lastRandomPlayerIndex].action
        m.actionArg = gMarioStates[lastRandomPlayerIndex].actionArg
        m.actionState = gMarioStates[lastRandomPlayerIndex].actionState
        m.actionTimer = gMarioStates[lastRandomPlayerIndex].actionTimer
        m.forwardVel = gMarioStates[lastRandomPlayerIndex].forwardVel
        m.invincTimer = 30

        roundTime = ROUND_TIME_AMOUNT
        gGlobalSyncTable.roundTimer = roundTime
    end
end

function on_hud_render()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_NORMAL)

    local center = djui_hud_get_screen_width() * 0.5

    djui_hud_set_color(0, 0, 0, 127)
    if (network_player_connected_count() > 1) then
        djui_hud_render_rect(center - 160, 0, 270, 50)
    elseif (network_player_connected_count() <= 1) then
        djui_hud_render_rect(center - 200, 0, 420, 50)
    end

    -- color timer depending on seconds left
    if (math.floor(gGlobalSyncTable.roundTimer / 30) <= 60) then
        djui_hud_set_color(255, 200, 0, 255)
    elseif (math.floor(gGlobalSyncTable.roundTimer / 30) <= 10) then
        djui_hud_set_color(255, 0, 0, 255)
    else
        djui_hud_set_color(255, 255, 255, 255)
    end

    if (network_player_connected_count() > 1) then
        djui_hud_print_text(tostring(math.floor(gGlobalSyncTable.roundTimer / 30)) .. " seconds left", center - 150, 2, 1.5)
    elseif (network_player_connected_count() <= 1) then
        djui_hud_print_text("More players are required.", center - 190, 2, 1.5)
    end
    
end

-- hooks
hook_event(HOOK_UPDATE, update)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
