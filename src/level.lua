require "class"

Level = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Level:_init(game, player)
	self.game = game
	self.terminal = Terminal(self.game, self)
	self.player = player
	self.walls = {}
	self.ladders = {}
	self.doors = {}
	self.levers = {}
	self.levelArray = {}
	self.backgrounds = {}
	local lines = {}			
	
	for line in love.filesystem.lines('level1.txt') do
		if line == "--buttons--" then
			break
		end
		lines[#lines + 1] = line
		self.levelArray[#self.levelArray + 1] = {}
		for i = 1, #line, 1 do
			self.levelArray[#self.levelArray][#self.levelArray[#self.levelArray]+1] = string.sub(line, i, i)
		end
	end

	local lineCount = 0
	for line in love.filesystem.lines('level1.txt') do
		lineCount = lineCount + 1
		if lineCount > #self.levelArray then
			for word in line:gmatch("%w+") do
				table.insert(line, word)
			end
		end
	end
	
	ladderImage = love.graphics.newImage('art/wallTileWithLadder.png')
	wallImage = love.graphics.newImage('art/wallTile1.png')
	foregroundImage = love.graphics.newImage('art/foregroundWallTile.png')
	
	self.tileSize = 160
	
	self.camera = {x = 0, y = 0, dx = 0, dy = 0}

	for y, row in pairs(self.levelArray) do
		for x, tile in pairs(row) do
			if tile == 'w' then
				table.insert(self.walls, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize, h = self.tileSize})
			elseif tile == ' ' then
				table.insert(self.backgrounds, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize, h = self.tileSize})
			elseif tile == 'l' then
				table.insert(self.ladders, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize})
			elseif string.byte(tile) >= string.byte('a') and string.byte(tile) <= string.byte("j") then
				table.insert(self.levers, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize, key=tile, on=false})
			elseif string.byte(tile) >= string.byte('A') and string.byte(tile) <= string.byte("J") then
				table.insert(self.doors, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize, h=3*self.tileSize, key=tile, open = false})
			end
		end
	end
	self.screen = {w = 1920, h = 1080}
	self.cameraBuffer = 900
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
			love.graphics.setColor(255, 155, 155)
		else
			love.graphics.setColor(155, 0, 0)
		end
		love.graphics.rectangle("fill", lever.x + self.camera.x, lever.y + self.camera.y, lever.w, lever.w)
	end
	
	love.graphics.setColor(0, 155, 0)
	for i, door in pairs(self.doors) do
		if door["open"] then
			love.graphics.rectangle("fill", door.x + self.camera.x, door.y + self.camera.y, 0.2 * door.w, door.h)
		else
			love.graphics.rectangle("fill", door.x + self.camera.x, door.y + self.camera.y, door.w, door.h)
		end
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
		--self.camera.y = 0
	elseif self.camera.y < -#self.levelArray*self.tileSize + self.screen.h then
		--self.camera.y = -#self.levelArray[1]*self.tileSize + self.screen.h
	end
end

function Level:update(dt)
	self.player:update(dt, self)
	self:cameraUpdate(dt)
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