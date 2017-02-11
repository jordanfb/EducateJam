require "class"

Level = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Level:_init(game)
	self.game = game
	self.walls = {}
	self.levelArray = {{'w','w','w','w','w','w','w','w','w','w','w','w','w','w','w','w'},
					   {'w',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','w'},
					   {'w',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','w'},
					   {'w',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','w'},
					   {'w',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','w'},
					   {'w',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','w'},
					   {'w','w','w','w','w','w','w','w','w','w','w','w','w','w','w','w'},}

	self.tileSize = 160

	for y, row in pairs(self.levelArray) do
		for x, tile in pairs(row) do
			if tile == 'w' then
				table.insert(self.walls, {x=(x-1)*self.tileSize, y=(y-1)*self.tileSize, w=self.tileSize})
			end
		end
	end
end

function Level:load()
	-- run when the level is given control
end

function Level:leave()
	-- run when the level no longer has control
end

function Level:draw()
	love.graphics.setBackgroundColor(100, 100, 100)
	love.graphics.setColor(255, 255, 255)
	
	for i, wall in pairs(self.walls) do
		love.graphics.rectangle("fill", wall.x, wall.y, wall.w, wall.w)
	end
end

function Level:update(dt)
	--
end

function Level:resize(w, h)
	--
end

function Level:keypressed(key, unicode)
	--
end

function Level:keyreleased(key, unicode)
	--
end

function Level:mousepressed(x, y, button)
	--
end

function Level:mousereleased(x, y, button)
	--
end