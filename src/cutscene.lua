



require "class"
require "menu"
-- require "button"

Cutscene = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Cutscene:_init(game)
	-- this is for the draw stack
	self.drawUnder = false
	self.updateUnder = false

	self.game = game
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
end

function Cutscene:load()
	-- run when the level is given control
	love.graphics.setFont(self.font)
	love.mouse.setVisible(false)
	love.graphics.setBackgroundColor(0, 0, 0)

end

function Cutscene:leave()
	-- run when the level no longer has control
end

function Cutscene:draw()
	love.graphics.printf(self.lines[self.game.level.currentLevel], self.SCREENWIDTH / 2 - 350, self.SCREENHEIGHT / 2, 700, "center")
end

function Cutscene:update(dt)
	local mX = love.mouse.getX()
	local mY = love.mouse.getY()
end

function Cutscene:resize(w, h)
	--
end

function Cutscene:keypressed(key, unicode)
	print("key pressed in pause menu: "..key)
	if key == "space" or key == "joysticka" then
		self.game:popScreenStack()
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
	self.game:addToScreenStack(self.game.level)
	self.game.level:initialize()
end

function Cutscene:mousemoved(x, y, dx, dy, istouch)
	-- self.menu:mousemoved(x, y, dx, dy, istouch)
end