require "class"

Gate = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Gate:setOutput(gates, inputs)
	if gates[self.inAname] ~= nil then
		self.inA = gates[self.inAname]:evaluate(gates, inputs)
	else
		self.inA = inputs[self.inAname]
	end
	if gates[self.inBname] ~= nil then
		self.inB = gates[self.inBname]:evaluate(gates, inputs)
	else
		self.inB = inputs[self.inBname]
	end

	if self.gateType == "not" then
		return not self.inA
	elseif self.gateType == "and" then
		return self.inA and self.inB
	elseif self.gateType == "or" then
		return self.inA or self.inB
	-- elseif self.gateType == "xor" then
	-- 	if self.inA and self.inB  then
	-- 		return false
	-- 	return self.inA or self.inB
	-- elseif self.gateType == "nand" then
	-- 	return not self.inA and self.inB
	-- elseif self.gateType == "nor" then
	-- 	return not self.inA or self.inB
	elseif self.gateType == "on" then
		return true
	elseif self.gateType == "off" then
		return false
	else
		print("ERROR: INVALID GATE gateTYPE:" .. self.gateType)
		love.event.quit()
		return nil
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

function Gate:evaluate(gates, inputs)
	self.out = self:setOutput(gates, inputs)
	print("gate evaluate: inA "..self.inAname.." inB "..self.inBname.. " node name/output "..self.output .. " output value ")
	print(self.out)
	return self.out
end