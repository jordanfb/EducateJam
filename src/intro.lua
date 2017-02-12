require "class"
require "menu"
-- require "button"

Intro = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Intro:_init(game)
	-- this is for the draw stack
	self.drawUnder = false
	self.updateUnder = false

	self.game = game
	-- self.menu = Menu(self.game, {"Resume", "Exit", "Reset"})
	self.SCREENWIDTH = self.game.SCREENWIDTH
	self.SCREENHEIGHT = self.game.SCREENHEIGHT

	-- self.image = love.graphics.newImage('mainmenu.png')
	self.hasJoysticks = false
	self.joystickIndicatorGrowing = true
	self.joystickIndicatorScale = 1
	self.lines = {}

	self.images = {}
	for i = 1, 20 do
		self.images[i] = love.graphics.newImage('art/openingScene'..i..'.png')
	end
	self.frame = 1
end

function Intro:load()
	-- run when the level is given control
	self.time = 0
	love.mouse.setVisible(false)
	love.graphics.setBackgroundColor(0, 0, 0)

end

function Intro:leave()
	-- run when the level no longer has control
end

function Intro:draw()
	love.graphics.draw(self.images[math.floor(self.frame)+1], 0, 0)
end

function Intro:update(dt)
	self.frame = self.frame + 0.05
	if self.frame > #self.images - 1 then
		self.frame = #self.images - 1
		self.game:popScreenStack()
		self.game:addToScreenStack(self.game.cutscene)
	end
end

function Intro:resize(w, h)
	--
end

function Intro:keypressed(key, unicode)
	self.game:popScreenStack()
	self.game:addToScreenStack(self.game.mainMenu)
	self.game.level.currentLevel = 1
	self.game.player.score = 0
end

function Intro:selectButton(choice)

end

function Intro:keyreleased(key, unicode)
	--
end

function Intro:mousepressed(x, y, button)
	-- self:selectButton(self.menu:mousepressed(x, y, button))
end

function Intro:mousereleased(x, y, button)
	self.game:popScreenStack()
	self.game:addToScreenStack(self.game.mainMenu)
	self.game.level.currentLevel = 1
	self.game.player.score = 0
end

function Intro:mousemoved(x, y, dx, dy, istouch)
	-- self.menu:mousemoved(x, y, dx, dy, istouch)
end