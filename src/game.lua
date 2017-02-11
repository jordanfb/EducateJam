
-- require "player"
require "level"
require "mainmenu"
require "player"
-- require "joysticktester"
-- require "pausemenu"
-- require "deathmenu"
-- require "joystickmanager"

require "class"

Game = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Game:_init()
	-- these are for draw stacks:
	self.drawUnder = false
	self.updateUnder = false

	-- here are the actual variables
	self.SCREENWIDTH = 1920
	self.SCREENHEIGHT = 1080
	self.fullscreen = false
	self.drawFPS = false
	
	self.player = Player(self)

	self.level = Level(self, self.player) -- we should have it load by filename or something.
	self.mainMenu = MainMenu(self)
	-- self.player = Player(self)
	-- self.level= Level(self, self.player)
	-- self.pauseMenu = PauseMenu(self)
	-- self.joystickTester = JoystickTester(self)
	-- self.deathMenu = DeathMenu(self)
	-- self.joystickManager = JoystickManager(self)
	self.screenStack = {}
	
	-- self.bg = love.graphics.newImage('images/bg.png')
	
	-- bgm = love.audio.newSource("music/battlemusic.mp3")
	-- bgm:setVolume(0.9) -- 90% of ordinary volume
	-- bgm:setLooping( true )
	-- bgm:play()
	love.graphics.setBackgroundColor(0, 0, 0)
	self:addToScreenStack(self.level)
	-- self:addToScreenStack(self.player)
	self.fullCanvas = love.graphics.newCanvas(self.SCREENWIDTH, self.SCREENHEIGHT)
end

function Game:load(args)
	--
end

function Game:takeScreenshot()
	local screenshot = love.graphics.newScreenshot()
	screenshot:encode('png', os.time()..'.png')
end

function Game:draw()
	love.graphics.setCanvas(self.fullCanvas)
	love.graphics.clear()
	-- love.graphics.draw(self.bg, 0, 0)

	local thingsToDraw = 1 -- this will become the index of the lowest item to draw
	for i = #self.screenStack, 1, -1 do
		thingsToDraw = i
		if not self.screenStack[i].drawUnder then
			break
		end
	end
	-- this is so that the things earlier in the screen stack get drawn first, so that things like pause menus get drawn on top.
	for i = thingsToDraw, #self.screenStack, 1 do
		self.screenStack[i]:draw()
		-- if i ~= 1 then
		-- 	print("DRAWING "..i)
		-- end
	end
	if (self.drawFPS) then
		love.graphics.setColor(255, 0, 0)
		love.graphics.print("FPS: "..love.timer.getFPS(), 10, love.graphics.getHeight()-45)
		love.graphics.setColor(255, 255, 255)
	end

	-- love.graphics.rectangle("fill", 0, 0, 600, 800)

	-- love.graphics.rectangle("fill", 0, 0, 1920, 1080)

	love.graphics.setCanvas()
	love.graphics.setColor(255, 255, 255)
	if self.fullscreen or true then
		local width = love.graphics.getWidth()
		local height = love.graphics.getHeight()
		local scale = math.min(height/1080, width/1920)
		-- width/2-300*scale
		love.graphics.draw(self.fullCanvas, width/2-1920/2*scale, height/2-1080/2*scale, 0, scale, scale)
		love.graphics.setColor(0, 0, 0)
		-- the left and right bars
		love.graphics.rectangle("fill", 0, 0, width/2-1920/2*scale, height)
		love.graphics.rectangle("fill", width/2+1920/2*scale, 0, width/2-1920/2*scale, height)
		-- the top and bottom bars
		-- love.graphics.setColor(255, 0, 0)
		love.graphics.rectangle("fill", 0, 0, width, height/2-1080/2*scale)
		love.graphics.rectangle("fill", 0, height, width, -(height/2-1080/2*scale))
		love.graphics.setColor(255, 255, 255)
	else
		local scale = math.min(love.graphics.getHeight()/1080, love.graphics.getWidth()/1920)
		love.graphics.draw(self.fullCanvas, 0, 0, 0, scale, scale)
	end
end

function Game:realToFakeMouse(x, y)
	-- converts from what the screen sees to what the game wants to see
	if not self.fullscreen then
		return {x = x, y = y}
	else
		local width = love.graphics.getWidth()
		local height = love.graphics.getHeight()
		local scale = math.min(height/800, width/600)
		return {x = (x-(width/2-300*scale))/scale, y = y/scale}
	end
end

function Game:update(dt)
	-- self.joystickManager:update(dt)
	for i = #self.screenStack, 1, -1 do
		self.screenStack[i]:update(dt)
		if self.screenStack[i] and not self.screenStack[i].updateUnder then
			break
		end
	end
end

function Game:popScreenStack()
	self.screenStack[#self.screenStack]:leave()
	self.screenStack[#self.screenStack] = nil
	self.screenStack[#self.screenStack]:load()
end

function Game:addToScreenStack(newScreen)
	if self.screenStack[#self.screenStack] ~= nil then
		self.screenStack[#self.screenStack]:leave()
	end
	self.screenStack[#self.screenStack+1] = newScreen
	newScreen:load()
end

function Game:resize(w, h)
	for i = 1, #self.screenStack, 1 do
		self.screenStack[i]:resize(w, h)
	end
	-- self.level:resize(w, h)
end

function Game:keypressed(key, unicode)
	self.screenStack[#self.screenStack]:keypressed(key, unicode)
	if key == "f2" or key == "f11" then
		self.fullscreen = not self.fullscreen
		love.window.setFullscreen(self.fullscreen)
	elseif key == "f3" then
		self:takeScreenshot()
	elseif key == "f1" then
		love.event.quit()
	end
end

function Game:keyreleased(key, unicode)
	self.screenStack[#self.screenStack]:keyreleased(key, unicode)
end

function Game:mousepressed(x, y, button)
	self.screenStack[#self.screenStack]:mousepressed(x, y, button)
end

function Game:mousereleased(x, y, button)
	self.screenStack[#self.screenStack]:mousereleased(x, y, button)
end

function Game:joystickadded(joystick)
	self.joystickManager:getJoysticks()
	self.mainMenu.hasJoysticks = self.joystickManager:hasJoysticks()
end

function Game:joystickremoved(joystick)
	self.joystickManager:getJoysticks()
	self.mainMenu.hasJoysticks = self.joystickManager:hasJoysticks()
end

function Game:quit()
	--
end