



require "class"
require "menu"
-- require "button"

PauseMenu = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function PauseMenu:_init(game)
	-- this is for the draw stack
	self.drawUnder = true
	self.updateUnder = false

	self.game = game
	self.menu = Menu(self.game, {"Resume", "Exit"})
	self.SCREENWIDTH = self.game.SCREENWIDTH
	self.SCREENHEIGHT = self.game.SCREENHEIGHT
	self.font = love.graphics.newFont(32)
	self.fontHeight = self.font:getHeight()
	
	-- self.image = love.graphics.newImage('mainmenu.png')
	self.hasJoysticks = false
	self.joystickIndicatorGrowing = true
	self.joystickIndicatorScale = 1
end

function PauseMenu:load()
	-- run when the level is given control
	love.graphics.setFont(self.font)
	love.mouse.setVisible(true)
	love.graphics.setBackgroundColor(255, 255, 255)
end

function PauseMenu:leave()
	-- run when the level no longer has control
end

function PauseMenu:draw()
	-- love.graphics.draw(self.image, 130, 100, 0, 1, 1)
	if self.hasJoysticks then -- display that you have a joystick connected
		love.graphics.setColor(0, 0, 128)--90, 100, 255)
		love.graphics.printf("With Controllers!", 172, 250, 500, "center", -.27, self.joystickIndicatorScale, self.joystickIndicatorScale)
	end
	love.graphics.setColor(0, 0, 0)
	love.graphics.printf("F2 - FullScreen", 0, 700, 600, "center")
	self.menu:draw()
end

function PauseMenu:update(dt)
	local mX = love.mouse.getX()
	local mY = love.mouse.getY()
	if self.joystickIndicatorGrowing then
		self.joystickIndicatorScale = self.joystickIndicatorScale + dt*.03
		if self.joystickIndicatorScale > 1.01 then
			self.joystickIndicatorGrowing = false
		end
	else
		self.joystickIndicatorScale = self.joystickIndicatorScale - dt*.03
		if self.joystickIndicatorScale < .99 then
			self.joystickIndicatorGrowing = true
		end
	end
	self.menu:update(dt)
end

function PauseMenu:resize(w, h)
	--
end

function PauseMenu:keypressed(key, unicode)
	-- if key == "space" then
	-- 	self.game.level:reset() -- play
	-- 	self.game:addToScreenStack(self.game.level)
	-- end
	local choice = self.menu:keypressed(key, unicode)
	if choice ~= nil then
		self:selectButton(choice)
	end
end

function PauseMenu:selectButton(choice)
	if choice == "ERROR" then
		print("ERROR ON MAIN MENU BUTTON SELECT!!!!")
	elseif choice == "Resume" then
		self.game:popScreenStack()
	elseif choice == "Exit" then -- exit to menu
		self.game:popScreenStack()
		self.game:popScreenStack()
	-- elseif choice == "Test" then
	-- 	-- test things for jordan
	-- 	self.game:addToScreenStack(self.game.terminal)
	end
end

function PauseMenu:keyreleased(key, unicode)
	--
end

function PauseMenu:mousepressed(x, y, button)
	-- self:selectButton(self.menu:mousepressed(x, y, button))
end

function PauseMenu:mousereleased(x, y, button)
	self:selectButton(self.menu:mousepressed(x, y, button))
	-- for k, v in pairs(self.buttons) do
	-- 	if v:updateMouse(x, y) then
	-- 		-- print(v.text .. " was pressed")
	-- 		if v.text == "Quit" then
	-- 			love.event.quit()
	-- 		elseif v.text == "Play" then
	-- 			self.game.level:reset()
	-- 			self.game:addToScreenStack(self.game.level)
	-- 		elseif v.text == "Test" then
	-- 			self.game:addToScreenStack(self.game.joystickTester)
	-- 		end
	-- 	end
	-- end
end

function PauseMenu:mousemoved(x, y, dx, dy, istouch)
	self.menu:mousemoved(x, y, dx, dy, istouch)
end