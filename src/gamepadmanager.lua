
require "class"


GamepadManager = class()



function GamepadManager:_init(game)
	self.game = game
	self.joysticks = {}
	self.gamepads = {}
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