require("defines")
local loaded = false



game.onload(function()
	if not loaded then
		loaded = true
		
		if glob.tapes ~= nil then
			game.onevent(defines.events.ontick, ticker)
		end
	end
end)

game.oninit(function()
	loaded = true
end)

game.onevent(defines.events.onbuiltentity, function(event)
	if event.createdentity.name == "tape-measure" then
		if glob.tapes ~= nil and glob.tapes[tostring(event.playerindex)] ~= nil then
			printDistance(event)
		else
			addTapeToTicker(event.createdentity.position, event.playerindex)
		end
		event.createdentity.destroy()
		game.getplayer(event.playerindex).insert({name = "tape-measure", count = 1})
	end
end)

function ticker()
	for k,tapeTable in pairs(glob.tapes) do
		if tapeTable["marker"].valid
			and tapeTable["player"].cursorstack ~= nil
			and tapeTable["player"].cursorstack["name"] == "tape-measure" then
			
			local playerPosition = tapeTable["player"].position
			local lastPlayerPosition = tapeTable["lastPlayerPosition"]
			
			if playerPosition.x ~= lastPlayerPosition.x or playerPosition.y ~= lastPlayerPosition.y then
				local arrows = tapeTable["arrows"]
				local markerPosition = tapeTable["marker"].position
				if math.floor(playerPosition.x) > math.floor(markerPosition.x) then
					if arrows[1] == nil or not arrows[1].valid then
						arrows[1] = game.createentity({position = {playerPosition.x - 1, playerPosition.y}, name = "arrow-left"})
					else
						arrows[1].teleport({playerPosition.x - 1, playerPosition.y})
					end
				elseif math.floor(playerPosition.x) < math.floor(markerPosition.x) then
					if arrows[2] == nil or not arrows[2].valid then
						arrows[2] = game.createentity({position = {playerPosition.x + 1, playerPosition.y}, name = "arrow-right"})
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
						arrows[3] = game.createentity({position = {playerPosition.x, playerPosition.y - 1}, name = "arrow-up"})
					else
						arrows[3].teleport({playerPosition.x, playerPosition.y - 1})
					end
				elseif math.floor(playerPosition.y) < math.floor(markerPosition.y) then
					if arrows[4] == nil or not arrows[4].valid then
						arrows[4] = game.createentity({position = {playerPosition.x, playerPosition.y + 1}, name = "arrow-down"})
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
			glob.tapes[k] = nil
		end
	end
	
	if tableIsEmpty(glob.tapes) then
		glob.tapes = nil
		game.onevent(defines.events.ontick, nil)
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
	local endPosition = event.createdentity.position
	local playerIndex = event.playerindex
	local tapeTable = glob.tapes[tostring(playerIndex)]
	
	if tapeTable["marker"].valid then
		local player = game.getplayer(playerIndex)
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

function addTapeToTicker(position, playerIndex)
	local newTape = {}
	local marker = game.createentity({position = position, name = "tape-measure-marker", force = game.forces.player})
	local player = game.getplayer(playerIndex)
	local playerPosition = player.position
	local markerPosition = marker.position
	local arrows = {}
	
	if math.floor(playerPosition.x) > math.floor(markerPosition.x) then
		arrows[1] = game.createentity({position = {playerPosition.x - 1, playerPosition.y}, name = "arrow-left"})
	elseif math.floor(playerPosition.x) < math.floor(markerPosition.x) then
		arrows[2] = game.createentity({position = {playerPosition.x + 1, playerPosition.y}, name = "arrow-right"})
	end
	if math.floor(playerPosition.y) > math.floor(markerPosition.y) then
		arrows[3] = game.createentity({position = {playerPosition.x, playerPosition.y - 1}, name = "arrow-up"})
	elseif math.floor(playerPosition.y) < math.floor(markerPosition.y) then
		arrows[4] = game.createentity({position = {playerPosition.x, playerPosition.y + 1}, name = "arrow-down"})
	end
	
	newTape["player"] = player
	newTape["marker"] = marker
	newTape["arrows"] = arrows
	newTape["lastPlayerPosition"] = playerPosition
	newTape["lastCheckedPosition"] = markerPosition
	newTape["lastCheckedTick"] = -500
	
	if glob.tapes == nil then
		game.onevent(defines.events.ontick, ticker)
		glob.tapes = {}
	end
	glob.tapes[tostring(playerIndex)] = newTape
end