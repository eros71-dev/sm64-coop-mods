-- name: Last Cap Standing
-- description: Don't let anyone steal your cap or you will lose!\n\nMod by eros71 and Agent X.

-- keep track of round info
ROUND_STATE_WAIT        = 0
ROUND_STATE_ACTIVE      = 1
gGlobalSyncTable.roundState = ROUND_STATE_WAIT
roundTime = 9000 -- 5 minutes, 60 seconds in every minute * 5 minutes * 30 frames per second
gGlobalSyncTable.roundTimer = 9000

function update()
    if gGlobalSyncTable.roundState == ROUND_STATE_ACTIVE then
        gGlobalSyncTable.roundTimer = gGlobalSyncTable.roundTimer - 1
    else
        -- temp
        gGlobalSyncTable.roundState = ROUND_STATE_ACTIVE
    end
end

function mario_update(m)
    if (m.flags & MARIO_CAP_ON_HEAD) == 0 then
        m.health = 0x880
        set_mario_action(m, ACT_SHIVERING, 0)
        vec3f_copy(m.marioObj.header.gfx.pos, m.pos)
        vec3s_set(m.marioObj.header.gfx.angle, -m.faceAngle.x, m.faceAngle.y, m.faceAngle.z)
    end
end

function on_hurt(attacker, victim)
    -- only consider local player
    if victim.playerIndex ~= 0 then
        return
    end

    victim.flags = victim.flags & ~MARIO_CAP_ON_HEAD
    djui_popup_create(gNetworkPlayers[0].name .. " has been caught!", 1)
end

function on_hud_render()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_NORMAL)

    local center = djui_hud_get_screen_width() * 0.5

    djui_hud_set_color(0, 0, 0, 127)
    djui_hud_render_rect(center - 160, 0, 270, 50)
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_print_text(tostring(math.floor(gGlobalSyncTable.roundTimer / 30)) .. " seconds left", center - 150, 2, 1.5)
end

-- hooks --
hook_event(HOOK_UPDATE, update)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_PVP_ATTACK, on_hurt)
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)