-- name: Sus
-- description: Mario I don’t know man\nyou’ve been seeming sus lately
--[[local timer = 0
local LEVEL = LEVEL_BOB
local DELAY = 60

function update()
    if gNetworkPlayers[0].currLevelNum ~= LEVEL and gNetworkPlayers[0].currAreaSyncValid then
            warp_to_level(LEVEL, 1, 1)
    end
end*/

hook_event(HOOK_UPDATE, update)]]--

smlua_audio_utils_replace_sequence(SEQ_LEVEL_GRASS, 0x22, 100, "sussy-battlefield")