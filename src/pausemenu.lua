



require "class"
require "menu"
-- require "button"

PauseMenu = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function PauseMenu:_init(game, level)
	-- this is for the draw stack
	self.drawUnder = true
	self.updateUnder = false

	self.game = game
	self.level = level
	self.menu = Menu(self.game, {"Resume", "Exit", "Reset"})
	self.SCREENWIDTH = self.game.SCREENWIDTH
	self.SCREENHEIGHT = self.game.SCREENHEIGHT
	self.font = love.graphics.newFont(32)
	self.fontHeight = self.font:getHeight()
	
	-- self.image = love.graphics.newImage('mainmenu.png')
	self.selection = 0
	
	self.gateImages = {}
	for i = 1, 7 do
		self.gateImages[i] = love.graphics.newImage('art/bigGateTile'..i..'.png')
	end

	--[[
4,	1,	8
	2,	
5,	3, 	9
6,	7,	10


	]]--

	self.joystickSelected = 1
	local JSone = {7, 2, 4, 8} -- up, down, left, right
	local JStwo = {1, 3, 4, 8}
	local JSthree = {2, 7, 5, 9}
	local JSfour = {6, 5, 8, 1}
	local JSfive = {4, 6, 9, 3}
	local JSsix = {5, 4, 10, 7}
	local JSseven = {3, 1, 6, 10}
	local JSeight = {10, 9, 1, 4}
	local JSnine = {8, 10, 3, 5}
	local JSten = {9, 8, 7, 6}
	self.joystickMoveMap = {JSone, JStwo, JSthree, JSfour, JSfive, JSsix, JSseven, JSeight, JSnine, JSten}
end

-- function PauseMenu:selectJoystickButtonMethod(i)
-- 	-- this is the third system of selections, which combines them all into one giant thing
-- 	-- essentially just adds Martin's selection thing onto the button selection thing
-- 	if i <= 3 then
-- 		self:selectButtonTurnOn(i)
-- 	else
-- 		self:selectOtherthing(i-3)
-- 	end
-- end

function PauseMenu:selectButtonTurnOn(i)
	local c = 1
	for k, v in pairs(self.menu.buttons) do
		v.selected = (i == c)
		c = c + 1
	end
	self.selection = 0
end

function PauseMenu:selectOtherthing(i)
	for k, v in pairs(self.menu.buttons) do
		v.selected = false
	end
	self.selection = i
end

function PauseMenu:setJoystickSelected()
	-- this is the third system of selections, which combines them all into one giant thing
	-- essentially just adds Martin's selection thing onto the button selection thing
	if self.joystickSelected <= 3 then
		self:selectButtonTurnOn(self.joystickSelected)
	else
		self:selectOtherthing(self.joystickSelected-3)
	end
end

function PauseMenu:load()
	-- run when the level is given control
	love.graphics.setFont(self.font)
	love.mouse.setVisible(true)
	love.graphics.setBackgroundColor(1, 1, 1)
	self.joystickSelected = 1
end

function PauseMenu:leave()
	-- run when the level no longer has control
end

function PauseMenu:draw()
	-- love.graphics.draw(self.image, 130, 100, 0, 1, 1)
	love.graphics.setColor(0, 0, 0, 200/255)
	love.graphics.rectangle("fill", 80, 80, self.SCREENWIDTH-160, self.SCREENHEIGHT-160, 50, 50)
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", 80, 80, self.SCREENWIDTH-160, self.SCREENHEIGHT-160, 50, 50)
	-- if self.hasJoysticks then -- display that you have a joystick connected
		-- love.graphics.setColor(0, 0, 128)--90, 100, 255)
		-- love.graphics.printf("With Controllers!", 172, 250, 500, "center", -.27, self.joystickIndicatorScale, self.joystickIndicatorScale)
	-- end
	
	for i = 1, 3 do
		love.graphics.setColor(1, 1, 1)
		if self.selection==i then
			love.graphics.setColor(1, 1, 1, 125/255)
		end
		love.graphics.draw(self.gateImages[i], 100, 300*i - 150)
	end
	
	love.graphics.setColor(1, 1, 1)
	if self.selection==4 then
		love.graphics.setColor(1, 1, 1, 125/255)
	end
	love.graphics.draw(self.gateImages[4], self.SCREENWIDTH/2 - 240, 300*3 - 150)
	
	for i = 1, 3 do
		love.graphics.setColor(1, 1, 1)
		if self.selection==i+4 then
			love.graphics.setColor(1, 1, 1, 125/255)
		end
		love.graphics.draw(self.gateImages[4+i], self.SCREENWIDTH-240-320, 300*i - 150)
	end
	
	self.menu:draw()
end

function PauseMenu:update(dt)
	local mX = love.mouse.getX()
	local mY = love.mouse.getY()
	self.menu:update(dt)
	if self.game.useJoystick then
		self:setJoystickSelected()
	end
end

function PauseMenu:resize(w, h)
	--
end

function PauseMenu:keypressed(key, unicode)
	-- print("key pressed in pause menu: "..key)
	-- if key == "space" then
	-- 	self.game.level:reset() -- play
	-- 	self.game:addToScreenStack(self.game.level)
	-- end
	local joystickUsed = false

	if key == "joysticka" then
		joystickUsed = true
		if self.joystickSelected <= 3 then
			self:selectButton(self.menu.buttons[self.joystickSelected].text)
		else
			self.game:popScreenStack()
			self.game:addToScreenStack(self.game.helpmenu)
		end
	elseif key == "joystickb" then
		self:selectButton("Resume")
	elseif key == "escape" then
		self:selectButton("Resume")
	elseif key == "joystickback" then
		self:selectButton("Exit")
	elseif key == "joystickstart" then
		self:selectButton("Resume")
	elseif key == "menuUp" or key == "w" or key == "up" then
		self.joystickSelected = self.joystickMoveMap[self.joystickSelected][1]
		joystickUsed = true
	elseif key == "menuDown" or key == "s" or key == "down" then
		self.joystickSelected = self.joystickMoveMap[self.joystickSelected][2]
		joystickUsed = true
	elseif key == "menuLeft" or key == "a" or key == "left" then
		self.joystickSelected = self.joystickMoveMap[self.joystickSelected][3]
		joystickUsed = true
	elseif key == "menuRight" or key == "d" or key == "right" then
		self.joystickSelected = self.joystickMoveMap[self.joystickSelected][4]
		joystickUsed = true
	end
	if joystickUsed and self.game.useJoystick then
		self:setJoystickSelected()
	end
end

function PauseMenu:selectButton(choice)
	if choice == "None" then
		-- print("ERROR ON MAIN MENU BUTTON SELECT!!!!")
		-- do nothing, it's probably fine.
	elseif choice == "Resume" then
		self.game:popScreenStack()
	elseif choice == "Reset" then
		self.game.level:reset()
		self.game:popScreenStack()
	elseif choice == "Exit" then -- exit to menu
		self.game:popScreenStack()
		self.game:popScreenStack()
		self.game.gameMusic:stop()
		self.game.startMusic:play()
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
	if self.selection > 0 then
		self.game:popScreenStack()
		self.game:addToScreenStack(self.game.helpmenu)
	end
	if self.game.useJoystick then
		self.button.selected = true
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
		love.graphics.setColor(1, 1, 1)
		if self.selection==i then
			love.graphics.setColor(1, 1, 1, 125/255)
		end
		love.graphics.draw(self.gateImages[i], 100, 300*i - 150)]]

function PauseMenu:mousemoved(x, y, dx, dy, istouch)
	local m = self.game:realToFakeMouse(x, y)
	self.menu:mousemoved(x, y, dx, dy, istouch)
	self.selection = 0
	if m.x > 100 and m.x < 420 and m.y > 150 and m.y < 150 + 900 then
		if m.y > 150 and m.y < 450 then
			self.selection = 1
		elseif m.y > 450 and m.y < 750 then
			self.selection = 2
		elseif m.y > 750 and m.y < 1050 then
			self.selection = 3
		end
	end
	if m.x > self.SCREENWIDTH-240-320 and m.x < self.SCREENWIDTH-240-320 + 320 and m.y > 150 and m.y < 150 + 900 then
		if m.y > 150 and m.y < 450 then
			self.selection = 5
		elseif m.y > 450 and m.y < 750 then
			self.selection = 6
		elseif m.y > 750 and m.y < 1050 then
			self.selection = 7
		end
	end
	if m.x > self.SCREENWIDTH/2 - 240 and m.x < self.SCREENWIDTH/2 - 240 + 360 and m.y > 300*3 - 150 and m.y < 900 - 150 + 240 then
		self.selection = 4
	end
	
	
end