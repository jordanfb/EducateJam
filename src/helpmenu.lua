require "class"
require "menu"
-- require "button"

Helpmenu = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Helpmenu:_init(game, pausemenu)
	-- this is for the draw stack
	self.drawUnder = true
	self.updateUnder = false
	self.pausemenu = pausemenu

	self.game = game
	self.back = Button("Back", 300, 300, 300, 100, 32, game)
	self.SCREENWIDTH = self.game.SCREENWIDTH
	self.SCREENHEIGHT = self.game.SCREENHEIGHT
	self.font = love.graphics.newFont(32)
	self.fontHeight = self.font:getHeight()
	
	-- self.image = love.graphics.newImage('mainmenu.png')
	self.hasJoysticks = false
	self.joystickIndicatorGrowing = true
	self.joystickIndicatorScale = 1
	self.selection = 0
	
	self.gateImages = {}
	for i = 1, 7 do
		self.gateImages[i] = love.graphics.newImage('art/bigGateTile'..i..'.png')
	end
	
end

function Helpmenu:load()
	-- run when the level is given control
	love.graphics.setFont(self.font)
	love.mouse.setVisible(true)
	love.graphics.setBackgroundColor(255, 255, 255)
end

function Helpmenu:leave()
	-- run when the level no longer has control
end

function Helpmenu:draw()
	-- love.graphics.draw(self.image, 130, 100, 0, 1, 1)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", 80, 80, self.SCREENWIDTH-160, self.SCREENHEIGHT-160)
	love.graphics.setColor(255, 255, 255)
	self.back:draw()
end

function Helpmenu:update(dt)
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
end

function Helpmenu:resize(w, h)
	--
end

function Helpmenu:keypressed(key, unicode)
	print("key pressed in pause menu: "..key)
	-- if key == "space" then
	-- 	self.game.level:reset() -- play
	-- 	self.game:addToScreenStack(self.game.level)
	-- end
	if key == "joysticka" then
		local choice = self.menu:keypressed(key, unicode)
		if choice ~= nil then
			self:selectButton(choice)
		end
	elseif key == "joystickb" then
		self:selectButton("Resume")
	end
end

function Helpmenu:selectButton(choice)
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
	-- elseif choice == "Test" then
	-- 	-- test things for jordan
	-- 	self.game:addToScreenStack(self.game.terminal)
	end
end 

function Helpmenu:keyreleased(key, unicode)
	--
end

function PauseMenu:mousepressed(x, y, button)
	-- self:selectButton(self.menu:mousepressed(x, y, button))
end

function Helpmenu:mousereleased(x, y, button)
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
--[[
		love.graphics.setColor(255, 255, 255)
		if self.selection==i then
			love.graphics.setColor(255, 255, 255, 125)
		end
		love.graphics.draw(self.gateImages[i], 100, 300*i - 150)]]

function Helpmenu:mousemoved(x, y, dx, dy, istouch)
	self.back:mousemoved(x, y, dx, dy, istouch)

	
	
end