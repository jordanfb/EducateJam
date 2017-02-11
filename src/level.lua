require "class"

Level = class()

-- _init, load, draw, update(dt), keypressed, keyreleased, mousepressed, mousereleased, resize, (drawUnder, updateUnder)

function Level:_init(args)

	self.walls = {}
	self.levelArray = {{'w','w','w','w','w','w','w','w','w','w','w','w','w','w','w','w'},
					   {'w',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','w'},
					   {'w',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','w'},
					   {'w',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','w'},
					   {'w',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','w'},
					   {'w','w','w','w','w','w','w','w','w','w','w','w','w','w','w','w'},

	self.tileSize = 32
					   
	for y, row in pairs(levelArray) do
		for x, tile in pairs(row) do
			if tile = 'w' then
				table.insert(walls, {x=x, y=y})
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
	for i, wall in pairs(self.walls) do
		love.graphics.rectangle(wall.x*self.tileSize, wall.y*self.tileSize, self.tileSize, self.tileSize)
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