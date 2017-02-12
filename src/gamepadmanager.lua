
require "class"


GamepadManager = class()



function GamepadManager:_init(game)
	self.game = game
	self.joysticks = {}
	self.gamepads = {}
	self.leftflickup = false
	self.leftflickdown = false
	self.leftflickleft = false
	self.leftflickright = false

	self.leftx = 0
	self.lefty = 0
	self.rightx = 0
	self.righty = 0
end


function GamepadManager:addjoystick(joystick)
	self:getJoysticks()
end

function GamepadManager:removejoystick(joystick)
	self:getJoysticks()
end

function GamepadManager:getJoysticks()
	self.joysticks = love.joystick.getJoysticks()
	for k, v in pairs(self.joysticks) do
		if v:isGamepad() then
			self.gamepads[#self.gamepads+1] = v
		end
	end
end

function GamepadManager:hasJoysticks()
	self:getJoysticks()
	return #self.gamepads > 0
end

function GamepadManager:gamepadpressed(gamepad, button)
	-- self.gamepadManager:(gamepad, button)
	self.game:keypressed("joystick"..button)
	love.mouse.setVisible(false)
end

function GamepadManager:gamepadaxis( joystick, axis, value )
	love.mouse.setVisible(false)
	-- self.gamepadManager:gamepadaxis(joystick, axis, value)
	if axis == "leftx" then
		local changeX = value-self.leftx
		if changeX > 0 then
			if not self.leftflickright then
				self.game:keypressed("menuLeft", "")
				self.leftflickright = true
			end
			if self.leftflickleft then
				self.leftflickleft = false
			end
		elseif changeX < 0 then
			if not self.leftflickleft then
				self.game:keypressed("menuLeft", "")
				self.leftflickleft = true
			end
			if self.leftflickright then
				self.leftflickright = false
			end
		end
		self.leftx = value
	elseif axis == "lefty" then
		local changeY = value-self.lefty
		if value > .1 then -- it's lower half
			if changeY > 0 then
				if not self.leftflickdown then
					self.game:keypressed("menuDown", "")
					self.leftflickdown = true
				end
			else
				self.leftflickdown = false
			end
		elseif value < -.1 then
			if changeY < 0 then
				if not self.leftflickup then
					self.game:keypressed("menuUp", "")
					self.leftflickup = true
				end
			else
				self.leftflickup = false
			end
		end
		-- if changeY > 0 then
		-- 	if not self.leftflickdown then
				
		-- 	end
		-- 	if self.leftflickup then
		-- 		self.leftflickup = false
		-- 	end
		-- elseif changeY < 0 then
		-- 	if not self.leftflickup then
		-- 		self.game:keypressed("menuUp", "")
		-- 		self.leftflickup = true
		-- 	end
		-- 	if self.leftflickdown then
		-- 		self.leftflickdown = false
		-- 	end
		-- end
		self.lefty = value
	end
end