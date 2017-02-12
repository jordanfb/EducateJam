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
	self.back = Button("Back", 950, 880, 300, 100, 32, game)
	self.SCREENWIDTH = self.game.SCREENWIDTH
	self.SCREENHEIGHT = self.game.SCREENHEIGHT
	self.font = love.graphics.newFont(32)
	self.fontHeight = self.font:getHeight()
	
	-- self.image = love.graphics.newImage('mainmenu.png')
	self.hasJoysticks = false
	self.joystickIndicatorGrowing = true
	self.joystickIndicatorScale = 1
	self.selection = 0
							--1			--2			--3			--4			--5			--6			--7
	self.gateNames = {"BUFFER GATE", "NOT GATE", "AND GATE", "OR GATE", "XOR GATE", "NAND GATE", "NOR"}
	
	self.gateDescriptions = {"The input of this gate is always the output!",
							 "This gate inverts the input for the output!",
							 "The input and output of this gate must both be on for the output to be on!",
							 "If either input is on, so is the output!",
							 "Exactly one input to this gate must be on for the output to be on!",
							 "As long as at least one input is off, the output of this gate is on!",
							 "The output of this gate is only on if both inputs are off!"}
	
	self.truthTables = { {{'A', 'B', 'O'},
             			  {'0', '-', '0'},
						  {'0', '-', '0'},
						  {'1', '-', '1'},
						  {'1', '-', '1'}},
						  
						 {{'A', 'B', 'O'},
						  {'0', '-', '1'},  --not
						  {'0', '-', '1'},
						  {'1', '-', '0'},
						  {'1', '-', '0'}},
						  
						 {{'A', 'B', 'O'},
						  {'0', '0', '0'},  --and
						  {'0', '1', '0'},
						  {'1', '0', '0'},
						  {'1', '1', '1'}},
						  
						 {{'A', 'B', 'O'},
						  {'0', '0', '0'},  --or
						  {'0', '1', '1'},
						  {'1', '0', '1'},
						  {'1', '1', '1'}},
						  
						 {{'A', 'B', 'O'},
						  {'0', '0', '0'},  --xor
						  {'0', '1', '1'},
						  {'1', '0', '1'},
						  {'1', '1', '0'}},
						  
						 {{'A', 'B', 'O'},
						  {'0', '0', '1'},  --nand
						  {'0', '1', '1'},
						  {'1', '0', '1'},
						  {'1', '1', '0'}},
						  
						 {{'A', 'B', 'O'},
						  {'0', '0', '1'},  --nor
						  {'0', '1', '0'},
						  {'1', '0', '0'},
						  {'1', '1', '0'}}}
						  
						  
	
	
	
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
	love.graphics.setColor(0, 132, 0)
	love.graphics.setFont(love.graphics.newFont("fonts/november.ttf", 48))
	love.graphics.printf(self.gateDescriptions[self.pausemenu.selection], 1150, 460, 600, "center")
	
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.gateImages[self.pausemenu.selection], 200, 400)
	
	love.graphics.setFont(love.graphics.newFont("fonts/november.ttf", 64))
	love.graphics.printf(self.gateNames[self.pausemenu.selection], 800, 200, 300, "center")
	
	for i = 1, 4 do
		for j = 1, 3 do
			love.graphics.setFont(love.graphics.newFont("fonts/november.ttf", 32))
			love.graphics.printf(self.truthTables[self.pausemenu.selection][i][j], 600 + 100*j, 300 + 100*i, 300, "center")
		end
	end
	
	
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

function Helpmenu:mousepressed(x, y, button)
	-- self:selectButton(self.menu:mousepressed(x, y, button))
end

function Helpmenu:mousereleased(x, y, button)
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