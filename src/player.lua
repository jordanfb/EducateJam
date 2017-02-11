require "class"

Player = class()


function Player:_init(game)
	self.game = game

	self.x = 300		--Players X and Y location
	self.y = 300

	self.dx = 0		--Players X and Y velocity
	self.dy = 0
	self.speed = 160*2	--Players X acceleration

	self.onGround = false		--Tracks if the player is on the ground
	self.onLadder = false		--Tracks if the player is on a ladder
	
	self.w = 160
	self.h = 2*160

	self.gravity = 16			--Attributes about they players movement
	self.jumpStrength = 160*4		--and world
	self.ladderSpeed = 5 		--Rate at which a player climbs ladders
	self.maxSpeed = 70
	self.friction = 2
end

--Returns the sign of the number passed in
function sign(v)
	if v==0 then
		return 0
	elseif v > 0 then
		return 1
	end
	return -1
end

--Resets the player to the sepcified location
function Player:reset(levelXStart, levelYStart)
	self.x = levelXStart
	self.y = levelYStart
	self.dx = 0
	self.dy = 0
end

--Lets the player jump
function Player:jump()
	if self.onGround then
		self.dy = -self.jumpStrength
		self.y = self.y - 100
		error("OKAY")
	end
end

--Draws the rectangle
function Player:draw()
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)		--Placeholder
end

function Player:keypressed(key)

end

--Runs collision checking
function Player:collisions(dt, level)
	--level has level.walls, which holds (x, y, w)
	for i, wall in pairs(level.walls) do
		if self.x + self.w > wall.x and self.x < wall.x + wall.w then
			if self.y + self.h <= wall.y + 1 and self.y + self.h + self.dy*dt > wall.y then
				self.dy = 0
				self.y = wall.y - self.h
				self.onGround = true
			end
		end
		if self.y + self.h > wall.y and self.y < wall.y + wall.w then
			--if self.x + self.w <= wall.x + 1 and self.x + self.w + self.dx*dt > wall.x then
			--	self.dx = 0
			--	self.x = wall.x - self.w
			if self.x >= wall.x + wall.w and self.x + self.dx*dt < wall.x + wall.w then
				self.dx = 0
				self.x = wall.x + wall.w
			end
		end
	end
end

function Player:getInput()
	if love.keyboard.isDown("a") then		--accelerates the player left
		self.dx =  -self.speed
	end
	if love.keyboard.isDown("d") then	--accelerates the player right
		self.dx = self.speed
	end
	if love.keyboard.isDown("w") and self.onLadder then
		self.y = self.ladderSpeed
	end
	if love.keyboard.isDown("d") and self.onLadder then
		self.y = -1 * self.ladderSpeed
	end
	if love.keyboard.isDown("space") and self.onGround then
		self.dy = -self.jumpStrength
	end
end

--Moves the player
function Player:update(dt, level)
	
	self.dx = 0
	self.onGround = false
	
	self:collisions(dt, level)
	self:getInput()

	if not self.onLadder then
		self.dy = self.dy + self.gravity
		self.y = self.y + self.dy * dt
	end
	
	self.x = self.x + self.dx * dt	--moves the player
	
end

