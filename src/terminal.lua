



require "class"
require "circuit"

Terminal = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Terminal:_init(game)
	-- this is for the draw stack
	self.drawUnder = true
	self.updateUnder = false
	self.game = game
	self.circuit = Circuit("testmap1.txt")

	self.circuit.inputs["A"] = false
	self.circuit.inputs["B"] = false
	self.circuit.inputs["C"] = true

	self.circuit:evaluate()
	for k, v in pairs(self.circuit.outputs) do
		print("Output "..k.." = ")
		print(v)
	end
end

function Terminal:load()
	-- run when the level is given control
end

function Terminal:leave()
	-- run when the level no longer has control
end

function Terminal:draw()
	love.graphics.setColor(100, 200, 255)
	love.graphics.rectangle("fill", 100, 100, 1920-200, 1080-200, 10, 10)
end

function Terminal:update(dt)
	--
end

function Terminal:resize(w, h)
	--
end

function Terminal:keypressed(key, unicode)
	if key == "escape" or key == "joystickB" then
		self.game:popScreenStack()
	end
end

function Terminal:keyreleased(key, unicode)
	--
end

function Terminal:mousepressed(x, y, button)
	--
end

function Terminal:mousereleased(x, y, button)
	--
end

function Terminal:mousemoved(x, y, dx, dy, istouch)
	--
end