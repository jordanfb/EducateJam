
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

	self.rightflickup = false
	self.rightflickdown = false
	self.rightflickleft = false
	self.rightflickright = false
	self.flickTimerStart = .2
	self.flickTimer = self.flickTimerStart

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
	if #self.gamepads == 0 then
		self.game.useJoystick = false
	end
end

function GamepadManager:getJoysticks()
	self.joysticks = love.joystick.getJoysticks()
	for k, v in pairs(self.joysticks) do
		if v:isGamepad() then
			self.gamepads[#self.gamepads+1] = v
		end
	end
	if #self.gamepads == 0 then
		self.game.useJoystick = false
	end
end

function GamepadManager:hasJoysticks()
	self:getJoysticks()
	return #self.gamepads > 0
end

function GamepadManager:gamepadpressed(gamepad, button)
	-- self.gamepadManager:(gamepad, button)
	self.game:keypressed("joystick"..button, "")
	love.mouse.setVisible(false)
	self.game.useJoystick = true
end

function GamepadManager:update(dt)
	if self.flickTimer > 0 then
		self.flickTimer = self.flickTimer - dt
		if self.flickTimer < 0 then
			self.flickTimer = 0
		end
	end
end

function GamepadManager:gamepadaxis( joystick, axis, value )
	if math.abs(value) > .25 then
		love.mouse.setVisible(false)
		self.game.useJoystick = true
	-- elseif math.abs(value) < .05 then
	-- 	self.leftflickup = false
	-- 	self.leftflickdown = false
	-- 	self.leftflickleft = false
	-- 	self.leftflickright = false

	-- 	self.rightflickup = false
	-- 	self.rightflickdown = false
	-- 	self.rightflickleft = false
	-- 	self.rightflickright = false
	end
	-- self.gamepadManager:gamepadaxis(joystick, axis, value)
	-- if axis == "leftx" then
	-- 	local changeX = value-self.leftx
	-- 	if changeX > 0 then
	-- 		if not self.leftflickright then
	-- 			self.game:keypressed("menuLeft", "")
	-- 			self.leftflickright = true
	-- 		end
	-- 		if self.leftflickleft then
	-- 			self.leftflickleft = false
	-- 		end
	-- 	elseif changeX < 0 then
	-- 		if not self.leftflickleft then
	-- 			self.game:keypressed("menuLeft", "")
	-- 			self.leftflickleft = true
	-- 		end
	-- 		if self.leftflickright then
	-- 			self.leftflickright = false
	-- 		end
	-- 	end
	-- 	self.leftx = value
	if axis == "leftx" then
		local changeX = value-self.leftx
		if value > .1 then
			if changeX > 0 then
				if not self.leftflickright and self.flickTimer <= 0 then
					self.game:keypressed("menuRight", "")
					self.leftflickright = true
					self.flickTimer = self.flickTimerStart
				end
			else
				self.leftflickright = false
			end
		elseif value < -.1 then
			if changeX < 0 then
				if not self.leftflickleft and self.flickTimer <= 0 then
					self.game:keypressed("menuLeft", "")
					self.leftflickleft = true
					self.flickTimer = self.flickTimerStart
				end
			else
				self.leftflickleft = false
			end
		elseif math.abs(value) < .1 then
			self.leftflickright = false
			self.leftflickleft = false
		end
		self.leftx = value
	elseif axis == "lefty" then
		local changeY = value-self.lefty
		if value > .1 then -- it's lower half
			if changeY > 0 then
				if not self.leftflickdown and self.flickTimer <= 0 then
					self.game:keypressed("menuDown", "")
					self.leftflickdown = true
					self.flickTimer = self.flickTimerStart
				end
			else
				self.leftflickdown = false
			end
		elseif value < -.1 then
			if changeY < 0 then
				if not self.leftflickup and self.flickTimer <= 0 then
					self.game:keypressed("menuUp", "")
					self.leftflickup = true
					self.flickTimer = self.flickTimerStart
				end
			else
				self.leftflickup = false
			end
		elseif math.abs(value) < .1 then
			self.leftflickup = false
			self.leftflickdown = false
		end
		self.lefty = value
	end

	if axis == "rightx" then
		local changeX = value-self.rightx
		if value > .1 then
			if changeX > 0 then
				if not self.rightflickright and self.flickTimer <= 0 then
					self.game:keypressed("menuRight", "")
					self.rightflickright = true
					self.flickTimer = self.flickTimerStart
				end
			else
				self.rightflickright = false
			end
		elseif value < -.1 then
			if changeX < 0 then
				if not self.rightflickleft and self.flickTimer <= 0 then
					self.game:keypressed("menuLeft", "")
					self.rightflickleft = true
					self.flickTimer = self.flickTimerStart
				end
			else
				self.rightflickleft = false
			end
		elseif math.abs(value) < .1 then
			self.rightflickright = false
			self.rightflickleft = false
		end
		self.rightx = value
	elseif axis == "righty" then
		local changeY = value-self.righty
		if value > .1 then -- it's lower half
			if changeY > 0 then
				if not self.rightflickdown and self.flickTimer <= 0 then
					self.game:keypressed("menuDown", "")
					self.rightflickdown = true
					self.flickTimer = self.flickTimerStart
				end
			else
				self.rightflickdown = false
			end
		elseif value < -.1 then
			if changeY < 0 then
				if not self.rightflickup and self.flickTimer <= 0 then
					self.game:keypressed("menuUp", "")
					self.rightflickup = true
					self.flickTimer = self.flickTimerStart
				end
			else
				self.rightflickup = false
			end
		elseif math.abs(value) < .1 then
			self.rightflickup = false
			self.rightflickdown = false
		end
		self.lefty = value
	end
	-- print("axis values ".. self.lefty..", "..self.righty)
end