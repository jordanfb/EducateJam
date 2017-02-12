require "class"
require "menu"
-- require "button"

Credits = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Credits:_init(game, pausemenu)
	-- this is for the draw stack
	self.drawUnder = true
	self.updateUnder = false
	self.pausemenu = pausemenu

	self.game = game
	self.button = Button("Back", 950, 880, 300, 100, 32, game)
	self.SCREENWIDTH = self.game.SCREENWIDTH
	self.SCREENHEIGHT = self.game.SCREENHEIGHT
	self.font = love.graphics.newFont(32)
	self.fontHeight = self.font:getHeight()
	
	-- self.image = love.graphics.newImage('mainmenu.png')
	self.hasJoysticks = false
	self.joystickIndicatorGrowing = true
	self.joystickIndicatorScale = 1
	self.selection = 0
	
	
end

function Credits:load()
	-- run when the level is given control
	love.graphics.setFont(self.font)
	love.mouse.setVisible(true)
	love.graphics.setBackgroundColor(255, 255, 255)
end

function Credits:leave()
	-- run when the level no longer has control
end

function Credits:draw()
	-- love.graphics.draw(self.image, 130, 100, 0, 1, 1)
	--love.graphics.setColor(0, 0, 0)
	--love.graphics.rectangle("fill", 80, 80, self.SCREENWIDTH-160, self.SCREENHEIGHT-160)
	love.graphics.setColor(0, 0, 0, 200)
	love.graphics.rectangle("fill", 80, 80, self.SCREENWIDTH-160, self.SCREENHEIGHT-160, 50, 50)
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("line", 80, 80, self.SCREENWIDTH-160, self.SCREENHEIGHT-160, 50, 50)
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(love.graphics.newFont("fonts/november.ttf", 48))
	love.graphics.printf("Game programming, art and design by \nMartin Duffy, Jordan Faas-Busch, Simon Hopkins, Tristan Protzman\nMusic and Sound by: Eric Skiff\nMade in 24 hours for\nRPI Educational Game Jam", 0, 150, self.SCREENWIDTH, "center")
	
	self.button:draw()
end

function Credits:update(dt)
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
	self.button:updateMouse(mX, mY)
end

function Credits:resize(w, h)
	--
end

function Credits:keypressed(key, unicode)
	print("key pressed in pause menu: "..key)
	-- if key == "space" then
	-- 	self.game.level:reset() -- play
	-- 	self.game:addToScreenStack(self.game.level)
	-- end
	if key == "joysticka" then
		self:selectButton("Back")
	elseif key == "joystickb" then
		self:selectButton("Back")
	elseif key == "escape" then
		self:selectButton("Back")
	end
end

function Credits:selectButton(choice)
	if choice == "None" then
		-- print("ERROR ON MAIN MENU BUTTON SELECT!!!!")
		-- do nothing, it's probably fine.
	elseif choice == "Back" then
		self.game:popScreenStack()
		self.game:addToScreenStack(self.game.mainMenu)
	-- elseif choice == "Test" then
	-- 	-- test things for jordan
	-- 	self.game:addToScreenStack(self.game.terminal)
	end
end 

function Credits:keyreleased(key, unicode)
	--
end

function Credits:mousepressed(x, y, button)
	--
end

function Credits:mousereleased(x, y, button)
	if self.button:updateMouse(x, y, button) then
		self:selectButton("Back")
	end
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
--[[
		love.graphics.setColor(255, 255, 255)
		if self.selection==i then
			love.graphics.setColor(255, 255, 255, 125)
		end
		love.graphics.draw(self.gateImages[i], 100, 300*i - 150)]]

function Credits:mousemoved(x, y, dx, dy, istouch)
	self.button:mousemoved(x, y, dx, dy, istouch)
end