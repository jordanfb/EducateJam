require "class"

Player = class()


function Player:_init(game)
	self.game = game

	self.x = 0		--Players X and Y location
	self.y = 0

	self.dx = 0		--Players X and Y velocity
	self.dy = 0
	self.ddx = 5	--Players X acceleration

	self.onGround = false		--Tracks if the player is on the ground
	self.onLadder = false		--Tracks if the player is on a ladder

	self.gravity = -30			--Attributes about they players movement
	self.jumpStrength = 30		--and world
	self.ladderSpeed = 5 		--Rate at which a player climbs ladders
	self.maxSpeed = 7
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
		self.dy = self.jumpStrength
	end
end

--Draws the rectangle
function Player:draw()
	love.graphics.rectangle(self.x, self.y, 50, 50)		--Placeholder
end

function Player:keypressed(key)
	if key == "space" then
		self:jump()
	end
end

--Runs collision checking
function Player:collisions(level)
	--level has level.walls, which holds (x, y, w)
	for i, wall in level.walls do
		if self.dx < 0 and self.x < wall.x then
			self.dx = 0
			self.x = wall.x
		end
	end
end


--Moves the player
function Player:update(dt)

	if love.keyboard.isDown("a") then		--accelerates the player left
		self.dx = self.dx - self.ddx
	elseif love.keyboard.isDown("d") then	--accelerates the player right
		self.dx = self.dx + self.ddx
	elseif love.keyboard.isDown("w") and self.onLadder then
		self.y = self.ladderSpeed
	elseif love.keyboard.isDown("d") and self.onLadder then
		self.y = -1 * self.ladderSpeed
	--else
	--	if math.abs(self.dx) > 0.1 and self.onGround then		--Slows the player down based on the friction coefficient.  THIS MIGHT HAVE A BUG WITH LADDERS!!!
		--	self.dx = self.dx - sign(self.dx) * self.friction
	--	end
	end

	if not self.onLadder then
		self.dy = self.dy + self.gravity * dt
		self.y = self.y + self.dy * dt
	end
	
	if math.abs(self.dx) > self.maxSpeed then	--makes sure the player isn't moving too fast
		self.dx = sign(self.dx) * self.maxSpeed
	end
	self.x = self.x + self.dx * dt	--moves the player
end

