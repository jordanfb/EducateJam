


require "class"
require "button"

Menu = class()


function Menu:_init(game, buttons) -- buttons is a list of names in order of the buttons to press.
	self.selected = 1
	self.buttonNames = buttons
	self.font = love.graphics.newFont(32)
	self.fontHeight = self.font:getHeight()
	self.game = game
	self:makeButtons()
	self.useJoystick = false
end

function Menu:makeButtons()
	self.buttons = {}
	local x = 1920/2
	local buttonHeight = 100
	local buttonWidth = 300
	local y = 1080/2-(20+buttonHeight)*#self.buttonNames/2
	local i = 0
	local spacing = 20
	for k, v in pairs(self.buttonNames) do
		self.buttons[k] = Button(v, x, y+i*(buttonHeight+spacing), buttonWidth, buttonHeight, self.fontHeight, self.game)
		i = i + 1
	end
end

function Menu:draw()
	for k, v in pairs(self.buttons) do
		v:draw()
	end
end

function Menu:update(dt)
	local mx = love.mouse.getX()
	local my = love.mouse.getY()
	local i = 1
	for k, v in pairs(self.buttons) do
		if v:updateMouse(mx, my) then
			self.selected = i
			self.useJoystick = false
		end
		i = i + 1
	end
	if self.useJoystick then
		i = 1
		for k, v in pairs(self.buttons) do
			v:setSelected(i == self.selected)
			i = i + 1
		end
	end
end

function Menu:mousepressed(x, y, button)
	self:update(0) -- because mouse was pressed, assume that we need to use mouse
	self.useJoystick = false
	return self:returnPressed()
end

function Menu:returnPressed()
	local i = 1
	for k, v in pairs(self.buttons) do
		if i == self.selected then
			return v.text
		end
		i = i + 1
	end
	return "ERROR"
end

function Menu:keypressed(key, unicode)
	if key == "menuUp" then
		self.selected = self.selected - 1
		if self.selected <= 0 then
			self.selected = #self.buttons
		end
	elseif key == "menuDown" then
		self.selected = self.selected+1
		if self.selected > #self.buttons then
			self.selected = 1
		end
	elseif key == "joystickA" then
		return self:returnPressed()
	end
end

function Menu:mousemoved(x, y, dx, dy, istouch)
	--
end