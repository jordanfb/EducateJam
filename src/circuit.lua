require "class"
require "gate"

Circuit = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Circuit:_init(file)
	-- self.filename = file
	self.inputs = {}
	self.outputs = {}
	table.insert(self.inputs, "d")
	-- print("leng of inpust"..#self.inputs)
	-- self.outputs = {}
	self:loadCircuit(file)
	self:evaluate()
end

function Circuit:tablelength(t)
	local count = 0
	for k, v in pairs(t) do
		count = count + 1
	end
	return count
end

function Circuit:loadCircuit(file)
	-- print("loading circuit"..file)
	local lines = {}						--Reads in the file to a table
	-- openfile = io.open(file)
	for line in love.filesystem.lines(file) do
		-- print("trying to read")
		lines[#lines + 1] = line
	end

	-- jordan's guess
	self.inputs = {}
	self.outputs = {}
	self.drawNodes = {}
	self.gates = {}
	for k, lineOfText in pairs(lines) do
		local line = {}
		for word in lineOfText:gmatch("%w+") do table.insert(line, word) end
		-- print("number of splits in line "..#line)
		if #line > 1 and line[1] == "input" then
			self.inputs[line[2]] = false
			self.drawNodes[line[2]] = false
		elseif #line > 1 and line[1] == "output" then
			self.outputs[line[2]] = false
		elseif #line > 1 and line[1] == "node" then
			self.drawNodes[line[2]] = false
		elseif #line > 0 then
			-- print("ADDED A GATE")
			self.gates[line[2]] = Gate(line[1], line[2], line[3], line[4])
		end
	end
	-- print("Made all gates")
end

function Circuit:getGatesForDoor(output)
	-- print("CIRCUIT GATES FOR DOOR OUTPUT "..tostring(output))
	local g = self.gates[output]
	local levelTable = {}
	local displayTable = {}
	local minDepth = 1
	g:getGatesForDoor(self.gates, displayTable, levelTable, minDepth)
	print("Depth of circuit is "..#displayTable.. " number of circuits is "..self:tablelength(levelTable))
	return {displayTable = displayTable, levelTable = levelTable}
end

function Circuit:evaluate()
	for k, v in pairs(self.inputs) do
		-- set the node equivalent to the same so that it will display correctly
		self.drawNodes[k] = v
	end
	for k, v in pairs(self.outputs) do
		-- print(k.." trying to do stuff")
		-- k = the name of the output, and the first gate to check.
		-- print("inputs len"..self:tablelength(self.inputs))
		local g = self.gates[k]
		-- print("type of possible gate "..type(g))
		self.outputs[k] = g:evaluate(self.gates, self.drawNodes, self.inputs)
	end
	for k, v in pairs(self.outputs) do
		self.drawNodes[k] = v
	end
end


