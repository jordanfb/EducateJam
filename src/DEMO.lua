



require "class"

Game = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Game:_init(args)
	-- this is for the draw stack
	self.drawUnder = false
	self.updateUnder = false
end

function Game:load()
	-- run when the level is given control
end

function Game:leave()
	-- run when the level no longer has control
end

function Game:draw()
	--
end

function Game:update(dt)
	--
end

function Game:resize(w, h)
	--
end

function Game:keypressed(key, unicode)
	--
end

function Game:keyreleased(key, unicode)
	--
end

function Game:mousepressed(x, y, button)
	--
end

function Game:mousereleased(x, y, button)
	--
end