require class

Gate = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Gate:setOutput(self.type, self.inA, self.inB)
	if self.type == "not" then
		return not self.inA
	elseif self.type == "and" then
		return self.inA and self.inB
	elseif self.type == "or" then
		return self.inA or self.inB
	elseif self.type == "xor" then
		if self.inA and self.inB  then
			return false
		return self.inA or self.inB
	elseif self.type == "nand" then
		return not self.inA and self.inB
	elseif self.type == "nor" then
		return not self.inA or self.inB
	elseif self.type == "on" then
		return true	
	elseif self.type == "off" then
		return false
	else
		print("ERROR: INVALID GATE TYPE:" .. type)
		love.event.quit()
		return nil
	end
end

function Gate:_init(type, inA, inB)
	self.type = type
	self.inA = inA
	self.inB = inB
	self.out = self.setOutput()
end

--Change the gate type, for toggling inputs
function Gate:setType(type)
	self.type = type
end

--Changes the input, passing a 0 adjusts inA, 1 adjusts inB
function Gate:changeInput(input, value)
	if input == 0 then
		inA = value
	else
		inB = value
end

function Gate:getOutput()
	self.out = self.setOutput()
	return self.out
end