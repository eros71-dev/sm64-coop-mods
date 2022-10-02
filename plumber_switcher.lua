-- name: Plumber Switcher
-- description: This mod will randomly switch your pos with another player.\nMade by eros71.\nSpecial thanks for a function to:\nAgent X

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
        if (active_player(gMarioStates[lastRandomPlayerIndex])) then
            m.pos.x = gMarioStates[lastRandomPlayerIndex].pos.x
            m.pos.y = gMarioStates[lastRandomPlayerIndex].pos.y
            m.pos.z = gMarioStates[lastRandomPlayerIndex].pos.z
            m.faceAngle.x = gMarioStates[lastRandomPlayerIndex].faceAngle.x
            m.faceAngle.y = gMarioStates[lastRandomPlayerIndex].faceAngle.y
            m.faceAngle.z = gMarioStates[lastRandomPlayerIndex].faceAngle.z
            m.interactObj = gMarioStates[lastRandomPlayerIndex].interactObj
            m.heldObj = gMarioStates[lastRandomPlayerIndex].heldObj
            m.usedObj = gMarioStates[lastRandomPlayerIndex].usedObj
            m.riddenObj = gMarioStates[lastRandomPlayerIndex].riddenObj
            m.heldByObj = gMarioStates[lastRandomPlayerIndex].heldByObj
            m.numCoins = gMarioStates[lastRandomPlayerIndex].numCoins
            m.capTimer = gMarioStates[lastRandomPlayerIndex].capTimer
            m.peakHeight = gMarioStates[lastRandomPlayerIndex].peakHeight
            --gNetworkPlayers[0].overrideModelIndex = gNetworkPlayers[lastRandomPlayerIndex].modelIndex --Scrapped, I would have to sync every single modelIndex manually, i don't know how to do that yet
            if gMarioStates[lastRandomPlayerIndex].health ~= 0xff then
                m.health = gMarioStates[lastRandomPlayerIndex].health
            end
            m.health = gMarioStates[lastRandomPlayerIndex].health
            if gMarioStates[lastRandomPlayerIndex].action ~= (ACT_DISAPPEARED or ACT_DEATH_EXIT or ACT_PULLING_DOOR or ACT_PUSHING_DOOR)  then
                m.action = gMarioStates[lastRandomPlayerIndex].action
                m.actionArg = gMarioStates[lastRandomPlayerIndex].actionArg
                m.actionState = gMarioStates[lastRandomPlayerIndex].actionState
                m.actionTimer = gMarioStates[lastRandomPlayerIndex].actionTimer
            end
            m.forwardVel = gMarioStates[lastRandomPlayerIndex].forwardVel
            m.invincTimer = 30
        end
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

function on_time_command(msg)
	local newTime = tonumber(msg)
	if not (network_is_server()) then
        djui_chat_message_create("Only the host may change this setting.")
        return true
    end
	if type(newTime) == "nil" then
		if msg == "" then
			if ROUND_TIME_AMOUNT == 1800 then
				djui_chat_message_create("Time is currently set to default.")
				return true
			else
				djui_chat_message_create("Time is currently set to "..ROUND_TIME_AMOUNT..".")
				return true
			end
		elseif msg == "default" and (network_is_server()) then
			djui_chat_message_create("Time reset to default.")
			ROUND_TIME_AMOUNT = 1800
            roundTime = ROUND_TIME_AMOUNT
            gGlobalSyncTable.roundTimer = roundTime
			return true
		else
			djui_chat_message_create("Invalid input.")
			return true
		end
	elseif (network_is_server()) then
		djui_chat_message_create("New time applied.")
		ROUND_TIME_AMOUNT = newTime
        roundTime = ROUND_TIME_AMOUNT
        gGlobalSyncTable.roundTimer = roundTime
		return true
	end
	return false
end

--- @param m MarioState
function active_player(m)
    local np = gNetworkPlayers[m.playerIndex]
    if m.playerIndex == 0 then
        return true
    end
    if not np.connected then
        return false
    end
    if np.currCourseNum ~= gNetworkPlayers[0].currCourseNum then
        return false
    end
    if np.currActNum ~= gNetworkPlayers[0].currActNum then
        return false
    end
    if np.currLevelNum ~= gNetworkPlayers[0].currLevelNum then
        return false
    end
    if np.currAreaIndex ~= gNetworkPlayers[0].currAreaIndex then
        return false
    end
    return is_player_active(m)
end

-- hooks
hook_chat_command("time", "change the amount of time between swaps.", on_time_command)
hook_event(HOOK_UPDATE, update)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
