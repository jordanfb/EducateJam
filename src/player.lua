require "class"

Player = class()


function Player:_init(game)
	self.game = game

	self.x = 300		--Players X and Y location
	self.y = 300

	self.dx = 0		--Players X and Y velocity
	self.dy = 0
	self.speed = 160*3	--Players X acceleration

	self.onGround = false		--Tracks if the player is on the ground
	self.onLadder = false		--Tracks if the player is on a ladder
	self.touchingLadder = false
	
	self.w = 160
	self.h = 2*160
	
	self.facing = 1

	self.gravity = 16*2			--Attributes about they players movement
	self.jumpStrength = 160*6		--and world
	self.ladderSpeed = 160*2 		--Rate at which a player climbs ladders
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
function Player:draw(camera)
	love.graphics.rectangle("fill", self.x + camera.x, self.y + camera.y, self.w, self.h)		--Placeholder
	--if self.touchingLadder then
	--	love.graphics.printf("TOUCHING LADDER", 300, 300, 300, "right")
	--end
end

function Player:keypressed(key, unicode, level)
	if key=="e" then
		if self.onGround and self:isTouchingLever(level)~=0 then
			level.levers[self:isTouchingLever(level)].on = not level.levers[self:isTouchingLever(level)].on
		end
	end
end

--Runs collision checking
function Player:gravityCollisions(dt, level)
	--level has level.walls, which holds (x, y, w)
	for i, wall in pairs(level.walls) do
		if self.x + self.w > wall.x and self.x < wall.x + wall.w then
			if self.y + self.h <= wall.y + 1 and self.y + self.h + self.dy*dt > wall.y then
				self.dy = 0
				self.y = wall.y - self.h
				self.onGround = true
			elseif self.y >= wall.y + wall.w - 1 and self.y + self.dy*dt < wall.y + wall.w then
				self.dy = 0
				self.y = wall.y + wall.w
			end
		end
	end
end
--Runs collision checking
function Player:movementCollisions(dt, level)
	--level has level.walls, which holds (x, y, w)
	for i, wall in pairs(level.walls) do
		if self.y + self.h > wall.y + 1 and self.y < wall.y + wall.w then
			if self.x < wall.x + wall.w and self.x > wall.x + 5*wall.w/6 then
				self.dx = 0
				self.x = wall.x + wall.w
			elseif self.x + self.w > wall.x and self.x < wall.x - 5*wall.w/6 then
				self.dx = 0
				self.x = wall.x - self.w
			end
		end
		if self.x + self.w > wall.x + 1 and self.x < wall.x + wall.w then
			if self.y < wall.y + wall.w and self.y > wall.y + 5*wall.w/6 then
				self.dy = 0
				self.y = wall.y + wall.w
			elseif self.y + self.h > wall.y and self.y < wall.y - 5*wall.w/6 and self.onLadder then
				self.dy = 0
				self.onGround = true
				self.y = wall.y - self.h
			end	
		end
	end
end

function Player:ladderCollisions(dt, level)
	self.touchingLadder = false
	for i, ladder in pairs(level.ladders) do
		if self.y > ladder.y and self.y < ladder.y + ladder.w then
			if self.x + self.w > ladder.x + (1/2)*ladder.w and self.x < ladder.x + (1/2)*ladder.w then
				self.touchingLadder = true
				return
			end
		end
	end
	self.onLadder = false
end

function Player:isTouchingLever(level)
	for i, lever in pairs(level.levers) do
		if self.y + self.h > lever.y and self.y < lever.y + lever.w then
			if self.x + self.w > lever.x and self.x < lever.x + lever.w then
				return i
			end
		end
	end
	return 0
end

function Player:getInput(level)
	if love.keyboard.isDown("a") then		--accelerates the player left
		self.dx =  -self.speed
		self.facing = -1
		if self.x < level.cameraBuffer - level.camera.x then
			level.camera.dx = self.speed
		end
	end
	if love.keyboard.isDown("d") then	--accelerates the player right
		self.dx = self.speed
		self.facing = 1
		if self.x > level.screen.w - level.cameraBuffer - level.camera.x then
			level.camera.dx = -self.speed
		end
	end
	if love.keyboard.isDown("w") and self.touchingLadder then
		self.onLadder = true
		self.dy = - self.ladderSpeed
	end
	if love.keyboard.isDown("s") and self.onLadder then
		self.dy = self.ladderSpeed
	end
	if love.keyboard.isDown("space") then
		self.onLadder = false
		if self.onGround then
			self.dy = -self.jumpStrength
		end
	end
end

function Player:movePlayer(dt)
	if not self.onLadder then
		self.dy = self.dy + self.gravity
	end
	
	self.y = self.y + self.dy * dt
	self.x = self.x + self.dx * dt	--moves the player

end

--Moves the player
function Player:update(dt, level)
	
	level.camera.dx = 0
	level.camera.dy = 0
	self.dx = 0
	self.onGround = false
	
	if self.onLadder then
		self.dy = 0
	end
	
	self:ladderCollisions(dt, level)
	self:gravityCollisions(dt, level)
	self:getInput(level)
	if self.onGround then
		self.onLadder = false
	end
	self:movePlayer(dt)	
	self:movementCollisions(dt, level)
	
	
	if self.y > level.screen.h - level.cameraBuffer/2 - level.camera.y then
		level.camera.y = level.screen.h - level.cameraBuffer/2 - self.y
	end
	if self.y < level.cameraBuffer/2 - level.camera.y then
		level.camera.y = level.cameraBuffer/2 - self.y
	end
	
end