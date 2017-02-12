



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
	self.joystickSelected = 1-- goes from 1 to 2 to three to four to five, only those things
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
	elseif name == "nil" then
		return 8
	else
		-- not a thing!
		print("TRIED TO GET LOGIC GATE NUMBER OF NOT A GATE")
		return -1
	end
end

function Terminal:logicGateNumberToName(num)
	local convert = {"buffer", "not", "and", "or", "xor", "nand", "nor", "nil"}
	return convert[tonumber(num)]
end

function Terminal:setLogicGate(gate, override)
	if self.editable == "edit" or override==true then
		-- then you can change it!
		self.gateName = gate
		self.gateType = self:nameToLogicGateNumber(gate)
		if self.gateType ~= 8 then
			self.gateImage = self.level.inventoryImages["gateTile"..self.gateType..".png"]
		else
			self.gateImage = nil
		end
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
	if self.gateName ~= "nil" then
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

function Terminal:addSelectedGateToGate(index)
	if index > #self.level.player.inventory then
		return false
	end
	local gate = self.level.player.inventory[index]
	-- print("INVENTORY VALUE"..self.level.player.inventory[index])
	local gt = self:logicGateNumberToName(gate)
	-- print("GT "..gt)
	local oldGate = self.level.terminals[self.selected].gateType
	if self.level.terminals[self.selected]:setLogicGate(gt) then
		table.remove(self.level.player.inventory, index)
		if oldGate > 0 and oldGate ~= 8 and oldGate ~= "nil" and oldGate ~= nil then
			-- print("ADDING OLDGATE TO INVENTORY "..oldGate)
			table.insert(self.level.player.inventory, oldGate)
		end
		-- print("ADDED CIRCUIT")
		for k, v in pairs(self.level.circuit.gates) do
			if v.output == self.level.terminals[self.selected].out then --and v.inA == self.level.terminals[self.selected].inA and v.inB == self.level.terminals[self.selected].inB then
				-- delete it or whatever
				v.gateType = gt
				-- print("Found it to add it to the thing")
				break
			end
		end
	end
	self.level.circuit:evaluate()
	self.level.player:updateAllDoors(self.level)
end

function Terminal:returnSelectedGateToInventory()
	-- print("RETURNING GATE")
	local oldGate = self.level.terminals[self.selected].gateType
	if oldGate == "nil" or oldGate == -1 or oldGate == nil or oldGate == 8 then
		return false
	end
	if oldGate ~= "nil" then
		if self.level.terminals[self.selected]:setLogicGate("nil") then
			table.insert(self.level.player.inventory, oldGate)
			for k, v in pairs(self.level.circuit.gates) do
				-- print(tostring(v.output).."sdfkj"..tostring(self.level.terminals[self.selected].out))
				if v.output == self.level.terminals[self.selected].out then --and v.inA == self.level.terminals[self.selected].inA and v.inB == self.level.terminals[self.selected].inB then
					-- delete it or whatever
					v.gateType = "nil"
					break
				end
			end
		end
	end
	self.level.circuit:evaluate()
	self.level.player:updateAllDoors(self.level)
end

function Terminal:drawInventory()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.level.inventoryImages.background, self.inventoryX, self.inventoryY)
	local x = self.inventoryX + 40
	local y = self.inventoryY + 40

	for k, v in pairs(self.level.player.inventory) do
		if k > 4 then
			break
		end
		self:setColorForTile(true)
		-- draw the tile
		love.graphics.draw(self.level.inventoryImages.tileBackground, x, y+(k-1)*185)
		self:setColorToNode("nothing", true)
		-- draw the gate
		-- print("GATE VALUE THAT'S CAUSING CRASH "..v)
		love.graphics.draw(self.level.inventoryImages["gateTile"..v..".png"], x, y+(k-1)*185)
		-- y = y + 10 -- the height of the gate and 40 for spacing -- but not, since it does it above
	end
	if self.game.useJoystick then
		local hx = 0
		local hy = 0
		if self.joystickSelected > 1 then
			hx = x
			hy = y+(self.joystickSelected-2)*185
		else
			hx = 300+self.terminalX
			hy = 300+self.terminalY
		end
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.level.inventoryImages.highlight, hx, hy)
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
	love.graphics.draw(self.level.inventoryImages.leftArrow, self.terminalX+20, self.terminalY + self.backgroundH-10)
	love.graphics.draw(self.level.inventoryImages.rightArrow, self.terminalX+self.backgroundW-20-160, self.terminalY + self.backgroundH-10)
end

function Terminal:update(dt)
	--
end

function Terminal:resize(w, h)
	--
end

function Terminal:keypressed(key, unicode)
	-- print(key)
	if key == "joysticka" then
		if self.game.level.terminals[self.selected].joystickSelected == 1 then
			self.game.level.terminals[self.selected]:returnSelectedGateToInventory()
		else
			self.game.level.terminals[self.selected]:addSelectedGateToGate(self.joystickSelected-1)
		end
	elseif key == "escape" or key == "joystickb" or key == "e" then
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
	if key == "menuUp" then
		self.game.level.terminals[self.selected].joystickSelected = self.game.level.terminals[self.selected].joystickSelected-1
	elseif key == "menuDown" then
		self.game.level.terminals[self.selected].joystickSelected = self.game.level.terminals[self.selected].joystickSelected+1
	elseif key == "menuLeft" then
		if self.game.level.terminals[self.selected].joystickSelected == 1 then
			self.game.level.terminals[self.selected].joystickSelected = 2
		else
			self.game.level.terminals[self.selected].joystickSelected = 1
		end
	elseif key == "menuRight" then
		if self.game.level.terminals[self.selected].joystickSelected == 1 then
			self.game.level.terminals[self.selected].joystickSelected = 2
		else
			self.game.level.terminals[self.selected].joystickSelected = 1
		end
	end
	if self.game.level.terminals[self.selected].joystickSelected <= 0 then
		self.game.level.terminals[self.selected].joystickSelected = 1+#self.level.player.inventory
	elseif self.game.level.terminals[self.selected].joystickSelected > 1+#self.level.player.inventory then
		self.game.level.terminals[self.selected].joystickSelected = 1
	end
end

function Terminal:keyreleased(key, unicode)
	--
end

function Terminal:dealWithMouseClick(a, b, button)
	local m = self.game:realToFakeMouse(a, b, button)
	local x = m.x
	local y = m.y
	-- this just pretty much just clicks the things, I also have to do selection for joystick controlls
	if x > self.inventoryX+40 and x < self.inventoryX + 40+240 then
		if y > self.inventoryY+40 and y < self.inventoryY+800 then
			local modY = (y-self.inventoryY-40) %(185)
			-- print("could be cool")
			if modY < 160 then
				-- on a button
				local inventorySlot = math.floor((y-self.inventoryY-40)/(185))+1
				if inventorySlot <= #self.level.player.inventory then
					self:addSelectedGateToGate(inventorySlot)
				end
			end
		end
	end
	if math.abs(1920/2-x) < 240/2 then
		if math.abs(1080/2-y) < 160/2 then
			-- remove the thing in teh middle
			self:returnSelectedGateToInventory()
		end
	end
	if y > self.terminalY + self.backgroundH-10 and y < self.terminalY + self.backgroundH-10 + 120 then
		if x > self.terminalX+20 and x < self.terminalX+20+160 then
			self.selected = self.selected - 1
			if self.selected <= 0 then
				self.selected = #self.level.terminals
			end
		elseif x > self.terminalX+self.backgroundW-20-160 and x < self.terminalX+self.backgroundW-20 then
			self.selected = self.selected + 1
			if self.selected > #self.level.terminals then
				self.selected = 1
			end
		end
	end
	-- if y > self.inventoryY + self.backgroundY
end

function Terminal:mousepressed(x, y, button)
	-- print(self.level.terminals[self.selected].gateName)
	self:dealWithMouseClick(x, y, button)
	-- if self.level.terminals[self.selected].gateName == "nil" then
	-- 	-- add the gate
	-- 	self:addSelectedGateToGate(1)
	-- else
	-- 	-- remove the gate
	-- 	self:returnSelectedGateToInventory()
	-- end
end

function Terminal:mousereleased(x, y, button)
	--
end

function Terminal:mousemoved(x, y, dx, dy, istouch)
	love.mouse.setVisible(true)
	-- local m = self.game:realToFakeMouse(x, y, button)
	-- if m.x > self.inventoryX+40 and m.x < self.inventoryX + 40+240 then
	-- 	if m.y > self.inventoryY+40 and m.y < self.inventoryY+800 then
	-- 		print("is inside")
	-- 	else
	-- 		print("is not")
	-- 	end
	-- else
	-- 	print("xwrong")
	-- end
end