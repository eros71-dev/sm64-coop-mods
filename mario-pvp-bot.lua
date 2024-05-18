-- name: Mario PVP Bot
-- description: By \\#d6c899\\eros\\#6fb900\\71\\#ffffff\\\n\nThis sm64ex-coop mod will control your character for you, moving towards the nearest player and attacking them.\n\nSpecial thanks to:\nIsaac\nfor the improved movement code!

-- This entire thing is very experimental and is a mess, I'm not trying to do optimized clean code here
-- Here be dragons

-- TODO:
-- - Fix permanent panic state(?)

---Mario Update Local
-- We use this hook to control our character.

--[[

Controller struct
| buttonDown | `integer` |  |
| buttonPressed | `integer` |  |
| extStickX | `integer` |  |
| extStickY | `integer` |  |
| port | `integer` |  |
| rawStickX | `integer` |  |
| rawStickY | `integer` |  |
| stickMag | `number` |  |
| stickX | `number` |  |
| stickY | `number` |  |
]]
--[[
   Camera stuct (oh boy what did I get myself into)
| areaCenX | `number` |  |
| areaCenY | `number` |  |
| areaCenZ | `number` |  |
| cutscene | `integer` |  |
| defMode | `integer` |  |
| doorStatus | `integer` |  |
| focus | [Vec3f](structs.md#Vec3f) | read-only |
| mode | `integer` |  |
| nextYaw | `integer` |  |
| pos | [Vec3f](structs.md#Vec3f) | read-only |
| unusedVec1 | [Vec3f](structs.md#Vec3f) | read-only |
| yaw | `integer` |  |

]]

local nearestPlayerName = "N/A"
local nearestPlayerDistance = "N/A"

local punchCooldownValue = 0.1                      -- 0.3 seconds by default
local jumpKickCooldownValue = 0.4                   -- 1 second by default
local swimCooldownValue = 0.7                       -- 0.7 seconds by default

local punchCooldown = punchCooldownValue * 30       -- * 30 frames per second
local jumpKickCooldown = jumpKickCooldownValue * 30 -- * 30 frames per second
local swimCooldown = swimCooldownValue * 30         -- * 30 frames per second
local punchCooldownTimer = 0
local jumpKickCooldownTimer = 0
local swimCooldownTimer = 0

local jumpOverWallsCooldownValue = 0.5                        -- 0.5 seconds by default
local jumpOverWallsCooldown = jumpOverWallsCooldownValue * 30 -- * 30 frames per second
local jumpOverWallsCooldownTimer = 0

local canGroundPound = true

local didFirstPunch = false
local didFirstJumpKick = false

local aiEnabled = true
local aiInfo = true

local holdJump = false
local holdJumpTimer = 0
local holdJumpTimerValue = 1                     -- 1 second by default
local holdJumpTimerMax = holdJumpTimerValue * 30 -- * 30 frames per second

controller = nil

local function s16(num)
   num = math.floor(num) & 0xFFFF
   if num >= 32768 then return num - 65536 end
   return num
end



-- translated from vanilla C decomp
-- thank you Isaac!
local function adjust_analog_stick(controller)
   -- Reset the controller's x and y floats.
   controller.stickX = 0
   controller.stickY = 0

   -- Modulate the rawStickX and rawStickY to be the new f32 values by adding/subtracting 6.
   if controller.rawStickX <= -8 then
      controller.stickX = controller.rawStickX + 6
   elseif controller.rawStickX >= 8 then
      controller.stickX = controller.rawStickX - 6
   end

   if controller.rawStickY <= -8 then
      controller.stickY = controller.rawStickY + 6
   elseif controller.rawStickY >= 8 then
      controller.stickY = controller.rawStickY - 6
   end

   -- Calculate magnitude from the center by vector length.
   controller.stickMag = math.sqrt(controller.stickX ^ 2 + controller.stickY ^ 2)

   -- Magnitude cannot exceed 64: if it does, modify the values appropriately to
   -- flatten the values down to the allowed maximum value.
   if controller.stickMag > 64 then
      controller.stickX = controller.stickX * 64 / controller.stickMag
      controller.stickY = controller.stickY * 64 / controller.stickMag
      controller.stickMag = 64
   end
end

--------------------------

---@param m MarioState
local function mario_update_local(m)
   if m.playerIndex ~= 0 then return end -- Only run for the local player

   controller = m.controller
   if network_player_connected_count() < 2 then return end -- If there are no other players, do nothing
   if is_game_paused() then return end                     -- If the game is paused, do nothing
   if m.health == 0xff then return end                     -- If we're dead, do nothing

   -- AI code --------------------------------------------------------------------------------
   if not aiEnabled then return end -- If AI is disabled, do nothing

   -- Find the nearest player and print the distance
   local nearestPlayer = nearest_mario_state_to_object(m.marioObj)

   if nearestPlayer ~= nil then
      nearestDistance = dist_between_objects(nearestPlayer.marioObj, m.marioObj)
      -- Info for HUD
      nearestPlayerName = gNetworkPlayers[nearestPlayer.playerIndex].name
      nearestPlayerDistance = tostring(math.floor(nearestDistance))
      -- using gNetworkPlayers[], check if the current player y pos is higher than ours, if so, go find the nearest coin
      --FIXME (Doesn't really need a fix, it's more of a "change me" since this is just a crappy workaround for the ai)
      if nearestPlayer.pos.y > m.pos.y then
         -- nearest coin to recover health
         local nearestCoin = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvYellowCoin);

         -- If no coin is found, try to find the nearest red coin
         if nearestCoin == nil then
            nearestCoin = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvRedCoin);
         end

         -- If no coin is found, try to find the nearest star
         if nearestCoin == nil then
            nearestCoin = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvStar);
         end

         -- If no coin is found, try to find the nearest door (no warp)
         if nearestCoin == nil then
            nearestCoin = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvDoor);
         end

         -- If no coin is found, try to find the nearest door (warp)
         if nearestCoin == nil then
            nearestCoin = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvDoorWarp);
         end

         -- go to the nearest coin
         -- If we're far away from the player, move towards the nearest coin
         if nearestCoin ~= nil then
            local marioX = m.pos.x
            local marioY = m.pos.y
            local marioZ = m.pos.z
            local nearestCoinX = nearestCoin.header.gfx.pos.x
            local nearestCoinY = nearestCoin.header.gfx.pos.y
            local nearestCoinZ = nearestCoin.header.gfx.pos.z
            local xDiff = nearestCoinX - marioX
            local zDiff = nearestCoinZ - marioZ
            local distance = math.sqrt(xDiff * xDiff + zDiff * zDiff)

            -- controller angle
            -- Same as before, but we invert the angle to run away from the player
            local cameraAngle = math.atan2(m.area.camera.pos.z - marioZ, m.area.camera.pos.x - marioX)
            local coinAngle = math.atan2(nearestCoinZ - marioZ, nearestCoinX - marioX)
            local angle = coinAngle + cameraAngle

            -- now we set the controller angle
            controller.stickX = math.sin(angle) * 64
            controller.stickY = math.cos(angle) * 64
            -------------------

            -- controller magnitude
            controller.stickMag = 64
            -------------------
         end
      end
   end

   if m.action == ACT_FREEFALL or m.action == ACT_HOLD_FREEFALL or m.action == ACT_JUMP or m.action == ACT_HOLD_JUMP then
      -- Avoid fall damage by jump kicking when close to the ground
      --FIXME (Doesn't work)
      if m.floorHeight == m.pos.y - 20 then
         m.controller.buttonPressed = m.controller.buttonPressed + B_BUTTON
      end
      if m.floorHeight == m.pos.y and not canGroundPound then
         canGroundPound = true
      end
   end

   -- If we touch the ground, stop holding jump
   if m.floorHeight == m.pos.y then
      holdJump = false
      holdJumpTimer = holdJumpTimerMax
   end

   -- Hold jump timer stuff
   if holdJump then
      if holdJumpTimer <= 0 then
         holdJump = false
         holdJumpTimer = holdJumpTimerMax
      else
         holdJumpTimer = holdJumpTimer - 1
         m.controller.buttonDown = m.controller.buttonDown + A_BUTTON -- Hold A
      end
   end

   -- Jump over walls with a cooldown, not great will definitely cause issues like fall damage
   if m.wall ~= nil then
      if jumpOverWallsCooldownTimer <= 0 then
         m.controller.buttonPressed = m.controller.buttonPressed + A_BUTTON
         m.controller.buttonDown = m.controller.buttonDown + A_BUTTON
         jumpOverWallsCooldownTimer = jumpOverWallsCooldown
         holdJump = true
      else
         jumpOverWallsCooldownTimer = jumpOverWallsCooldownTimer - 1
      end
   end

   -- Move towards the nearest player using the controller struct
   local controller = m.controller
   if nearestPlayer ~= nil then
      local nearestPlayerX = nearestPlayer.pos.x
      local nearestPlayerY = nearestPlayer.pos.y
      local nearestPlayerZ = nearestPlayer.pos.z
      local nearestPlayerAngle = nearestPlayer.faceAngle.y
      local marioX = m.pos.x
      local marioY = m.pos.y
      local marioZ = m.pos.z
      local marioAngle = m.faceAngle.y
      local xDiff = nearestPlayerX - marioX
      local zDiff = nearestPlayerZ - marioZ
      local distance = math.sqrt(xDiff * xDiff + zDiff * zDiff)
      --29/07/2023 update
      local targetPos = nearestPlayer.pos


      -- it's been so long that I forgot how this code even worked I'm gonna have a bad time with this now lol

      -- m.intendedMag will be used for the movement magnitude
      -------------------
      -- Move towards the nearest player
      if distance > 100 and (m.health >> 8) > 2 then
         -- controller angle
         -- We need to calculate where the controller should be pointing at considering the nearest player's position on the screen
         -- Our movement is influenced by the camera, as it will keep constantly moving next to the player
         -- We need to take it into account when calculating the angle so we make sure we always move towards the player
         -- We do this by calculating the angle between the player and the camera, and then adding it to the angle between the player and us
         -- This way, we will always move towards the player, no matter where the camera is
         --local cameraAngle = math.atan2(m.area.camera.pos.z - marioZ, m.area.camera.pos.x - marioX) --UNUSED
         --local playerAngle = math.atan2(nearestPlayerZ - marioZ, nearestPlayerX - marioX) --UNUSED
         --local angle = playerAngle + cameraAngle --OLD

         -- code vars originally by Isaac
         local mult = clamp(math.abs(xDiff), 0, 128)
         local angle = s16(atan2s(zDiff, xDiff)) - gLakituState.yaw

         -- now we set the controller angle, code fixed thanks to Isaac's help
         controller.rawStickX = mult * sins(angle)
         controller.rawStickY = -mult * coss(angle)
         adjust_analog_stick(controller)
         -------------------

         -- controller magnitude
         if controller.rawStickX ~= 0 or controller.rawStickY ~= 0 then
            controller.stickMag = 64
         end
         -------------------

         -- Panic state, low health
         -- If we get hurt, run away from the nearest player
      elseif (m.health >> 8) <= 2 then
         -- nearest coin to recover health
         if gNetworkPlayers[0].currLevelNum ~= LEVEL_CASTLE_GROUNDS then
            local nearestCoin = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvYellowCoin);
         else
            local nearestCoin = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvDoorWarp);
         end

         -- If no coin is found, try to find the nearest red coin
         if nearestCoin == nil then
            nearestCoin = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvRedCoin);
         end

         -- If no coin is found, try to find the nearest star
         if nearestCoin == nil then
            nearestCoin = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvStar);
         end

         -- If no coin is found, try to find the nearest door (no warp)
         if nearestCoin == nil then
            nearestCoin = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvDoor);
         end

         -- If no coin is found, try to find the nearest door (warp)
         if nearestCoin == nil then
            nearestCoin = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvDoorWarp);
         end

         -- if the distance to the nearest player is less than 100, run away from the player
         if distance < 100 then
            -- controller angle
            -- Same as before, but we invert the angle to run away from the player
            local cameraAngle = math.atan2(m.area.camera.pos.z - marioZ, m.area.camera.pos.x - marioX)
            local playerAngle = math.atan2(nearestPlayerZ - marioZ, nearestPlayerX - marioX)
            local angle = playerAngle + cameraAngle + math.pi

            -- now we set the controller angle
            controller.stickX = math.sin(angle) * 64
            controller.stickY = math.cos(angle) * 64
            -------------------

            -- controller magnitude
            if controller.rawStickX ~= 0 or controller.rawStickY ~= 0 then
               controller.stickMag = 64
            end
            -------------------
         else
            -- If we're far away from the player, move towards the nearest coin
            if nearestCoin ~= nil then
               local nearestCoinX = nearestCoin.header.gfx.pos.x
               local nearestCoinY = nearestCoin.header.gfx.pos.y
               local nearestCoinZ = nearestCoin.header.gfx.pos.z
               local xDiff = nearestCoinX - marioX
               local zDiff = nearestCoinZ - marioZ
               local distance = math.sqrt(xDiff * xDiff + zDiff * zDiff)

               -- controller angle
               -- Same as before, but we invert the angle to run away from the player
               --local cameraAngle = math.atan2(m.area.camera.pos.z - marioZ, m.area.camera.pos.x - marioX)
               --local coinAngle = math.atan2(nearestCoinZ - marioZ, nearestCoinX - marioX)
               --local angle = coinAngle + cameraAngle

               --[[OLD
               -- now we set the controller angle
               controller.stickX = math.sin(angle) * 64
               controller.stickY = math.cos(angle) * 64
               -------------------
               ]]
                  --

               -- code vars originally by Isaac
               local mult = clamp(math.abs(xDiff), 0, 128)
               local angle = s16(atan2s(zDiff, xDiff)) - gLakituState.yaw

               -- now we set the controller angle, code fixed thanks to Isaac's help
               controller.rawStickX = mult * sins(angle)
               controller.rawStickY = -mult * coss(angle)
               adjust_analog_stick(controller)
               -------------------

               -- controller magnitude
               controller.stickMag = 64
               -------------------
            end
         end
      end
   end

   -- Attack the nearest player
   if nearestPlayer ~= nil then
      local nearestPlayerX = nearestPlayer.pos.x
      local nearestPlayerY = nearestPlayer.pos.y
      local nearestPlayerZ = nearestPlayer.pos.z
      local marioX = m.pos.x
      local marioY = m.pos.y
      local marioZ = m.pos.z
      local xDiff = nearestPlayerX - marioX
      local zDiff = nearestPlayerZ - marioZ
      local distance = math.sqrt(xDiff * xDiff + zDiff * zDiff)
      if distance > 100 and distance < 150 then
         -- Punch, cooldown after first punch
         if didFirstPunch == false then
            set_mario_action(m, ACT_PUNCHING, 0)
            didFirstPunch = true
         else
            if punchCooldownTimer <= 0 then
               set_mario_action(m, ACT_PUNCHING, 0)
               punchCooldownTimer = punchCooldown
            else
               punchCooldownTimer = punchCooldownTimer - 1
            end
         end
      elseif distance <= 100 then
         -- Jump Kick, cooldown after first jump kick
         if didFirstJumpKick == false then
            set_mario_action(m, ACT_JUMP_KICK, 0)
            didFirstJumpKick = true
         else
            if jumpKickCooldownTimer <= 0 then
               set_mario_action(m, ACT_JUMP_KICK, 0)
               jumpKickCooldownTimer = jumpKickCooldown
            else
               jumpKickCooldownTimer = jumpKickCooldownTimer - 1
            end
         end
      end
   end
end

local function on_hud_render()
   if not aiInfo then return end -- If AI is disabled, don't render the rest of the HUD
   local width = djui_hud_get_screen_width()
   local height = djui_hud_get_screen_height()
   djui_hud_set_resolution(RESOLUTION_N64)
   djui_hud_set_font(FONT_TINY)
   -- Text shadow
   djui_hud_set_color(0, 0, 0, 64)
   djui_hud_print_text("Nearest Player: " .. nearestPlayerName, 25, 33, 1)
   djui_hud_print_text("Distance: " .. nearestPlayerDistance, 25, 49, 1)
   -- Text
   djui_hud_set_color(255, 255, 255, 255)
   djui_hud_print_text("Nearest Player: " .. nearestPlayerName, 24, 32, 1)
   djui_hud_print_text("Distance: " .. nearestPlayerDistance, 24, 48, 1)
   if not aiEnabled then return end -- If AI is disabled, don't render the rest of the HUD
   -- We will draw a square showing the controller input as a square with a white square inside
   djui_hud_set_color(255, 255, 255, 255)
   djui_hud_set_font(FONT_HUD)
   djui_hud_print_text("AI Input", 200, 220, 0.8)
   -- Controller input background
   djui_hud_set_color(0, 0, 0, 64)
   djui_hud_render_rect(192, 160, 90, 80)
   -- Controller input stick
   djui_hud_set_color(255, 255, 255, 255)
   if controller ~= nil then
      djui_hud_render_rect(236 + (controller.stickX / 2), 200 + (-(controller.stickY / 2)), 8, 8)
   else
      djui_hud_render_rect(236, 200, 8, 8)
   end
end

local function on_ai_command(msg)
   if msg == "on" then
      djui_chat_message_create("AI Enabled")
      aiEnabled = true
      return true
   elseif msg == "off" then
      djui_chat_message_create("AI Disabled")
      aiEnabled = false
      return true
   end
   return false
end

local function on_aiCooldown_command(msg)
   if msg == "on" then
      djui_chat_message_create("AI Cooldown Enabled")
      -- Reset cooldown values
      punchCooldownValue = 0.1    -- 0.3 seconds by default
      jumpKickCooldownValue = 0.4 -- 1 second by default
      swimCooldownValue = 0.7     -- 0.7 seconds by default
      return true
   elseif msg == "off" then
      djui_chat_message_create("AI Cooldown Disabled")
      -- Set cooldown values to 0
      punchCooldownValue = 0
      jumpKickCooldownValue = 0
      swimCooldownValue = 0
      return true
   end
   return false
end

local function on_aiInfo_command(msg)
   if msg == "on" then
      djui_chat_message_create("AI Distance HUD Enabled")
      aiInfo = true
      return true
   elseif msg == "off" then
      djui_chat_message_create("AI Distance HUD Disabled")
      aiInfo = false
      return true
   end
   return false
end

hook_event(HOOK_BEFORE_MARIO_UPDATE, mario_update_local)
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
hook_chat_command("ai", "[on|off] Turn the AI ON or OFF.", on_ai_command)
hook_chat_command("aiCooldown", "[on|off] Turn the AI ON or OFF.", on_aiCooldown_command)
hook_chat_command("aiInfo", "[on|off] Turn the AI Distance HUD ON or OFF.", on_aiInfo_command)
