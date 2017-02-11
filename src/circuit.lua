require "class"

Circuit = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Circuit:loadCircuit(file)
	-- lines = {}						--Reads in the file to a table
	-- for line in io.lines(file) do 
	-- 	lines[#lines + 1] = line
	-- end

	-- inputs = {}
	-- nodes = {}

	-- for i, element in pairs(lines)
	-- 	for token in string.gmatch(line, "[^%s]+") do
	-- 		if token[1] == "*"
	-- 	end
	-- end

	for 
end


function Circuit:_init(file)
	self.circuit = self.loadCircuit(file)
end