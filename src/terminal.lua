



require "class"
require "circuit"

Terminal = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Terminal:_init(x, y, w, h, game, currentLevel, level, key)
	-- this is for the draw stack
	self.currentLevel = currentLevel
	self.drawUnder = true
	self.updateUnder = false
	self.game = game
	self.level = level
	self.x = x
	self.y = y
	self.w = w
	self.h = h

	self.key = key -- what images we use for this terminal
	self.numInputs = 0
	self.inA = 0
	self.inB = 0
	self.out = 0
	self.selected = 1 -- this will be set to what index this terminal is, so it opens to a cool thing!

	self.backgroundW = self.level.insideTerminalImages.background:getWidth()
	self.backgroundH = self.level.insideTerminalImages.background:getHeight()
	self.terminalX = 1920/2-self.backgroundW/2
	self.terminalY = 1080/2-self.backgroundH/2

	-- self.circuit:evaluate()
	-- for k, v in pairs(self.circuit.outputs) do
	-- 	print("Output "..k.." = ")
	-- 	print(v)
	-- end
end

function Terminal:setTerminalData(numInputs, terminalIndex, gateType, editable, out, inA, inB)
	--2, i, t[3], t[4], t[5], t[6], t[7]
	self.numInputs = numInputs
	self.gateType = gametype
	self.editable = editable
	self.inA = inA
	self.inB = inB
	self.out = out
	self.selected = terminalIndex
	self.resetInfo = {terminalIndex = terminalIndex, out = out, inA = inA, inB = inB, numInputs = numInputs}
end

function Terminal:reset()
	self.selected = self.resetInfo.terminalIndex
	self.numInputs = self.resetInfo.numInputs
	self.inA = self.resetInfo.inA
	self.inB = self.resetInfo.inB
	self.out = self.resetInfo.out
end

function Terminal:load()
	-- run when the level is given control
end

function Terminal:leave()
	-- run when the level no longer has control
end

function Terminal:setColorToNode(node)
	if self.level.circuit.drawNodes[node] then
		love.graphics.setColor(7, 131, 201)
	else
		love.graphics.setColor(104, 104, 104)
	end
end

function Terminal:getRuneForDisplay(rune)
	local r = string.upper(rune)
	if self.level.circuit.drawNodes[rune] then
		return self.level.blueRunes[r]
	else
		return self.level.greyRunes[r]
	end
end

function Terminal:draw()
	local t = self.level.terminals[self.selected]
	t:drawThisOne()
end

function Terminal:drawThisOne()
	-- love.graphics.setColor(100, 200, 255)
	-- love.graphics.rectangle("fill", 100, 100, 1920-200, 1080-200, 10, 10)
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.level.insideTerminalImages.background, self.terminalX, self.terminalY)

	if self.numInputs == 2 then -- draw two node stuff! Duh!
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.level.insideTerminalImages.twoInputImages.background, self.terminalX, self.terminalY)
		self:setColorToNode(self.inA)
		love.graphics.draw(self.level.insideTerminalImages.twoInputImages.inA, self.terminalX, self.terminalY)
		-- this is where I draw the inA rune in the top left
		love.graphics.draw(self:getRuneForDisplay(self.inA), 120-80+self.terminalX, 150-80+self.terminalY)
		-- love.graphics.draw(self.level.greyRunes)
		self:setColorToNode(self.inB)
		love.graphics.draw(self.level.insideTerminalImages.twoInputImages.inB, self.terminalX, self.terminalY)
		-- this is where I draw the inB rune in the bottom left
		love.graphics.draw(self:getRuneForDisplay(self.inB), 100-80+self.terminalX, 650-80+self.terminalY)
		self:setColorToNode(self.out)
		love.graphics.draw(self.level.insideTerminalImages.twoInputImages.out, self.terminalX, self.terminalY)
		-- this is where I draw the out rune in the right
		love.graphics.draw(self:getRuneForDisplay(self.out), 640-80+self.terminalX, 660-80+self.terminalY)
	elseif self.numInputs == 1 then -- draw one node stuff
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.level.insideTerminalImages.oneInputImages.background, self.terminalX, self.terminalY)
		self:setColorToNode(self.inA)
		love.graphics.draw(self.level.insideTerminalImages.oneInputImages.inA, self.terminalX, self.terminalY)
		-- this is where I draw the inA rune in the top left
		love.graphics.draw(self:getRuneForDisplay(self.inA), 90-80+self.terminalX, 580-80+self.terminalY)
		self:setColorToNode(self.out)
		love.graphics.draw(self.level.insideTerminalImages.oneInputImages.out, self.terminalX, self.terminalY)
		-- this is where I draw the out rune in the right
		love.graphics.draw(self:getRuneForDisplay(self.out), 700-80+self.terminalX, 210-80+self.terminalY)
	else
		-- it probably isn't initialized yet, so hopefully it will be fixed...
		print("ERROR! TERMINAL DOESN'T HAVE CORRECT NUMBER OF INPUTS")
	end
end

function Terminal:update(dt)
	--
end

function Terminal:resize(w, h)
	--
end

function Terminal:keypressed(key, unicode)
	if key == "escape" or key == "joystickb" or key == "e" then
		self.game:popScreenStack()
	end
	if key == "right" or key == "joystickrightbumper" then
		-- swap to a right-er page
		self.selected = self.selected - 1
		if self.selected <= 0 then
			self.selected = #self.level.terminals
		end
	elseif key == "left" or key == "joystickleftbumper" then
		self.selected = self.selected + 1
		if self.selected > #self.level.terminals then
			self.selected = 1
		end
	end
end

function Terminal:keyreleased(key, unicode)
	--
end

function Terminal:mousepressed(x, y, button)
	--
end

function Terminal:mousereleased(x, y, button)
	--
end

function Terminal:mousemoved(x, y, dx, dy, istouch)
	love.mouse.setVisible(true)
end