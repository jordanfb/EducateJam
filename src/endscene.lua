require "class"
require "menu"
-- require "button"

Endscene = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Endscene:_init(game)
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

	self.time = 0
	self.fadeTime = 0.5
	self.totalTime = 6
end

function Endscene:load()
	-- run when the level is given control
	self.time = 0
	love.graphics.setFont(self.font)
	love.mouse.setVisible(false)
	love.graphics.setBackgroundColor(0, 0, 0)

end

function Endscene:leave()
	-- run when the level no longer has control
end

function Endscene:draw()
	local thisLevel = self.game.level.currentLevel * 2
	local pic = love.graphics.newImage("art/treasure4.png")
	width = pic:getWidth()
	height = pic:getHeight()
	love.graphics.draw(pic, self.SCREENWIDTH / 2, 200, 0, 1, 1, width / 2, height / 2)
	local text = ""
	if self.game.player.score == 26 then
		text = "Congratulations!!! You are awesome and completed the game in the minimum possible moves!  Try to see if you can go faster!"
	elseif self.game.player.score <= 26 then
		text = "Wow! We thought the best score was 26 but you did it in "..self.game.player.score.."! Please tell us your ways, Master of Logic!"
	else
		text = "You win! You completed the game in " .. self.game.player.score .. " moves, while the perfect score is 26.  Try to see if you can do better!"
	end
	love.graphics.printf(text, self.SCREENWIDTH / 2 - 350, self.SCREENHEIGHT / 2, 700, "center")
end

function Endscene:update(dt)
	self.time = self.time + dt
	local mX = love.mouse.getX()
	local mY = love.mouse.getY()
end

function Endscene:resize(w, h)
	--
end

function Endscene:keypressed(key, unicode)
	self.game:popScreenStack()
	self.game:addToScreenStack(self.game.mainMenu)
	self.game.startMusic:play()
	self.game.gameMusic:stop()
	self.game.level.currentLevel = 1
	self.game.player.score = 0
end

function Endscene:selectButton(choice)

end

function Endscene:keyreleased(key, unicode)
	--
end

function Endscene:mousepressed(x, y, button)
	-- self:selectButton(self.menu:mousepressed(x, y, button))
end

function Endscene:mousereleased(x, y, button)
	self.game:popScreenStack()
	self.game:addToScreenStack(self.game.mainMenu)
	self.game.startMusic:play()
	self.game.gameMusic:stop()
	self.game.level.currentLevel = 1
	self.game.player.score = 0
end

function Endscene:mousemoved(x, y, dx, dy, istouch)
	-- self.menu:mousemoved(x, y, dx, dy, istouch)
end