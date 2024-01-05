-- name: Scott the Woz mod
-- description: Hey all, Scott here!\nBy eros71 lmao

local borderheight = 9
local borderwidth = 9

function border()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_color(59, 86, 255, 255)
    djui_hud_render_rect(0, 0, djui_hud_get_screen_width(), borderheight)
    djui_hud_render_rect(0, djui_hud_get_screen_height()-borderheight, djui_hud_get_screen_width(), borderheight)
    djui_hud_render_rect(0, 0, borderwidth, djui_hud_get_screen_height())
    djui_hud_render_rect(djui_hud_get_screen_width()-borderwidth, 0, borderwidth, djui_hud_get_screen_height())
end

hook_event(HOOK_ON_HUD_RENDER, border)