require "class"

Level = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Level:_init(game, player)
	self.currentLevel = 2
	self.game = game
	self.terminal = Terminal(self.game, self.currentLevel, self)
	self.player = player
	self.walls = {}
	self.ladders = {}
	self.doors = {}
	self.levers = {}
	self.levelArray = {}
	self.backgrounds = {}
	self.terminals = {}
	self.gates = {}

	ladderImage = love.graphics.newImage('art/wallTileWithLadder.png')
	wallImage = love.graphics.newImage('art/wallTile1.png')
	foregroundImage = love.graphics.newImage('art/foregroundWallTile.png')
	
	self.terminalAnimation = 0
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

	local lines = {}	
	
	for line in love.filesystem.lines('levels/level'..self.currentLevel..'.txt') do
		if line == "--INITIAL STATUS --" then
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
		if configs then
			for word in line:gmatch("%w+") do table.insert(words, word) end
		end
		if line == "--INITIAL STATUS --" then
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
				table.insert(self.backgrounds, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize, h = self.tileSize})
			elseif tile == 'l' then
				table.insert(self.ladders, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize})
			elseif string.byte(tile) >= string.byte('a') and string.byte(tile) <= string.byte("j") then
				table.insert(self.levers, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize, key=tile, animation = 0, animating = false, on=false})
			elseif string.byte(tile) >= string.byte('A') and string.byte(tile) <= string.byte("J") then
				table.insert(self.doors, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize, h=3*self.tileSize, key=tile, open = false, animation = 0})
			elseif string.byte(tile) >= string.byte('1') and string.byte(tile) <= string.byte("9") then
				table.insert(self.gates, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize, h=self.tileSize, gate=tile, animation = 0})
			elseif tile == 'T' then
				table.insert(self.terminals, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize, h=self.tileSize})
			elseif tile == '_' then
				table.insert(self.backgrounds, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize, h = self.tileSize})
				self.player:reset((x-1)*self.tileSize, (y-1)*self.tileSize)	
			end
		end
	end
	self.screen = {w = 1920, h = 1080}
	self.cameraBuffer = 900

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
			print(k.." = "..tostring(v))
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
end

function Level:load()
	-- run when the level is given control
end

function Level:leave()
	-- run when the level no longer has control
end

function Level:draw()
	love.graphics.setBackgroundColor(100, 100, 100)
	
	love.graphics.setColor(255, 255, 255)
	for i, wall in pairs(self.backgrounds) do
		love.graphics.draw(wallImage, wall.x + self.camera.x, wall.y + self.camera.y)
	end
	
	for i, wall in pairs(self.walls) do
		love.graphics.draw(foregroundImage, wall.x + self.camera.x, wall.y + self.camera.y)
	end
	--foregroundImage
	
	for i, ladder in pairs(self.ladders) do
		love.graphics.draw(ladderImage, ladder.x + self.camera.x, ladder.y + self.camera.y)
	end
	
	for i, lever in pairs(self.levers) do
		if lever.on then
			love.graphics.draw(self.leverImages[math.floor(lever.animation)+1], lever.x + self.camera.x, lever.y + self.camera.y)
		else
			love.graphics.draw(self.leverImages[math.floor(lever.animation)+1], lever.x + self.camera.x, lever.y + self.camera.y)
		end
	end
	
	for i, door in pairs(self.doors) do
		love.graphics.draw(wallImage, door.x + self.camera.x, door.y + self.camera.y)
		if door.open then
			love.graphics.draw(self.doorImages[math.floor(door.animation)+1], door.x + self.camera.x, door.y - self.tileSize + self.camera.y)
		else
			love.graphics.draw(self.doorImages[math.floor(door.animation)+1], door.x + self.camera.x, door.y - self.tileSize + self.camera.y)
		end
	end
	
	love.graphics.setColor(128, 0, 0)
	for i, gate in pairs(self.gates) do
		love.graphics.rectangle("fill", gate.x + self.camera.x, gate.y + self.camera.y, gate.w, gate.h)
	end
	
	love.graphics.setColor(255, 255, 255)
	for i, terminal in pairs(self.terminals) do
		love.graphics.draw(self.terminalImages[math.floor(self.terminalAnimation)+1], terminal.x + self.camera.x, terminal.y + self.camera.y)
	end
	
	love.graphics.setColor(255, 255, 255)
	self.player:draw(self.camera)
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
	if key == "escape" then
		self.game:addToScreenStack(self.game.pauseMenu)
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