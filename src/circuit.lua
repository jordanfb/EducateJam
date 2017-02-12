require "class"
require "gate"

Circuit = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Circuit:_init(file)
	-- self.filename = file
	self.inputs = {}
	self.outputs = {}
	table.insert(self.inputs, "d")
	print("leng of inpust"..#self.inputs)
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
	print("read file")

	-- inputs = {}
	-- nodes = {}1

	-- for i, element in pairs(lines)
	-- 	for token in string.gmatch(line, "[^%s]+") do
	-- 		if token[1] == "*"
	-- 	end
	-- end

	-- jordan's guess
	self.inputs = {}
	self.outputs = {}
	self.gates = {}
	for k, lineOfText in pairs(lines) do
		local line = {}
		for word in lineOfText:gmatch("%w+") do table.insert(line, word) end
		print("number of splits in line "..#line)
		if #line > 1 and line[1] == "input" then
			self.inputs[line[2]] = false
		elseif #line > 1 and line[1] == "output" then
			self.outputs[line[2]] = false
		elseif #line > 1 and line[1] == "node" then
			-- do nothing!
		elseif #line > 0 then
			-- print("ADDED A GATE")
			self.gates[line[2]] = Gate(line[1], line[2], line[3], line[4])
			print("line contents:")
			for k, v in pairs(line) do
				print(v)
			end
			print("line ended")
			-- print("HAHA I LIED aCtUAlly")
			-- then it's a gate
		end
	end
	print("Made all gates")
end

function Circuit:evaluate()
	-- for k, v in pairs(self.inputs) do
	-- 	print("INPUTL "..k)
	-- end
	for k, v in pairs(self.outputs) do
		-- print(k.." trying to do stuff")
		-- k = the name of the output, and the first gate to check.
		-- print("inputs len"..self:tablelength(self.inputs))
		local g = self.gates[k]
		-- print("type of possible gate "..type(g))
		self.outputs[k] = g:evaluate(self.gates, self.inputs)
	end
end


