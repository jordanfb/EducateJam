



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
	self.gateScale = .75
	self.inputScale = .5*2
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
		local inputs = gateSetup.inputs
		self.circuitDisplays[#self.circuitDisplays+1] = {display = gatesDisplayTable, levels = gatesDisplayLevel, inputs = inputs, output = key}
	end
	self:setCoordinatesForDisplay()
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

function NewTerminal:setCoordinatesForDisplay()
	-- note that I really need to re-do the y coordinates for displaying gates
	print("MAKING COORDINATES")
	for k, page in pairs(self.circuitDisplays) do
		local numCollumns = self:tablelength(page.display)
		print("NIM COOLLLUMS "..numCollumns)
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
			print("ADDED X COORDS FOR GATE")
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
end

function NewTerminal:leave()
	-- run when the level no longer has control
end

function NewTerminal:drawInputs()
	local numInputs = #(self.circuitDisplays[self.currentPage]).inputs
	local step = (self.backgroundH-2*self.magicEdgeOffset)/(numInputs+1)
	local x = self.terminalX + self.magicEdgeOffset
	local y = self.terminalY + self.magicEdgeOffset+step
	for i = 1, numInputs do
		local inputRune = string.upper(self.circuitDisplays[self.currentPage].inputs[i])
		local image = self.level.blueRunes[inputRune]
		love.graphics.draw(image, x, y, 0, self.inputScale, self.inputScale, image:getWidth()/2, image:getHeight()/2)
		y = y + step
	end
end

function NewTerminal:drawOutput()
	-- currrently only draws the single output, but you can pretty much just copy the drawInputs to make it work
	local x = self.terminalX+self.backgroundW-self.magicEdgeOffset
	local y = self.terminalY + self.backgroundH/2
	local outputRune = self.circuitDisplays[self.currentPage].output
	local image = self.level.blueRunes[outputRune]
	love.graphics.draw(image, x, y, 0, self.outputScale, self.outputScale, image:getWidth()/2, image:getHeight()/2)
end

function NewTerminal:drawGates()
	local page = self.circuitDisplays[self.currentPage]
	for k, collumn in pairs(page.display) do
		-- print(collumn)
		for j, gate in pairs(collumn) do
			love.graphics.setColor(200, 200, 200)
			local image = self.level.inventoryImages.tileBackground
			love.graphics.draw(image, gate.x, gate.y, 0, self.gateScale, self.gateScale, image:getWidth()/2, image:getHeight()/2)
		end
	end
end

function NewTerminal:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.level.insideTerminalImages.background, self.terminalX, self.terminalY)
	love.graphics.draw(self.level.insideTerminalImages.background, self.terminalX+self.backgroundW/2, self.terminalY)
	-- if #self.circuitDisplays > 0 then
	-- 	local x = self.terminalX + self.backgroundW -- subtract a certain amount though.
	-- 	for k, line in pairs(self.circuitDisplays[self.currentPage]) do
	-- 		-- display each layer.
	-- 	end
	-- end
	self:drawInputs()
	self:drawOutput()
	self:drawGates()
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