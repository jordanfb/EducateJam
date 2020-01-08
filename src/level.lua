require "class"
require "circuit"
require "newterminal"

Level = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Level:_init(game, player)
	self.currentLevel = 1
	self.numberOfLogicGateTypes = 7
	self.game = game
	self.player = player

	self.totalLevels = 8
	
	self.terminalNames = {}
	self.terminalNames["!"]=true
	self.terminalNames["@"]=true
	self.terminalNames["#"]=true
	self.terminalNames["$"]=true
	self.terminalNames["%"]=true
	self.terminalNames["^"]=true
	self.terminalNames["&"]=true
	self.terminalNames["*"]=true
	self.terminalNames["("]=true
	self.terminalNames[")"]=true
	
	self.treasure = {}

	self.ladderImage = love.graphics.newImage('art/wallTileWithLadder.png')
	self.foregroundImage = love.graphics.newImage('art/foregroundWallTile.png')
	
	self.terminalAnimation = 0
	self.gateAnimation = 0
	self.torchAnimation = 0
	
	self.wallImages = {}
	for i = 1, 4 do
		self.wallImages[i] = love.graphics.newImage('art/wallTile'..i..'.png')
	end
	
	self.terminalImages = {}
	for i = 1, 6 do
		self.terminalImages[i] = love.graphics.newImage('art/wallLayerWithTerminal'..i..'.png')
	end 
	
	self.leverImages = {}
	for i = 1, 5 do
		self.leverImages[i] = love.graphics.newImage('art/wallTileWithLever'..i..'.png')
	end 
	
	self.doorImages = {}
	for i = 1, 5 do
		self.doorImages[i] = love.graphics.newImage('art/doorGameJam'..i..'.png')
	end 
	
	self.blueRunes = {}
	for i = string.byte('A'), string.byte('P') do
		self.blueRunes[string.char(i)] = love.graphics.newImage('art/rune'..string.char(i)..'Blue.png')
	end 
	
	self.greyRunes = {}
	for i = string.byte('A'), string.byte('P') do
		self.greyRunes[string.char(i)] = love.graphics.newImage('art/rune'..string.char(i)..'Grey.png')
	end 
	
	self.gateImages = {}
	self.emptyGate = love.graphics.newImage('art/gate0.png')
	for i = 1, 7 do
		self.gateImages[i] = {}
		for j = 1, 8 do
			self.gateImages[i][j] = love.graphics.newImage('art/gate'..i..'-'..j..'.png')
		end
	end

	local oneInputImages = {background = love.graphics.newImage('art/2NodesOneGate.png'),
												inA = love.graphics.newImage('art/2NodesWire1.png'),
												out = love.graphics.newImage('art/2NodesWire2.png')}
	local twoInputImages = {background = love.graphics.newImage('art/3NodesOneGate.png'),
												inA = love.graphics.newImage('art/3NodesWire1.png'),
												inB = love.graphics.newImage('art/3NodesWire2.png'),
												out = love.graphics.newImage('art/3NodesWire3.png')}
	self.insideTerminalImages = {background = love.graphics.newImage('art/terminalBackground.png'),
							oneInputImages = oneInputImages,
							twoInputImages = twoInputImages,
						}
	self.inventoryImages = {background = love.graphics.newImage('art/playerInventoryPanel.png'),
							tileBackground = love.graphics.newImage('art/gateTileBackground.png'), 
							leftArrow = love.graphics.newImage('art/leftArrow.png'),
							rightArrow = love.graphics.newImage('art/rightArrow.png'),
							highlight = love.graphics.newImage('art/stillGatesBorder.png'),
							}
	for i = 1, self.numberOfLogicGateTypes do
		-- load the logic gate inputs
		self.inventoryImages["gateTile"..i..".png"] = love.graphics.newImage('art/gateTile'..i..'.png')
	end

	self.torchImages = {}
	for i = 1, 4 do
		self.torchImages[i] = love.graphics.newImage('art/wallTorch'..i..'.png')
	end 
	
	self.glowImage = love.graphics.newImage('art/torchlightAlphaCircle.png')
	
	self.treasureImages = {}
	for i = 1, 6 do
		self.treasureImages[i] = love.graphics.newImage('art/treasure'..i..'.png')
	end 

	self.doorSound = love.audio.newSource("music/door.wav", "static")
	self.doorSound:setLooping(false)
	
	self.gateSound = love.audio.newSource("music/gateCollect.mp3", "static")
	self.gateSound:setLooping(false)
	self.gateSound:setVolume(0.4)
	--self:initialize()
end

function Level:initialize()

	self.game.gameMusic:play()
	self.walls = {}
	self.ladders = {}
	self.doors = {}
	self.levers = {}
	self.levelArray = {}
	self.backgrounds = {}
	self.terminals = {}
	self.newTerminals = {} -- the key is the door output rune letter, which may or may not be good
	self.gates = {}
	self.torches = {}
	self.treasure = {}
	self.circuit = Circuit("levels/level"..self.currentLevel.."circuit.txt")

	local lines = {}	
	
	for line in love.filesystem.lines('levels/level'..self.currentLevel..'.txt') do
		if line == "--INITIAL STATUS--" then
			break
		end
		lines[#lines + 1] = line
		self.levelArray[#self.levelArray + 1] = {}
		for i = 1, #line, 1 do
			self.levelArray[#self.levelArray][#self.levelArray[#self.levelArray]+1] = string.sub(line, i, i)
		end
	end

	local configs = false	--set to true after reaching line --INITIAL STATUS --
	local words = {}
	for line in love.filesystem.lines('levels/level'..self.currentLevel..'.txt') do
		if line == "--TERMINAL STATUS--" then
			break
		end
		if configs then
			for word in line:gmatch("%w+") do table.insert(words, word) end
		end
		if line == "--INITIAL STATUS--" then
			configs = true
		end
	end
	local terminalSetupTable = {}
	configs = false
	print("NEW LEVEL")
	for line in love.filesystem.lines('levels/level'..self.currentLevel..'.txt') do
		if configs then
			local subtable = {}
			for word in line:gmatch("([^%s]+)") do table.insert(subtable, word) end
			table.insert(terminalSetupTable, subtable)
			if subtable[1] == "newterminal" then
				-- then the second thing is the key, and that is currently that
				-- print("NEW TERMINAL SETUP SUBTABLE")
				-- for k, v in pairs(subtable) do
				-- 	print(tostring(k)..", "..tostring(v))
				-- end
				-- print(self.game)
				-- print(self.currentLevel)
				-- print(self)
				-- print(self.circuit)
				local keys = {}
				for i = 3, #subtable do
					keys[i-2] = subtable[i]
				end
				self.newTerminals[subtable[2]] = NewTerminal(self.game, self.currentLevel, self, self.circuit, subtable[2], keys)
			end
		end
		if line == "--TERMINAL STATUS--" then
			configs = true
		end
	end

	self.tileSize = 160
	self.camera = {x = 0, y = 600, dx = 0, dy = 0}

	for y, row in pairs(self.levelArray) do
		for x, tile in pairs(row) do
			if tile == 'w' then
				table.insert(self.walls, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize, h = self.tileSize})
			elseif tile == ' ' then
				local s = 1
				local r = math.random()*10
				if r < 1 then
					s = 2
				elseif r < 2 then
					s = 2
				elseif r < 3 then
					s = 3
				end
				table.insert(self.backgrounds, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize, h = self.tileSize, sprite = s})
			elseif tile == 'l' then
				table.insert(self.ladders, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize})
			elseif string.byte(tile) >= string.byte('a') and string.byte(tile) <= string.byte("p") then
				table.insert(self.levers, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize, key=tile, animation = 0, animating = false, on=false})
			elseif string.byte(tile) >= string.byte('A') and string.byte(tile) <= string.byte("P") then
				table.insert(self.doors, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize, h=3*self.tileSize, key=tile, open = false, animation = 0})
			elseif string.byte(tile) >= string.byte('1') and string.byte(tile) <= string.byte("9") then
				table.insert(self.gates, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize*2, h=self.tileSize*2, gate=tile, taken=false, animation = 0})
			elseif self.terminalNames[tile] ~= nil then
				table.insert(self.terminals, Terminal((x-1)*self.tileSize, (y-1)*self.tileSize, self.tileSize, self.tileSize, self.game, self.currentLevel, self, tile))
				if self.newTerminals[tile] ~= nil then
					self.newTerminals[tile]:addCoordinates((x-1)*self.tileSize, (y-1)*self.tileSize, self.tileSize, self.tileSize)
				else
					print("NEW TERMINAL HAS NOT BEEN CREATED FOR TILE "..tile.."IN LEVEL "..self.currentLevel)
				end
			elseif tile == '_' then
				table.insert(self.backgrounds, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize, h = self.tileSize, sprite = 1})
				self.player:reset((x-1)*self.tileSize, (y-1)*self.tileSize)	
			elseif tile == '.' then
				table.insert(self.torches, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize, h = self.tileSize})
			elseif tile == ',' then
				self.treasure = {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize, h = self.tileSize*2}
			else
				error("TILE "..tile.. " ISN'T RECOGNIZED IN LEVEL "..self.currentLevel)
			end
		end
	end
	self.screen = {w = 1920, h = 1080}
	self.cameraBuffer = 900

	for k, t in pairs(terminalSetupTable) do
		-- print("SETTING TERMINALS")
		-- print("trying to find "..t[2])
		local viewables = {}
		local setViewables = false
		local numViewables = 0
		if t[1] == "terminal" then
			for j, v in pairs(t) do
				if v == "view" then
					setViewables = true
					numViewables = 1
				elseif setViewables then
					viewables[#viewables + 1] = v
					numViewables = numViewables + 1
				end
			end
			for i, terminal in pairs(self.terminals) do
				if terminal.key == t[2] then
					-- print("Found it")
					if #t == 7+numViewables then -- then it has two inputs
						terminal:setTerminalData(2, i, viewables, t[3], t[4], t[5], t[6], t[7])
					elseif #t == 6+numViewables then -- then it only has one gate
						terminal:setTerminalData(1, i, viewables, t[3], t[4], t[5], t[6])
					end
					break
				end
			end
		-- if it's the newterminal, then this whole loop is useless, so we should delete it if we only use newterminals.
		-- elseif t[1] == "newterminal" then
		-- 	self.newTerminals[#self.newTerminals+1] = NewTerminal(t[2], self.circuit)
		end
	end

	local tempX = nil
	local tempY = nil

	for i = 1, #words, 2 do
		-- print("LEVEL 72" .. words[i]..words[i+1])
		if words[i + 1] == "on" then
			for k, v in pairs(self.levers) do
				if v.key == words[i] then
					v.on = true
					v.animation = 4
				end--INITIAL STATUS --

			end
		elseif words[i] == "playerX" then
			tempX = tonumber(words[i + 1])
		elseif words[i] == "playerY" then
			tempY = tonumber(words[i + 1])
		end
	end

	if tempX ~= nil then
		self.player:reset(tempX, tempY)
	end

	self.player:updateAllDoors(self)

	self.resetInfo = {playerx = self.player.x, playery = self.player.y, levers = self:deepcopy(self.levers), camerax = self.camera.x, camery = self.camera.y}
end

function Level:deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[self:deepcopy(orig_key)] = self:deepcopy(orig_value)
        end
        setmetatable(copy, self:deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function Level:copyTable(intable)
	-- returns a copy of the lever table passed in
	local t = {}
	-- for k, v in pairs(intable) do
	-- 	if type(v) == "table" then
	-- 		t[k] = {unpack(v)}
	-- 	else
	-- 		t[k] = v
	-- 	end
	-- end
	local t = {}
	for k, v in pairs(table) do
		if type(v) == "table" then
			t[k] = self:copyTable(v)
		else
			t[k] = v
			-- print(k.." = "..tostring(v))
		end
	end
	return t
end

function Level:reset()
	self.player:reset(self.resetInfo.playerx, self.resetInfo.playery)
	self.levers = self:deepcopy(self.resetInfo.levers)
	-- print("MADE LEVER"..tostring(self.resetInfo.levers==nil))
	self.camera.x = self.resetInfo.camerax
	self.camera.y = 0--self.resetInfo.cameray
	self.player:updateAllDoors(self)
	for i, gate in pairs(self.gates) do
		gate.taken = false
	end
end

function Level:load()
	-- run when the level is given control
	love.mouse.setVisible(false)
end

function Level:leave()
	-- run when the level no longer has control
end

function Level:draw()
	love.graphics.setBackgroundColor(100/255, 100/255, 100/255)
	
	love.graphics.setColor(1, 1, 1)
	for i, wall in pairs(self.backgrounds) do
		love.graphics.draw(self.wallImages[wall.sprite], wall.x + self.camera.x, wall.y + self.camera.y)
	end
	
	for i, torch in pairs(self.torches) do
	love.graphics.setColor(1, 1, 1)
		love.graphics.draw(self.torchImages[math.floor(self.torchAnimation)+1], torch.x + self.camera.x, torch.y + self.camera.y)
		love.graphics.setColor(1, 1, 1, (25 + math.random()*10)/255)
		love.graphics.draw(self.glowImage, torch.x + self.camera.x - torch.w, torch.y + self.camera.y - torch.h)
	end
	
	love.graphics.setColor(1, 1, 1)
	for i, wall in pairs(self.walls) do
		love.graphics.draw(self.foregroundImage, wall.x + self.camera.x, wall.y + self.camera.y)
	end
	--foregroundImage
	
	for i, ladder in pairs(self.ladders) do
		love.graphics.draw(self.ladderImage, ladder.x + self.camera.x, ladder.y + self.camera.y)
	end
	
	for i, lever in pairs(self.levers) do
		if lever.on then
			love.graphics.draw(self.leverImages[math.floor(lever.animation)+1], lever.x + self.camera.x, lever.y + self.camera.y)
			love.graphics.draw(self.blueRunes[string.upper(lever.key)], lever.x + self.camera.x, lever.y - 10 + self.camera.y)
		else
			love.graphics.draw(self.leverImages[math.floor(lever.animation)+1], lever.x + self.camera.x, lever.y + self.camera.y)
			love.graphics.draw(self.greyRunes[string.upper(lever.key)], lever.x + self.camera.x, lever.y - 10 + self.camera.y)
		end
	end
	
	for i, door in pairs(self.doors) do
		love.graphics.draw(self.wallImages[1], door.x + self.camera.x, door.y + self.camera.y)
	end
	
	for i, gate in pairs(self.gates) do
		if gate.taken then
			love.graphics.draw(self.emptyGate, gate.x + self.camera.x, gate.y + self.camera.y)
		else
			love.graphics.draw(self.gateImages[math.floor(gate.gate+.5)][math.floor(self.gateAnimation)+1], gate.x + self.camera.x, gate.y + self.camera.y)
		end
	end
	
	love.graphics.setColor(1, 1, 1)
	for i, terminal in pairs(self.terminals) do
		love.graphics.draw(self.terminalImages[math.floor(self.terminalAnimation)+1], terminal.x + self.camera.x, terminal.y + self.camera.y)
	end
	
	if self.treasure.x then
		love.graphics.draw(self.wallImages[1], self.treasure.x + self.camera.x, self.treasure.y + self.camera.y)
		love.graphics.draw(self.treasureImages[math.floor(self.terminalAnimation)+1], self.treasure.x + self.camera.x, self.treasure.y + self.camera.y)
	end
	
	love.graphics.setColor(1, 1, 1)
	self.player:draw(self, self.camera)
	
	for i, door in pairs(self.doors) do
		if door.open then
			love.graphics.draw(self.doorImages[math.floor(door.animation)+1], door.x + self.camera.x, door.y - self.tileSize + self.camera.y)
			love.graphics.draw(self.blueRunes[door.key], door.x + self.camera.x, door.y - 180 + self.camera.y)
		else
			love.graphics.draw(self.doorImages[math.floor(door.animation)+1], door.x + self.camera.x, door.y - self.tileSize + self.camera.y)
			love.graphics.draw(self.greyRunes[door.key], door.x + self.camera.x, door.y - 180 + self.camera.y)
		end
	end

	self.player:drawFlips()
end

function Level:cameraUpdate(dt)
	self.camera.x = self.camera.x + self.camera.dx*dt
	self.camera.y = self.camera.y + self.camera.dy*dt
	if self.camera.x > 0 then
		self.camera.x = 0
	elseif self.camera.x < -#self.levelArray[1]*self.tileSize + self.screen.w then
		self.camera.x = -#self.levelArray[1]*self.tileSize + self.screen.w
	end
	if self.camera.y > 0 then
		self.camera.y = 0
	elseif self.camera.y < -#self.levelArray*self.tileSize + self.screen.h then
		self.camera.y = -#self.levelArray[1]*self.tileSize + self.screen.h
	end
end

function Level:animate(dt)
	self.terminalAnimation = (self.terminalAnimation+.1)%6
	self.gateAnimation = (self.gateAnimation+.1)%8
	self.torchAnimation = (self.torchAnimation+.1)%4
	for i, lever in pairs(self.levers) do
		if lever.on and lever.animation < 4 then
			lever.animation = lever.animation + .4
		elseif not lever.on and lever.animation > 0 then
			lever.animation = lever.animation - .4
		end
		if lever.animation > 4 then
			lever.animation = 4
		elseif lever.animation < 0 then
			lever.animation = 0
		end
	end
	for i, door in pairs(self.doors) do
		if (math.floor(door.animation)==2) then
			self.doorSound:play()
		end
		if door.open and door.animation < 4 then
			door.animation = door.animation + .4
		elseif not door.open and door.animation > 0 then
			door.animation = door.animation - .4
		end
		if door.animation > 4 then
			door.animation = 4
		elseif door.animation < 0 then
			door.animation = 0
		end
	end
end

function Level:update(dt)
	self.player:update(dt, self)
	self:cameraUpdate(dt)
	self:animate(dt)
end

function Level:resize(w, h)
	--
end

function Level:keypressed(key, unicode)
	self.player:keypressed(key, unicode, self)
	if key == "escape" or key == "joystickstart" or key == "joystickback" then
		self.game:addToScreenStack(self.game.pauseMenu)
	elseif key == "k" and self.game.cheatMode then
		if self.currentLevel < self.totalLevels then
			self.currentLevel = self.currentLevel + 1
			self:initialize()
		else
			self.game:addToScreenStack(self.game.cutscene)
			self.currentLevel = self.currentLevel + 1 
		end
	end
end

function Level:keyreleased(key, unicode)
	--
end

function Level:mousepressed(x, y, button)
	--
end

function Level:mousereleased(x, y, button)
	--
end


function Level:mousemoved(x, y, dx, dy, istouch)
	--
end