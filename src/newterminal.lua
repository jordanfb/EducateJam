



require "class"

NewTerminal = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function NewTerminal:_init(game, currentLevel, level, circuit, terminalName, keys)
	-- this is for the draw stack
	self.currentLevel = currentLevel
	self.drawUnder = true
	self.updateUnder = false

	-- now the actual variables
	self.game = game
	self.level = level
	self.circuit = circuit
	self.keys = keys -- a table of door circuits to display
	self.terminalName = terminalName
	-- what the letter is that is used to represent it, (also the key for the level.newTerminals table)
	self.circuitDisplays = {}
	self:setUpCircuitForDisplay()
	-- self.gatesToDisplay = {}
	
	self.x = 0 -- these get replaced when self:addCoordinates() is called by the level loader
	self.y = 0
	self.w = 0
	self.h = 0

	self.backgroundW = self.level.insideTerminalImages.background:getWidth()
	self.backgroundH = self.level.insideTerminalImages.background:getHeight()
	self.terminalX = 1920/2-self.backgroundW/2
	self.terminalY = 1080/2-self.backgroundH/2
	self.inventoryX = self.terminalX + self.backgroundW
	self.inventoryY = self.terminalY
end

function NewTerminal:setUpCircuitForDisplay()
	-- print("TERMINAL KEY "..tostring(self.key))
	for k, key in pairs(self.keys) do
		local gateSetup = self.circuit:getGatesForDoor(key)
		local gatesDisplayTable = gateSetup.displayTable
		local gatesDisplayLevel = gateSetup.levelTable
		self.circuitDisplays[key] = {display = gatesDisplayTable, levels = gatesDisplayLevel}
	end
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

function NewTerminal:addGateToDisplayTable(gate)
	--
end

function NewTerminal:testDraw1()
	--
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
end

function NewTerminal:leave()
	-- run when the level no longer has control
end

function NewTerminal:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.level.insideTerminalImages.background, self.terminalX, self.terminalY)
end

function NewTerminal:update(dt)
	--
end

function NewTerminal:resize(w, h)
	--
end

function NewTerminal:keypressed(key, unicode)
	if key == "e" or key == "joystickb" or key == "escape" then
		self.game:popScreenStack()
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