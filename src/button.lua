

require "class"

Button = class()

function Button:_init(text, x, y, width, height, fontHeight, game)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.text = text
	self.selected = false
	self.normalColor = {200, 200, 200}
	self.selectedColor = {100, 100, 100}
	self.fontHeight = fontHeight
	self.game = game
end

function Button:draw()
	if self.selected then
		love.graphics.setColor(self.selectedColor[1], self.selectedColor[2], self.selectedColor[3])
	else
		love.graphics.setColor(self.normalColor[1], self.normalColor[2], self.normalColor[3])
	end
	love.graphics.rectangle("fill", self.x-self.width/2, self.y-self.height/2, self.width, self.height, 10, 10)
	love.graphics.setColor(0, 0, 0)
	love.graphics.setLineWidth(3)
	love.graphics.rectangle("line", self.x-self.width/2, self.y-self.height/2, self.width, self.height, 10, 10)
	love.graphics.printf(self.text, self.x-self.width/2, self.y-self.fontHeight/2, self.width, "center")
end

function Button:updateMouse(mX, mY)
	local t = self.game:realToFakeMouse(mX, mY)
	mX = t.x
	mY = t.y
	if (mX > self.x-self.width/2 and mX < self.x+self.width/2) then
		if (mY > self.y-self.height/2 and mY < self.y + self.height/2) then
			self.selected = true
			return true
		end
	end
	self.selected = false
	return false
end

function Button:getSelected()
	return self.selected
end

function Button:setSelected(select)
	self.selected = select
end

function Button:select()
	self.selected = true
end

function Button:deselect()
	self.selected = false
end

function Button:mousemoved(x, y, dx, dy, istouch)
	--
end