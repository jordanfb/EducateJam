



require "class"
require "menu"
require "endscene"
-- require "button"

Cutscene = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Cutscene:_init(game)
	-- this is for the draw stack
	self.drawUnder = false
	self.updateUnder = false

	self.game = game
	self.endScene = Endscene(self.game)

	-- self.menu = Menu(self.game, {"Resume", "Exit", "Reset"})
	self.SCREENWIDTH = self.game.SCREENWIDTH
	self.SCREENHEIGHT = self.game.SCREENHEIGHT
	self.font = love.graphics.newFont("fonts/november.ttf", 50)

	self.fontHeight = self.font:getHeight()
	
	-- self.image = love.graphics.newImage('mainmenu.png')
	self.hasJoysticks = false
	self.joystickIndicatorGrowing = true
	self.joystickIndicatorScale = 1
	self.lines = {}
	for line in love.filesystem.lines("levels/cutscenes.txt") do
		print(line)
		self.lines[#self.lines + 1] = line
	end

	self.time = 0
	self.fadeTime = 0.5
	self.totalTime = 8
end

function Cutscene:load()
	-- run when the level is given control
	self.time = 0
	love.graphics.setFont(self.font)
	love.mouse.setVisible(false)
	love.graphics.setBackgroundColor(0, 0, 0)

end

function Cutscene:leave()
	-- run when the level no longer has control
end

function Cutscene:draw()
	local thisLevel = self.game.level.currentLevel * 2
	local pic = love.graphics.newImage(self.lines[thisLevel + 1])
	width = pic:getWidth()
	height = pic:getHeight()
	love.graphics.draw(pic, self.SCREENWIDTH / 2, 200, 0, 1, 1, width / 2, height / 2)
	love.graphics.printf(self.lines[thisLevel], self.SCREENWIDTH / 2 - 350, self.SCREENHEIGHT / 2, 700, "center")
end

function Cutscene:update(dt)
	self.time = self.time + dt

	if self.time > self.totalTime then
		self.game:popScreenStack()
		if self.game.level.currentLevel > self.game.level.totalLevels then
			self.game:addToScreenStack(self.endScene)
		else
			self.game:addToScreenStack(self.game.level)
			self.game.level:initialize()
		end
	elseif self.time > self.totalTime - self.fadeTime then
		local value = (self.totalTime - self.time) * 255
		value = 255 - math.abs(math.floor(value + 0.5))
		love.graphics.setBackgroundColor(value, value, value)
	end


	local mX = love.mouse.getX()
	local mY = love.mouse.getY()
end

function Cutscene:resize(w, h)
	--
end

function Cutscene:keypressed(key, unicode)
	if key == "menuUp" or key == "menuDown" or key == "menuLeft" or key == "menuRight" then
		return -- ignore the glitchy controller
	end
	self.game:popScreenStack()
	if self.game.level.currentLevel > self.game.level.totalLevels then
		self.game:addToScreenStack(self.endScene)
	else
		self.game:addToScreenStack(self.game.level)
		self.game.level:initialize()
	end
end

function Cutscene:selectButton(choice)

end

function Cutscene:keyreleased(key, unicode)
	--
end

function Cutscene:mousepressed(x, y, button)
	-- self:selectButton(self.menu:mousepressed(x, y, button))
end

function Cutscene:mousereleased(x, y, button)
	self.game:popScreenStack()
	if self.game.level.currentLevel > self.game.level.totalLevels then
		self.game:addToScreenStack(self.endScene)
	else
		self.game:addToScreenStack(self.game.level)
		self.game.level:initialize()
	end
end

function Cutscene:mousemoved(x, y, dx, dy, istouch)
	-- self.menu:mousemoved(x, y, dx, dy, istouch)
end