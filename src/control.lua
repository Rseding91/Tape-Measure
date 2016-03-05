require("defines")
  
script.on_load(function()
  if global.tapes ~= nil then
    script.on_event(defines.events.on_tick, ticker)
  end
end)

script.on_event(defines.events.on_built_entity, function(event)
  if event.created_entity.name == "tape-measure" then
    if global.tapes ~= nil and global.tapes[event.player_index] ~= nil then
      printDistance(event)
    else
      addTapeToTicker(event.created_entity.position, event.player_index)
    end
    event.created_entity.destroy()
    game.get_player(event.player_index).insert({name = "tape-measure", count = 1})
  end
end)

function ticker()
  for k,tapeTable in pairs(global.tapes) do
    if tapeTable["marker"].valid
      and tapeTable["player"].cursor_stack.valid_for_read
      and tapeTable["player"].cursor_stack.name == "tape-measure" then
      
      local playerPosition = tapeTable["player"].position
      local lastPlayerPosition = tapeTable["lastPlayerPosition"]
      local surface = tapeTable["surface"]
      
      if playerPosition.x ~= lastPlayerPosition.x or playerPosition.y ~= lastPlayerPosition.y then
        local arrows = tapeTable["arrows"]
        local markerPosition = tapeTable["marker"].position
        if math.floor(playerPosition.x) > math.floor(markerPosition.x) then
          if arrows[1] == nil or not arrows[1].valid then
            arrows[1] = surface.create_entity({position = {playerPosition.x - 1, playerPosition.y}, name = "arrow-left"})
          else
            arrows[1].teleport({playerPosition.x - 1, playerPosition.y})
          end
        elseif math.floor(playerPosition.x) < math.floor(markerPosition.x) then
          if arrows[2] == nil or not arrows[2].valid then
            arrows[2] = surface.create_entity({position = {playerPosition.x + 1, playerPosition.y}, name = "arrow-right"})
          else
            arrows[2].teleport({playerPosition.x + 1, playerPosition.y})
          end
        else
          if arrows[1] ~= nil then
            if arrows[1].valid then
              arrows[1].destroy()
            end
            arrows[1] = nil
          end
          if arrows[2] ~= nil then
            if arrows[2].valid then
              arrows[2].destroy()
            end
            arrows[2] = nil
          end
        end
        if math.floor(playerPosition.y) > math.floor(markerPosition.y) then
          if arrows[3] == nil or not arrows[3].valid then
            arrows[3] = surface.create_entity({position = {playerPosition.x, playerPosition.y - 1}, name = "arrow-up"})
          else
            arrows[3].teleport({playerPosition.x, playerPosition.y - 1})
          end
        elseif math.floor(playerPosition.y) < math.floor(markerPosition.y) then
          if arrows[4] == nil or not arrows[4].valid then
            arrows[4] = surface.create_entity({position = {playerPosition.x, playerPosition.y + 1}, name = "arrow-down"})
          else
            arrows[4].teleport({playerPosition.x, playerPosition.y + 1})
          end
        else
          if arrows[3] ~= nil then
            if arrows[3].valid then
              arrows[3].destroy()
            end
            arrows[3] = nil
          end
          if arrows[4] ~= nil then
            if arrows[4].valid then
              arrows[4].destroy()
            end
            arrows[4] = nil
          end
        end
        
        tapeTable["lastPlayerPosition"] = playerPosition
      end
    else
      cleanupTape(tapeTable)
      global.tapes[k] = nil
    end
  end
  
  if tableIsEmpty(global.tapes) then
    global.tapes = nil
    script.on_event(defines.events.on_tick, nil)
  end
end

function tableIsEmpty(t)
  if t then
    for k in pairs(t) do
      return false
    end
  end
  return true
end

function cleanupTape(tapeTable)
  if tapeTable["marker"].valid then
    tapeTable["marker"].destroy()
  end
  
  for k,v in pairs(tapeTable["arrows"]) do
    if v.valid then
      v.destroy()
    end
  end
end

function printDistance(event)
  local endPosition = event.created_entity.position
  local tapeTable = global.tapes[event.player_index]
  
  if tapeTable["marker"].valid then
    local player = tapeTable["player"]
    local markerPosition = tapeTable["marker"].position
    local xDiff, yDiff
    local xSign, ySign
    
    if tapeTable["lastCheckedPosition"].x ~= endPosition.x
      or tapeTable["lastCheckedPosition"].y ~= endPosition.y
      or event.tick - tapeTable["lastCheckedTick"] > 30 then
      
      tapeTable["lastCheckedTick"] = event.tick
      tapeTable["lastCheckedPosition"] = endPosition
      xDiff = math.abs(endPosition.x - markerPosition.x)
      yDiff = math.abs(endPosition.y - markerPosition.y)
      if endPosition.x < markerPosition.x then
        xSign = "-"
      else
        xSign = "+"
      end
      if endPosition.y < markerPosition.y then
        ySign = "-"
      else
        ySign = "+"
      end
      
      player.print("Total distance X: " .. xSign .. xDiff + 1)
      player.print("Total distance Y: " .. ySign .. yDiff + 1)
      player.print("Difference X: " .. xSign .. xDiff)
      player.print("Difference Y: " .. ySign .. yDiff)
      player.print("Start: " .. markerPosition.x .. "," .. markerPosition.y)
      player.print("End: " .. endPosition.x .. "," .. endPosition.y)
    end
  end
end

function addTapeToTicker(position, player_index)
  local newTape = {}
  local player = game.get_player(player_index)
  local surface = player.surface
  local marker = surface.create_entity({position = position, name = "tape-measure-marker", force = player.force})
  
  local playerPosition = player.position
  local markerPosition = marker.position
  local arrows = {}
  
  if math.floor(playerPosition.x) > math.floor(markerPosition.x) then
    arrows[1] = surface.create_entity({position = {playerPosition.x - 1, playerPosition.y}, name = "arrow-left"})
  elseif math.floor(playerPosition.x) < math.floor(markerPosition.x) then
    arrows[2] = surface.create_entity({position = {playerPosition.x + 1, playerPosition.y}, name = "arrow-right"})
  end
  if math.floor(playerPosition.y) > math.floor(markerPosition.y) then
    arrows[3] = surface.create_entity({position = {playerPosition.x, playerPosition.y - 1}, name = "arrow-up"})
  elseif math.floor(playerPosition.y) < math.floor(markerPosition.y) then
    arrows[4] = surface.create_entity({position = {playerPosition.x, playerPosition.y + 1}, name = "arrow-down"})
  end
  
  newTape["player"] = player
  newTape["surface"] = surface
  newTape["marker"] = marker
  newTape["arrows"] = arrows
  newTape["lastPlayerPosition"] = playerPosition
  newTape["lastCheckedPosition"] = markerPosition
  newTape["lastCheckedTick"] = -500
  
  if global.tapes == nil then
    script.on_event(defines.events.on_tick, ticker)
    global.tapes = {}
  end
  global.tapes[player_index] = newTape
end