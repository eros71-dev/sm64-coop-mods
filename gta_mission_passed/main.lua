-- name: GTA SA Mission Passed Screen
-- description: This mod will show some text similar to the one in Grand Theft Auto San Andreas\nwhenever somebody gets a star,\nalong with the well known Mission Passed music.\n\nBy \\#d6c899\\eros\\#6fb900\\71\\#ffffff\\.\n\nSpecial thanks to \\#ec7731\\Agent X\\#ffffff\\.

local missionPassedTex = get_texture_info("you_got_a_star")
local gtaSound1 = audio_stream_load("gta_sa_mission_passed_1.mp3")
local gtaSound2 = audio_stream_load("gta_sa_mission_passed_2.mp3")
local currentAlpha = 0
local fullAlphaTime = 6 * 30
local timer = fullAlphaTime
local showScreen = false
local posWidth = djui_hud_get_screen_width()
local posHeight = djui_hud_get_screen_height()
local fadeIn = true
local fadeOut = false
local static = false
local fadeSpeed = 8
local rand = math.random(0, 1)

-- By Agent X
function name_without_hex(name)
    local s = ''
    local inSlash = false
    for i = 1, #name do
        local c = name:sub(i,i)
        if c == '\\' then
            inSlash = not inSlash
        elseif not inSlash then
            s = s .. c
        end
    end
    return s
end

---@param m MarioState
function on_set_mario_action(m)
    if m.playerIndex == 0 then 
        if m.action == ACT_STAR_DANCE_EXIT or m.action == ACT_STAR_DANCE_NO_EXIT or m.action == ACT_STAR_DANCE_WATER then
            audio_stream_play(gtaSound1, false, 1)
            audio_stream_set_looping(gtaSound1, false)
            showScreen = true
        end
    else
        if m.action == ACT_STAR_DANCE_EXIT or m.action == ACT_STAR_DANCE_NO_EXIT or m.action == ACT_STAR_DANCE_WATER then
            audio_stream_play(gtaSound2, false, 1)
            audio_stream_set_looping(gtaSound2, false)
            djui_popup_create("\\#FFAD00\\"..name_without_hex(gNetworkPlayers[m.playerIndex].name).."\n\\#FFFFFF\\has collected a star!", 2)
        end
    end
    
end

function on_hud_render()
    if showScreen then
        if fadeIn and currentAlpha < 255 then
            currentAlpha = currentAlpha + (1 * fadeSpeed)
            if currentAlpha > 255 then
                currentAlpha = 255
            end
        end
        if currentAlpha >= 255 then
            fadeIn = false
            fadeOut = false
            static = true
        end
        if static then
            if timer > 0 then
                timer = timer - 1
            else
                timer = fullAlphaTime
                fadeIn = false
                fadeOut = true
                static = false
            end
        end
        if fadeOut and currentAlpha > 0 then
            currentAlpha = currentAlpha - (1 * fadeSpeed)
            if currentAlpha < 0 then
                currentAlpha = 0
            end
        elseif fadeOut and currentAlpha == 0 then
            fadeIn = true
            fadeOut = false
            static = false
            currentAlpha = 0
            showScreen = false
        end
        djui_hud_set_color(255, 255, 255, currentAlpha)
        posWidth = (djui_hud_get_screen_width() / 2) - (missionPassedTex.width * 0.8) / 2
        posHeight = (djui_hud_get_screen_height() / 2) - (missionPassedTex.height * 0.8) / 2
        djui_hud_set_resolution(RESOLUTION_DJUI)
        djui_hud_render_texture(missionPassedTex, posWidth, posHeight, 0.8, 0.8)
    end
end

smlua_audio_utils_replace_sequence(SEQ_EVENT_CUTSCENE_COLLECT_STAR, 34, 0, "silent_star")
hook_event(HOOK_ON_SET_MARIO_ACTION, on_set_mario_action)
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)