-- name: DVD Screensaver Mod
-- description: This mod will show a DVD screensaver after 5 minutes of inactivity.\n\nBy \\#d6c899\\eros\\#6fb900\\71\\#ffffff\\\n\nDVD logo font by PuzzlyLogos.\nhttps://www.deviantart.com/puzzlylogos

local waitTime = 5 * 60 * 30 -- 5 minutes * 6 seconds * 30 fps
local timer = waitTime
local renderStuff = false
local xDir = 1 -- 0 = left, 1 = right
local yDir = 1 -- 0 = up, 1 = down
local xPos = 0
local yPos = 0
local dvdTexture = get_texture_info("dvd")
local dvdLogoWidth = dvdTexture.width * 0.00008
local dvdLogoHeight = dvdTexture.height * 0.00016
local speed = 1
local sHeight = djui_hud_get_screen_height()
local sWidth = djui_hud_get_screen_width()
-- rgba texture stuff
local r = 255
local g = 255
local b = 255
local rnd = math.random(0, 1)
-- interpolation stuff
local oldX = 0
local oldY = 0

---MarioState
---@param m MarioState
function before_mario_update(m)
    if m.playerIndex ~= 0 then return end -- Only run for the local player

    if m.controller.buttonPressed ~= 0 or m.controller.buttonDown ~= 0 or m.controller.stickMag ~= 0 then
        timer = waitTime
        if renderStuff then
            -- Reset DVD logo stuff
            renderStuff = false
            xPos = 0
            yPos = 0
            xDir = 1
            yDir = 1
        end
    end

    if timer > 0 then
        timer = timer - 1
    else
        renderStuff = true
    end
end

function on_hud_render()
    -- djui_hud_set_font(FONT_TINY)
    djui_hud_set_resolution(RESOLUTION_N64)
    sHeight = djui_hud_get_screen_height()
    sWidth = djui_hud_get_screen_width()
    if renderStuff then
        if xPos >= sWidth - (dvdLogoWidth * 1000) + 8 then
            decide_rnd_color(r, g, b)
            xDir = 0
        end

        if xPos <= -3 then
            decide_rnd_color(r, g, b)
            xDir = 1
        end

        if yPos >= sHeight - (dvdLogoHeight * 500) + 2 then
            decide_rnd_color(r, g, b)
            yDir = 0
        end

        if yPos <= -2 then
            decide_rnd_color(r, g, b)
            yDir = 1
        end

        if xDir == 1 then
            oldX = xPos
            xPos = xPos + (1 * speed)
        else
            oldX = xPos
            xPos = xPos - (1 * speed)
        end

        if yDir == 1 then
            oldY = yPos
            yPos = yPos + (1 * speed)
        else
            oldY = yPos
            yPos = yPos - (1 * speed)
        end

        djui_hud_set_color(0, 0, 0, 255)
        djui_hud_render_rect(0, 0, sWidth + 2, sHeight)

        djui_hud_set_color(r, g, b, 255)
        djui_hud_render_texture_interpolated(dvdTexture, oldX, oldY, dvdLogoWidth, dvdLogoHeight, xPos, yPos,
            dvdLogoWidth, dvdLogoHeight)
    end
    -- djui_hud_print_text("Timer " .. timer, 0, 0, 1)
    -- djui_hud_print_text("xPos " .. xPos, 0, 12, 1)
    -- djui_hud_print_text("yPos " .. yPos, 0, 24, 1)
    -- djui_hud_print_text("xDir " .. xDir, 0, 36, 1)
    -- djui_hud_print_text("yDir " .. yDir, 0, 48, 1)
    -- djui_hud_print_text("sHeight " .. sHeight, 0, 64, 1)
    -- djui_hud_print_text("sWidth " .. sHeight, 0, 84, 1)
end

function check_yellow()
    if r == 255 and g == 255 then
        return true
    else
        return false
    end
end

-- Welcome to Mario's Ristorante! Enjoy your spaghetti!
function decide_rnd_color(currR, currG, currB)
    rnd = math.random(0, 2)
    if rnd == 2 and not check_yellow() then -- if rnd and not yellow
        r = 255                                          -- turn yellow
        g = 255
        b = 00
    else
        if currR == 255 then -- if red
            r = 0
            rnd = math.random(0, 1)
            if rnd == 0 then --turn green
                g = 255
                b = 0
            else --or blue
                g = 0
                b = 255
            end
        elseif currG == 255 then -- if green
            g = 0
            rnd = math.random(0, 1)
            if rnd == 0 then -- turn red
                r = 255
                b = 0
            else --or blue
                r = 0
                b = 255
            end
        elseif currB == 255 then -- if blue
            b = 0
            rnd = math.random(0, 1)
            if rnd == 0 then -- turn red
                r = 255
                g = 0
            else --or green
                r = 0
                g = 255
            end
        end
    end
end

hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
