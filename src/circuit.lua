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
	for line in io.lines(file) do
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
	for k, line in pairs(lines) do
		print(#line)
		if #line > 1 and string.sub(line, 1, 1) == "*" then
			self.inputs[string.sub(line, 2, 2)] = false
		elseif #line > 1 and string.sub(line, 1,1) == "%" then
			self.outputs[string.sub(line, 2, 2)] = false
		elseif #line > 1 and string.sub(line, 1, 1) == "#" then
			-- do nothing!
		elseif #line > 0 then
			-- print("ADDED A GATE")
			local letters = {}
			print(#line)
			for i = 1, #line do
				if string.sub(line, i, i) ~= " " then
					letters[#letters+1] = string.sub(line, i, i)
				end
			end
			self.gates[letters[2]] = Gate(letters[1], letters[2], letters[3], letters[4])
			-- print("HAHA I LIED aCtUAlly")
			-- then it's a gate
		end
	end
	print("MADE IT THROUGH LOAD CIRCUIT")
end

function Circuit:evaluate()
	for k, v in pairs(self.inputs) do
		print("INPUTL "..k)
	end
	for k, v in pairs(self.outputs) do
		print(k.." trying to do stuff")
		-- k = the name of the output, and the first gate to check.
		print("inputs len"..self:tablelength(self.inputs))
		self.outputs[k] = self.gates[k]:evaluate(self.gates, self.inputs)
	end
end


