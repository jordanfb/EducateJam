



require "class"

NewTerminal = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function NewTerminal:_init(game, currentLevel, level, circuit, terminalName, keys)
	-- this is for the draw stack
	self.currentLevel = currentLevel
	self.drawUnder = true
	self.updateUnder = false

	-- now the actual variables
	self.magicEdgeOffset = 40 -- the distance from the nodes and such to the edge of the terminal background
	-- self.gateScale = .5
	-- self.inputScale = .5*2
	self.outputScale = .5*2
	self.game = game
	self.level = level
	self.circuit = circuit
	self.keys = keys -- a table of door circuits to display
	self.terminalName = terminalName
	-- what the letter is that is used to represent it, (also the key for the level.newTerminals table)
	self.circuitDisplays = {}
	self.currentPage = 1
	-- self.gatesToDisplay = {}
	
	self.x = 0 -- these get replaced when self:addCoordinates() is called by the level loader
	self.y = 0
	self.w = 0
	self.h = 0

	self.backgroundW = self.level.insideTerminalImages.background:getWidth()*2
	self.backgroundH = self.level.insideTerminalImages.background:getHeight()
	self.terminalX = 1920/2-self.backgroundW/2
	self.terminalY = 1080/2-self.backgroundH/2
	self.inventoryX = self.terminalX + self.backgroundW
	self.inventoryY = self.terminalY

	self:prepareCircuitForDisplay()
end

function NewTerminal:prepareCircuitForDisplay()
	-- print("TERMINAL KEY "..tostring(self.key))
	for k, key in pairs(self.keys) do
		local gateSetup = self.circuit:getGatesForDoor(key)
		local gatesDisplayTable = gateSetup.displayTable
		local gatesDisplayLevel = gateSetup.levelTable
		local inputs = {}
		for i, j in pairs(gateSetup.inputs) do -- just copy the table over and make it into a table with stuff.
			inputs[i] = {rune = j, x = 0, y = 0}
		end
		local gateScale = 1
		if #gatesDisplayTable > 3 then
			gateScale = .5
		end
		local inputScale = 1
		if #inputs > 3 then
			inputScale = .5
		end
		self.circuitDisplays[#self.circuitDisplays+1] = {gateScale = gateScale, inputScale = inputScale, display = gatesDisplayTable, levels = gatesDisplayLevel, inputs = inputs, output = key}
	end
	self:setCoordinatesForDisplay()
	self:setInputCoordinatesForDisplay()
	-- self.gatesToDisplay then contains all the gates for that terminal/door.
	-- self.outputRune = ""
	-- self.inputRunes = {}
	-- self.displayTable = {} -- a table of x, y, powerSourceThingToCheck, powerStatus, and picture? (and image scale)
	-- what's the key of that? the output? that would probs make sense, but we already have the gates for that I think.
	-- as a note, the Y probably gets set after the whole thing is made, as does the x value, otherwise pain.

	-- splits it up into layers of things that should be drawn, so that they can be organized correctly.
	-- output is on the farthest right, and says what it has on the next left thing as an input. you then put that in the next
	-- layer. That gate may or may not be pushed back yet more if it's a prerequisite for some other gate, but that shouldn't
	-- happen for the first stage, because otherwise it's recursive/unstable/dependant on itself.
	-- self.onWhatLayer = {} -- this is key to layer# for each gate/input/output
	-- self.onWhatLayer[self.key] = 1
	-- local tempTable = {x = 0, y = 0, key = self.key, on = false, picture = nil}
	-- self.displayTable[1] = {self.key = tempTable}
	-- probably has to recursively add everything to this table using recursion. Recursively.
end

function NewTerminal:tablelength(t)
	if t == nil then
		return 0
	end
	local i = 0
	for k, v in pairs(t) do
		i = i + 1
	end
	return i
end

function NewTerminal:setInputCoordinatesForDisplay()
	for k, page in pairs(self.circuitDisplays) do
		local numInputs = #page.inputs
		local step = (self.backgroundH-2*self.magicEdgeOffset)/(numInputs+1)
		local x = self.terminalX + self.magicEdgeOffset
		local y = self.terminalY + self.magicEdgeOffset+step
		for i = 1, numInputs do
			-- local inputRune = string.upper(self.circuitDisplays[self.currentPage].inputs[i])
			-- local image = self.level.blueRunes[inputRune]

			-- local runeTable = self.circuitDisplays[self.currentPage].inputs[i]
			page.inputs[i].x = x
			page.inputs[i].y = y
			-- love.graphics.draw(image, x, y, 0, self.inputScale, self.inputScale, image:getWidth()/2, image:getHeight()/2)
			y = y + step
		end
	end
end

function NewTerminal:setCoordinatesForDisplay()
	-- note that I really need to re-do the y coordinates for displaying gates
	-- print("MAKING COORDINATES")
	for k, page in pairs(self.circuitDisplays) do
		local numCollumns = self:tablelength(page.display)
		-- print("NIM COOLLLUMS "..numCollumns)
		local step = (self.backgroundW-2*self.magicEdgeOffset) / (numCollumns+1)
		local x = self.terminalX + self.backgroundW - self.magicEdgeOffset-- subtract some amount though,
		-- for i = 1, #page.display do
			-- each collumn
		for k, collumn in pairs(page.display) do
			x = x - step -- this is done first, because you also display the output symbol on the right.
			local ystep = (self.backgroundH-2*self.magicEdgeOffset)/(self:tablelength(collumn)+1)
			local y = self.terminalY + self.magicEdgeOffset + ystep
			for j, gateTable in pairs(collumn) do
				gateTable.x = x
				gateTable.y = y
				y = y + ystep
			end
			-- print("ADDED X COORDS FOR GATE")
		end
		-- end
	end
end

function NewTerminal:addCoordinates(x, y, width, height)
	self.x = x
	self.y = y
	self.w = width
	self.h = height
end

function NewTerminal:nameToLogicGateNumber(name)
	local conversionTable = {}
	conversionTable["buffer"] = 1
	conversionTable["not"] = 2
	conversionTable["and"] = 3
	conversionTable["or"] = 4
	conversionTable["xor"] = 5
	conversionTable["nand"] = 6
	conversionTable["nor"] = 7
	conversionTable["nil"] = 8
	if conversionTable[name] == nil then
		error("TRIED TO GET LOGIC GATE NUMBER OF NOT A GATE, NEW TERMINAL")
	else
		return conversionTable[name]
	end
end

function NewTerminal:logicGateNumberToName(num)
	local convert = {"buffer", "not", "and", "or", "xor", "nand", "nor", "nil"}
	if tonumber(num) > #convert then
		error("TRIED TO CONVERT NUMBER TO GATE THAT WAS TOO LARGE NEW TERMINAL")
	end
	return convert[tonumber(num)]
end

function NewTerminal:reset()
	--
end

function NewTerminal:load()
	-- run when the level is given control
	-- love.mouse.setVisible(true)
	love.graphics.setLineWidth(2)
end

function NewTerminal:leave()
	-- run when the level no longer has control
end

function NewTerminal:drawInputs()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", self.terminalX, self.terminalY, 100, self.backgroundH)
	for i = 1, #self.circuitDisplays[self.currentPage].inputs do
		local inputRune = self.circuitDisplays[self.currentPage].inputs[i]
		local image = 0
		if self.level.circuit.drawNodes[inputRune.rune] then
			image = self.level.blueRunes[string.upper(inputRune.rune)]
		else
			image = self.level.greyRunes[string.upper(inputRune.rune)]
		end
		love.graphics.draw(image, inputRune.x, inputRune.y, 0, self.circuitDisplays[self.currentPage].inputScale, self.circuitDisplays[self.currentPage].inputScale, image:getWidth()/2, image:getHeight()/2)
	end
end

function NewTerminal:drawOutput()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", self.terminalX+self.backgroundW, self.terminalY, -100, self.backgroundH)
	-- currrently only draws the single output, but you can pretty much just copy the drawInputs to make it work
	local x = self.terminalX+self.backgroundW-self.magicEdgeOffset
	local y = self.terminalY + self.backgroundH/2
	local outputRune = self.circuitDisplays[self.currentPage].output
	local image = 0
	if self.level.circuit.drawNodes[outputRune] then
		image = self.level.blueRunes[outputRune]
	else
		image = self.level.greyRunes[outputRune]
	end
	love.graphics.draw(image, x, y, 0, self.circuitDisplays[self.currentPage].inputScale, self.circuitDisplays[self.currentPage].inputScale, image:getWidth()/2, image:getHeight()/2)
end

function NewTerminal:setPowerColor(rune)
	if self.level.circuit.drawNodes[rune] then
		-- make it bright, since it's on
		-- print("ongate")
		love.graphics.setColor(7, 131, 201)
	else
		-- print("off gate")
		love.graphics.setColor(104, 104, 104)
	end
end

function NewTerminal:drawGates()
	local page = self.circuitDisplays[self.currentPage]
	for k, collumn in pairs(page.display) do
		-- print(collumn)
		for j, gate in pairs(collumn) do
			love.graphics.setColor(200, 200, 200)
			local bgimage = self.level.inventoryImages.tileBackground
			love.graphics.draw(bgimage, gate.x, gate.y, 0, self.circuitDisplays[self.currentPage].gateScale, self.circuitDisplays[self.currentPage].gateScale, bgimage:getWidth()/2, bgimage:getHeight()/2)
			if gate.gate.gateType ~= "nil" then
				self:setPowerColor(gate.gate.output)
				-- love.graphics.setColor(100, 100, 255)
				local image = self.level.inventoryImages["gateTile"..self:nameToLogicGateNumber(gate.gate.gateType)..".png"]
				love.graphics.draw(image, gate.x, gate.y, 0, self.circuitDisplays[self.currentPage].gateScale, self.circuitDisplays[self.currentPage].gateScale, image:getWidth()/2, image:getHeight()/2)
			end
		end
	end
end

function NewTerminal:findInputIndex(rune)
	for k, v in pairs(self.circuitDisplays[self.currentPage].inputs) do
		if v.rune == rune then
			return k
		end
	end
	return -1
end

function NewTerminal:drawLines()
	love.graphics.setColor(255, 255, 255)
	local page = self.circuitDisplays[self.currentPage]

	local outputx = self.terminalX+self.backgroundW-self.magicEdgeOffset
	local outputy = self.terminalY + self.backgroundH/2
	self:setPowerColor(self.circuitDisplays[self.currentPage].output)
	love.graphics.line(outputx, outputy, page.display[1][page.output].x, page.display[1][page.output].y)

	for k, collumn in pairs(page.display) do
		for j, gate in pairs(collumn) do
			-- love.graphics.setColor(math.random()*255, math.random()*255, math.random()*255)
			local startGate = gate.gate
			if startGate.inAname ~= nil then
				self:setPowerColor(startGate.inAname)
				local endGateLevel = page.levels[startGate.inAname]
				if endGateLevel ~= nil and page.display[endGateLevel] ~= nil then
					local endGate = page.display[endGateLevel][startGate.inAname]
					love.graphics.line(gate.x, gate.y, endGate.x, endGate.y)
				elseif page.inputs[self:findInputIndex(startGate.inAname)] ~= nil then
					-- then it's an input, so check the input table. (except when it's the output, but sshhhh)
					local inputTable = page.inputs[self:findInputIndex(startGate.inAname)]
					love.graphics.line(gate.x, gate.y, inputTable.x, inputTable.y)
				end
			end
			-- love.graphics.setColor(math.random()*255, math.random()*255, math.random()*255)
			if startGate.inBname ~= nil then
				self:setPowerColor(startGate.inBname)
				local endGateLevel = page.levels[startGate.inBname]
				if endGateLevel ~= nil and page.display[endGateLevel] ~= nil then
					local endGate = page.display[endGateLevel][startGate.inBname]
					love.graphics.line(gate.x, gate.y, endGate.x, endGate.y)
				elseif page.inputs[self:findInputIndex(startGate.inBname)] ~= nil then
					-- then it's an input, so check the input table. (except when it's the output, but sshhhh)
					local inputTable = page.inputs[self:findInputIndex(startGate.inBname)]
					love.graphics.line(gate.x, gate.y, inputTable.x, inputTable.y)
				end
			end
		end
	end
end

function NewTerminal:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.level.insideTerminalImages.background, self.terminalX, self.terminalY)
	love.graphics.draw(self.level.insideTerminalImages.background, self.terminalX+self.backgroundW/2, self.terminalY)

	self:drawInputs()
	self:drawOutput()
	self:drawGates()
	self:drawLines()
end

function NewTerminal:update(dt)
	--
end

function NewTerminal:resize(w, h)
	--
end

function NewTerminal:moveLeftPage()
	-- swap to a left-er page
	self.currentPage = self.currentPage + 1
	if self.currentPage > #self.circuitDisplays then
		self.currentPage = 1
	end
	-- if self.viewablePages[self.circuitDisplays[self.currentPage].key] == nil then
	-- 	self:moveLeftPage()
	-- end
end

function NewTerminal:moveRightPage()
	-- swap to a right-er page
	self.currentPage = self.currentPage - 1
	if self.currentPage <= 0 then
		self.currentPage = #self.circuitDisplays
	end
	-- if self.viewablePages[self.circuitDisplays[self.currentPage].key] == nil then
	-- 	self:moveRightPage()
	-- end
end

function NewTerminal:keypressed(key, unicode)
	if key == "e" or key == "joystickb" or key == "escape" then
		self.game:popScreenStack()
	elseif key == "right" or key == "joystickrightshoulder" or key == "d" then
		self:moveRightPage()
	elseif key == "left" or key == "joystickleftshoulder" or key == "a" then
		self:moveLeftPage()
	end
end

function NewTerminal:keyreleased(key, unicode)
	--
end

function NewTerminal:mousepressed(x, y, button)
	-- 
end

function NewTerminal:mousereleased(x, y, button)
	--
end

function NewTerminal:mousemoved(x, y, dx, dy, istouch)
	--
end