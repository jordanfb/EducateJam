require "class"

Gate = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Gate:setOutput(gates, nodes, inputs)
	if gates[self.inAname] ~= nil then
		self.inA = gates[self.inAname]:evaluate(gates, nodes, inputs)
	else
		self.inA = inputs[self.inAname]
	end
	if gates[self.inBname] ~= nil then
		self.inB = gates[self.inBname]:evaluate(gates, nodes, inputs)
	else
		self.inB = inputs[self.inBname]
	end
	if self.gateType == nil then
		-- self.gateType = "nil"
		error("ERROR GATE NAME WAS SET TO nil BUT NOT IN QUOTES ERROR ERROR JORDAN FIX PLS")
		-- love.event.quit(1)
	end

	if self.gateType == "buffer" then
		return self.inA
	elseif self.gateType == "not" then
		return not self.inA
	elseif self.gateType == "and" then
		return self.inA and self.inB
	elseif self.gateType == "or" then
		return self.inA or self.inB
	elseif self.gateType == "xor" then
		if self.inA and self.inB  then
			return false
		end
		return self.inA or self.inB
	elseif self.gateType == "nand" then
		return not (self.inA and self.inB)
	elseif self.gateType == "nor" then
		return not (self.inA or self.inB)
	elseif self.gateType == "on" then
		return true
	elseif self.gateType == "off" then
		return falsed
	elseif self.gateType == "nil" then
		return false
	else
		error("ERROR: INVALID GATE gateTYPE:" .. self.gateType)
		-- love.event.quit(1)
		-- return nil
	end
end

function Gate:_init(gateType, output, ia, ib)
	self.gateType = gateType
	self.inAname = ia
	self.inBname = ib
	self.output = output
end

--Change the gate gateType, for toggling inputs
function Gate:setgateType(gateType)
	self.gateType = gateType
end

--Changes the input, passing a 0 adjusts inA, 1 adjusts inB
function Gate:changeInput(input, value)
	if input == 0 then
		inA = value
	else
		inB = value
	end
end

function Gate:getGatesForDoor(gates, displayTable, levelTable, minDepth)
	-- levelTable is a table with each string key as a key and the level of the table it's on, in case it has to be adjusted
	-- add yourself and recursively all the other gates above into the tables

	-- if you're already in the table at a lower depth than minDepth, then it needs to be pushed back and recursively continue
	-- otherwise, if you're in it at at least minDepth, then you're fine, if you're not in it you have to add yourself at
	-- minDepth I think, or perhaps higher.
	if displayTable[minDepth] == nil then
		displayTable[minDepth] = {}
	end
	if levelTable[self.output] ~= nil then
		if levelTable[self.output] < minDepth then -- push self back
			displayTable[levelTable[self.output]] = nil
			displayTable[minDepth][self.output] = self
			levelTable[self.output] = minDepth
			-- now you're pushed back, so call the later things to push themselves back as well.
		elseif levelTable[self.output] >= minDepth then -- return cause you're fine
			return
		end
	else
		levelTable[self.output] = minDepth
		displayTable[minDepth][self.output] = self
	end
	-- otherwise add yourself to the thing and continue as normal.
	if gates[self.inAname] ~= nil then
		gates[self.inAname]:getGatesForDoor(gates, displayTable, levelTable, minDepth+1)
	end -- otherwise it's an input
	if gates[self.inBname] ~= nil then
		gates[self.inBname]:getGatesForDoor(gates, displayTable, levelTable, minDepth+1)
	end -- otherwise it's an input

	-- local maxDepth = -1
	-- if levelTable[self.inAname] ~= nil then
	-- 	-- it has to be smaller than that level
	-- 	maxDepth = levelTable[self.inAname]
	-- end
	-- if levelTable[self.inBname] ~= nil then
	-- 	maxDepth = math.max(maxDepth, levelTable[self.inBname])
	-- end
	-- if maxDepth <= minDepth then it has to push that thing back
	-- t[self.output] = self
end

function Gate:evaluate(gates, nodes, inputs)
	self.out = self:setOutput(gates, nodes, inputs)
	-- print("gate evaluate: inA "..self.inAname.." inB "..self.inBname.. " node name/output "..self.output .. " output value ")
	-- print(self.out)
	-- then set the node version of it if it exists, so that you can then display correctly
	if nodes[self.output] ~= nil then
		nodes[self.output] = self.out
	end
	return self.out
end