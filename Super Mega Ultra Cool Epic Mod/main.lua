-- name: Super Mega Ultra Cool Epic Mod
-- description: please dont judge me i'm just too tired i need to sleep
--[[local timer = 0
local LEVEL = LEVEL_BOB
local DELAY = 60

function update()
    if gNetworkPlayers[0].currLevelNum ~= LEVEL and gNetworkPlayers[0].currAreaSyncValid then
            warp_to_level(LEVEL, 1, 1)
    end
end*/

hook_event(HOOK_UPDATE, update)]]--

smlua_audio_utils_replace_sequence(SEQ_LEVEL_GRASS, 0x22, 100, "bob")