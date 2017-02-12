


require "class"
require "button"

Menu = class()


function Menu:_init(game, buttons, xShift, yShift) -- buttons is a list of names in order of the buttons to press.
	self.selected = 1
	self.buttonNames = buttons
	self.font = love.graphics.newFont(32)
	self.fontHeight = self.font:getHeight()
	if not xShift then
		self.xShift = 0
		self.yShift = 0
	else
		self.xShift = xShift
		self.yShift = yShift
	end
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
		self.buttons[k] = Button(v, x + self.xShift, y+i*(buttonHeight+spacing) + self.yShift, buttonWidth, buttonHeight, self.fontHeight, self.game)
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
	if not self.useJoystick then
		for k, v in pairs(self.buttons) do
			if v:updateMouse(mx, my) then
				self.selected = i
				self.useJoystick = false
			-- elseif not self.useJoystick then
			-- 	v:setSelected(false)
			end
			i = i + 1
		end
	else
		i = 1
		for k, v in pairs(self.buttons) do
			v:setSelected(i == self.selected)
			i = i + 1
		end
	end
end

function Menu:mousepressed(x, y, button)
	self.useJoystick = false
	self:update(0) -- because mouse was pressed, assume that we need to use mouse
	return self:returnPressed()
end

function Menu:returnPressed()
	local i = 1
	for k, v in pairs(self.buttons) do
		if i == self.selected and v:getSelected() then
			return v.text
		end
		i = i + 1
	end
	return "ERROR"
end

function Menu:keypressed(key, unicode)
	if key == "menuUp" then
		self.useJoystick = true
		self.selected = self.selected - 1
		if self.selected <= 0 then
			self.selected = #self.buttons
		end
	elseif key == "menuDown" then
		self.useJoystick = true
		self.selected = self.selected+1
		if self.selected > #self.buttons then
			self.selected = 1
		end
	elseif key == "joysticka" then
		self.useJoystick = true
		return self:returnPressed()
	elseif key == "joystickb" then
		--
	end
end

function Menu:mousemoved(x, y, dx, dy, istouch)
	self.useJoystick = false
	self:update(0)
	love.mouse.setVisible(true)
end