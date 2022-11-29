-- name: Wario fucking dies
-- description: Based on the SM64DS meme,\nif you jump from the top of the tree near the bridge\ninto the lake\nwhile playing as Wario,\nyou die.\nAs simple as that.
triggeredFunnyTree = false

--Tree pos:
--x: 3153.0, y:780.0, z: 469.0

---@param m MarioState
function mario_update_local(m)
    --ignore players that aren't the local player
    if m.playerIndex ~= 0 then return end

    if m.pos.x == 3153.0 and m.pos.y == 780.0 and m.pos.z == 469.0
    and m.character.type == CT_WARIO
    and triggeredFunnyTree ~= true
    then 
        triggeredFunnyTree = true
    end

    if triggeredFunnyTree and (m.pos.x < 3000.0 or m.pos.x > 6200.0) and (m.pos.z < 100.0 or m.pos.z > 2200.0) then
        triggeredFunnyTree = false
    end
    
    if triggeredFunnyTree and m.prevAction == ACT_TOP_OF_POLE_JUMP and (m.action & ACT_FLAG_SWIMMING) ~= 0 then
        m.health = 0xff;
        triggeredFunnyTree = false
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update_local)