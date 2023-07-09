-- name: SM64JS - Blinking Trees
-- description: Only the oldest sm64js players know what this is\n:impendingdoom:
blinkTrees = false
gameOverScreenJS = false
gameOverMusicPlayed = false
impendingDoomTimer = (6 * 30)
if smlua_text_utils_get_language() == "Spanish" then
    gameOverMessage = "BUENAS NOCHES"
else
    gameOverMessage = "GOOD NIGHT"
end
textPos = 100
--- @param o Object
local function bhv_tree_loop(o)
    if blinkTrees then
        if o.oTimer % 2 ~= 0 then
            cur_obj_hide()
        else
            cur_obj_unhide()
        end
    end
end

function on_level_init()
    blinkTrees = false
    if impendingDoomTimer ~= -1 then
        gameOverScreenJS = false
    end
    impendingDoomTimer = (6 * 30)
    rand = math.random(0, 20)

    if gNetworkPlayers[0].currLevelNum == LEVEL_CASTLE_GROUNDS or gNetworkPlayers[0].currLevelNum == LEVEL_CASTLE then
        rand = 0
    end
    
    if rand == 10 then
        blinkTrees = true
        stop_sounds_in_continuous_banks()
        stop_background_music(get_current_background_music())
        play_music(0, SEQ_EVENT_ENDLESS_STAIRS, 0)
    end
end

function on_mario_update()
    if blinkTrees and impendingDoomTimer > 0 then
        impendingDoomTimer = impendingDoomTimer - 0.05;
    end
    if impendingDoomTimer < 0.5 and impendingDoomTimer ~= 0 then
        impendingDoomTimer = 0
        gameOverScreenJS = true
    end
    if impendingDoomTimer == 0 then
        level_trigger_warp(gMarioStates[0], WARP_OP_CREDITS_NEXT) -- softlock
        impendingDoomTimer = -1
        blinkTrees = false
    end
end

function on_hud_render()
    if blinkTrees then
        width = djui_hud_get_screen_width()
        if (impendingDoomTimer / 30) >= 1 then
            impendingDoomTimerText = math.floor((impendingDoomTimer / 30))
        else
            impendingDoomTimerText = 0
        end
        djui_hud_set_font(FONT_TINY)
        djui_hud_set_resolution(RESOLUTION_N64)
        djui_hud_set_color(0, 0, 0, 100)
        if smlua_text_utils_get_language() == "Spanish" then
            message = "Tienes " .. impendingDoomTimerText .. " segundos para salir del nivel."
        else
            message = "You have " .. impendingDoomTimerText .. " seconds to leave this level."
        end
        djui_hud_print_text(message, (width / 2) - textPos - 1, 15, 1)
        if (impendingDoomTimer/30) > 4 then
            djui_hud_set_color(255, 255, 255, 255)
        else
            djui_hud_set_color(255, 0, 0, 255)
        end
        djui_hud_print_text(message, (width / 2) - textPos, 14, 1)
    end
    if gameOverScreenJS then
        if blinkTrees then
            blinkTrees = false
        end
        djui_hud_set_font(FONT_HUD)
        djui_hud_set_resolution(RESOLUTION_N64)
        width = djui_hud_get_screen_width()
        height = djui_hud_get_screen_height()
        textPos = (width / 2) - 60
        if smlua_text_utils_get_language() == "Spanish" then
            textPos = textPos - 20
        end
        djui_hud_set_color(87, 62, 90, 127)
        djui_hud_print_text(gameOverMessage, textPos - 1, (height/2) - 1, 1.1)
        djui_hud_print_text(gameOverMessage, textPos + 1, (height/2) - 1, 1.1)
        djui_hud_print_text(gameOverMessage, textPos - 1, (height/2) + 1, 1.1)
        djui_hud_print_text(gameOverMessage, textPos + 1, (height/2) + 1, 1.1)
        djui_hud_print_text(gameOverMessage, textPos, (height/2) - 1, 1.1)
        djui_hud_print_text(gameOverMessage, textPos, (height/2) + 1, 1.1)
        djui_hud_set_color(0, 0, 0, 255)
        djui_hud_print_text(gameOverMessage, textPos, (height/2), 1.1)
        if not gameOverMusicPlayed then
            stop_sounds_in_continuous_banks()
            stop_background_music(get_current_background_music())
            audio_stream_play(audio_stream_load("good_night.mp3"), false, 1)
            gameOverMusicPlayed = true
        end
    end
end

hook_behavior(id_bhvTree, OBJ_LIST_POLELIKE, false, nil, bhv_tree_loop)
hook_event(HOOK_ON_LEVEL_INIT, on_level_init)
hook_event(HOOK_MARIO_UPDATE, on_mario_update)
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
