



require "class"
require "menu"
-- require "button"

MainMenu = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function MainMenu:_init(game)
	-- this is for the draw stack
	self.drawUnder = false
	self.updateUnder = false

	self.game = game
	self.menu = Menu(self.game, {"Play", "Exit", "Credits"}, 750, 310)
	self.SCREENWIDTH = self.game.SCREENWIDTH
	self.SCREENHEIGHT = self.game.SCREENHEIGHT
	self.font = love.graphics.newFont(32)
	self.fontHeight = self.font:getHeight()
	
	-- self.image = love.graphics.newImage('mainmenu.png')
	self.joystickIndicatorGrowing = true
	self.joystickIndicatorScale = 1
	
	self.image = love.graphics.newImage('art/menuBackground.png')
	
	self.game.startMusic:play()
end

function MainMenu:load()
	-- run when the level is given control
	love.graphics.setFont(self.font)
	love.mouse.setVisible(true)
	love.graphics.setBackgroundColor(255, 255, 255)
end

function MainMenu:leave()
	-- run when the level no longer has control
end

function MainMenu:draw()
	love.graphics.draw(self.image, 0, 0)
	-- love.graphics.draw(self.image, 130, 100, 0, 1, 1)
	-- if self.hasJoysticks then -- display that you have a joystick connected
	-- 	love.graphics.setColor(0, 0, 128)--90, 100, 255)
	-- 	love.graphics.printf("With Controllers!", 172, 250, 500, "center", -.27, self.joystickIndicatorScale, self.joystickIndicatorScale)
	-- end
	love.graphics.setColor(0, 0, 0)
	love.graphics.printf("F2 - FullScreen", self.SCREENWIDTH - 1000, 1020, 940, "right")
	self.menu:draw()
end

function MainMenu:update(dt)
	--
end

function MainMenu:resize(w, h)
	--
end

function MainMenu:keypressed(key, unicode)
	local choice = self.menu:keypressed(key, unicode)
	if choice ~= nil then
		self:selectButton(choice)
	elseif key == "joystickback" then
		self:selectButton("Exit")
	elseif key == "joystickstart" then
		self:selectButton("Play")
	end
end

function MainMenu:selectButton(choice)
	if choice == "ERROR" then
		-- not actually an error, just there
		-- print("ERROR ON MAIN MENU BUTTON SELECT!!!!")
	elseif choice == "Play" then
		self.game.startMusic:stop()
		self.game:addToScreenStack(self.game.intro)
	elseif choice == "Exit" then
		love.event.quit()
	elseif choice == "Credits" then
		-- test things for jordan
		self.game:addToScreenStack(self.game.credits)
	end
end

function MainMenu:keyreleased(key, unicode)
	--
end

function MainMenu:mousepressed(x, y, button)
	-- self:selectButton(self.menu:mousepressed(x, y, button))
end

function MainMenu:mousereleased(x, y, button)
	self:selectButton(self.menu:mousepressed(x, y, button))
end

function MainMenu:mousemoved(x, y, dx, dy, istouch)
	self.menu:mousemoved(x, y, dx, dy, istouch)
end