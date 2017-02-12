



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
	self.gateImage = nil -- just cause
	self.inventorySelected = 1


	self.backgroundW = self.level.insideTerminalImages.background:getWidth()
	self.backgroundH = self.level.insideTerminalImages.background:getHeight()
	self.terminalX = 1920/2-self.backgroundW/2
	self.terminalY = 1080/2-self.backgroundH/2
	self.inventoryX = self.terminalX + self.backgroundW
	self.inventoryY = self.terminalY

	-- self.circuit:evaluate()
	-- for k, v in pairs(self.circuit.outputs) do
	-- 	print("Output "..k.." = ")
	-- 	print(v)
	-- end
end

function Terminal:nameToLogicGateNumber(name)
	if name == "buffer" then
		return 1
	elseif name == "not" then
		return 2
	elseif name == "and" then
		return 3
	elseif name == "or" then
		return 4
	elseif name == "xor" then
		return 5
	elseif name == "nand" then
		return 6
	elseif name == "nor" then
		return 7
	else
		-- not a thing!
		print("TRIED TO GET LOGIC GATE NUMBER OF NOT A GATE")
		return -1
	end
end

function Terminal:logicGateNumberToName(num)
	local convert = {"buffer", "not", "and", "or", "xor", "nand", "nor"}
	return convert[num]
end

function Terminal:setLogicGate(gate, override)
	if self.editable or override==true then
		-- then you can change it!
		self.gateType = self:nameToLogicGateNumber(gate)
		self.gateImage = self.level.inventoryImages["gateTile"..self.gateType..".png"]
		return true
	else
		-- do nothing?
		return false
	end
end

function Terminal:setTerminalData(numInputs, terminalIndex, gateType, editable, out, inA, inB)
	--2, i, t[3], t[4], t[5], t[6], t[7]
	self.numInputs = numInputs
	self.gateName = gateType
	self:setLogicGate(gateType, true)
	self.editable = editable
	self.inA = inA
	self.inB = inB
	self.out = out
	self.selected = terminalIndex
	self.resetInfo = {terminalIndex = terminalIndex, out = out, inA = inA, inB = inB, numInputs = numInputs}
	self.magicCenteringNumber = 85
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

function Terminal:setColorToNode(node, override) -- sets the color to dark
	if (self.level.circuit.drawNodes[node] and override == nil) then
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

function Terminal:setColorToGate()
	if self.level.circuit.drawNodes[self.out] then
		-- make it bright, since it's on
		-- print("ongate")
		love.graphics.setColor(7, 131, 201)
	else
		-- print("off gate")
		love.graphics.setColor(104, 104, 104)
	end
end

function Terminal:setColorForTile(override) -- use override for the inventory
	if self.editable == "edit" or override then
		-- make it tan, since it's editable?
		-- print("editable")
		love.graphics.setColor(190, 164, 136)
	else
		love.graphics.setColor(70, 70, 70)
	end
end

function Terminal:drawLogicGate()
	-- print("test")
	if self.gateName ~= "nil" or true then
		self:setColorForTile()
		love.graphics.draw(self.level.inventoryImages.tileBackground, 300+self.terminalX, 300+self.terminalY)
		self:setColorToGate()
		if self.gateImage ~= nil then
			love.graphics.draw(self.gateImage, 300+self.terminalX, 300+self.terminalY)
		end
	else
		-- dont' draw anything?
	end
end

function Terminal:drawInventory()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.level.inventoryImages.background, self.inventoryX, self.inventoryY)
	local x = self.inventoryX + 40
	local y = self.inventoryY + 40

	for k, v in pairs(self.level.player.inventory) do
		self:setColorForTile(true)
		-- draw the tile
		love.graphics.draw(self.level.inventoryImages.tileBackground, x, y+(k-1)*100)
		self:setColorToNode("nothing", true)
		-- draw the gate
		love.graphics.draw(self.level.inventoryImages["gateTile"..v..".png"], x, y)
		y = y + 40 + 100 -- the height of the gate and 40 for spacing
	end
	love.graphics.setColor(255, 255, 255)
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
		love.graphics.draw(self:getRuneForDisplay(self.inA), 120-self.magicCenteringNumber+self.terminalX, 150-self.magicCenteringNumber+self.terminalY)
		-- love.graphics.draw(self.level.greyRunes)
		self:setColorToNode(self.inB)
		love.graphics.draw(self.level.insideTerminalImages.twoInputImages.inB, self.terminalX, self.terminalY)
		-- this is where I draw the inB rune in the bottom left
		love.graphics.draw(self:getRuneForDisplay(self.inB), 100-self.magicCenteringNumber+self.terminalX, 650-self.magicCenteringNumber+self.terminalY)
		self:setColorToNode(self.out)
		love.graphics.draw(self.level.insideTerminalImages.twoInputImages.out, self.terminalX, self.terminalY)
		-- this is where I draw the out rune in the right
		love.graphics.draw(self:getRuneForDisplay(self.out), 640-self.magicCenteringNumber+self.terminalX, 660-self.magicCenteringNumber+self.terminalY)
	elseif self.numInputs == 1 then -- draw one node stuff
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.level.insideTerminalImages.oneInputImages.background, self.terminalX, self.terminalY)
		self:setColorToNode(self.inA)
		love.graphics.draw(self.level.insideTerminalImages.oneInputImages.inA, self.terminalX, self.terminalY)
		-- this is where I draw the inA rune in the top left
		love.graphics.draw(self:getRuneForDisplay(self.inA), 90-self.magicCenteringNumber+self.terminalX, 580-self.magicCenteringNumber+self.terminalY)
		self:setColorToNode(self.out)
		love.graphics.draw(self.level.insideTerminalImages.oneInputImages.out, self.terminalX, self.terminalY)
		-- this is where I draw the out rune in the right
		love.graphics.draw(self:getRuneForDisplay(self.out), 700-self.magicCenteringNumber+self.terminalX, 210-self.magicCenteringNumber+self.terminalY)
	else
		-- it probably isn't initialized yet, so hopefully it will be fixed...
		print("ERROR! TERMINAL DOESN'T HAVE CORRECT NUMBER OF INPUTS")
	end
	self:drawLogicGate()
	self:drawInventory()
end

function Terminal:update(dt)
	--
end

function Terminal:resize(w, h)
	--
end

function Terminal:keypressed(key, unicode)
	-- print(key)
	if key == "escape" or key == "joystickb" or key == "e" then
		self.game:popScreenStack()
	end
	if key == "right" or key == "joystickrightshoulder" or key == "d" then
		-- swap to a right-er page
		self.selected = self.selected - 1
		if self.selected <= 0 then
			self.selected = #self.level.terminals
		end
	elseif key == "left" or key == "joystickleftshoulder" or key == "a" then
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