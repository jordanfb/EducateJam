require "class"

Player = class()


function Player:_init(game)
	self.game = game

	self.x = 300		--Players X and Y location
	self.y = 300

	self.dx = 0		--Players X and Y velocity
	self.dy = 0
	self.speed = 160*(3.2)	--Players X acceleration

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
	
	self.animation = 0
	self.animationType = "still"

	self.score = 0
	
	self.inventory = {}	
	
	self.walkImages = {}
	for i = 1, 12, 1 do
		self.walkImages[i] = love.graphics.newImage('art/playerWalk'..i..'.png')
	end 
	self.climbImages = {}
	for i = 1, 4, 1 do
		self.climbImages[i] = love.graphics.newImage('art/playerLadder'..i..'.png')
	end 
	self.idleImages = {}
	for i = 1, 5, 1 do
		self.idleImages[i] = love.graphics.newImage('art/playerIdle'..i..'.png')
	end
	self.fallingImage = love.graphics.newImage('art/playerFalling.png')

	self.scoreBackground = love.graphics.newImage('art/clickTrackerBackground.png')
	
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
	self.inventory = {}
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
function Player:draw(level, camera)
	love.graphics.setColor(1, 1, 1)

	if self:isTouchingInteractable(level)[1]~="nothing" then
		-- love.graphics.setFont(love.graphics.newFont("fonts/november.ttf", 36))
		local keybuttonthing = "E"
		if self.game.useJoystick then
			keybuttonthing = "(X)"
		end
		love.graphics.printf("PRESS "..keybuttonthing, self:isTouchingInteractable(level)[3] + camera.x, self:isTouchingInteractable(level)[4] + camera.y - 80, level.tileSize, "center")
	end

	if self.animationType == "still" then
		if self.facing==1 then
			love.graphics.draw(self.idleImages[math.floor(self.animation)+1], self.x + camera.x - self.w/2, self.y + camera.y, 0, self.facing, 1)		--Placeholder
		else
			love.graphics.draw(self.idleImages[math.floor(self.animation)+1], self.x + camera.x + 3*self.w/2, self.y + camera.y, 0, self.facing, 1)		--Placeholder
		end

	elseif self.animationType == "walk" then
		if self.facing==1 then
			love.graphics.draw(self.walkImages[math.floor(self.animation)+1], self.x + camera.x - self.w/2, self.y + camera.y, 0, self.facing, 1)		--Placeholder
		else
			love.graphics.draw(self.walkImages[math.floor(self.animation)+1], self.x + camera.x + 3*self.w/2, self.y + camera.y, 0, self.facing, 1)		--Placeholder
		end
	elseif self.animationType == "climb" then
		if self.facing==1 then
			love.graphics.draw(self.climbImages[math.floor(self.animation)+1], self.x + camera.x - self.w/2, self.y + camera.y, 0, self.facing, 1)		--Placeholder
		else
			love.graphics.draw(self.climbImages[math.floor(self.animation)+1], self.x + camera.x + 3*self.w/2, self.y + camera.y, 0, self.facing, 1)		--Placeholder
		end
	end
	--love.graphics.rectangle("line", self.x + camera.x, self.y + camera.y, self.w, self.h)		--Placeholder
	
	--if self.touchingLadder then
	--	love.graphics.printf("TOUCHING LADDER", 300, 300, 300, "right")
	--end
end

function Player:drawFlips()
	love.graphics.setFont(love.graphics.newFont("fonts/november.ttf", 36))
	love.graphics.draw(self.scoreBackground, 30, 30)
	love.graphics.setColor(7/255, 131/255, 201/255)
	love.graphics.printf("Flips: " .. self.score, 30, 90, 320, "center")
end

function Player:keypressed(key, unicode, level)
	if (key=="e"or key == "joystickx") then
		local touching = self:isTouchingInteractable(level)
		if touching[1]=="lever" then
			self.score = self.score + 1
			level.levers[touching[2]].on = not level.levers[touching[2]].on
			level.circuit.inputs[level.levers[touching[2]].key] = not level.circuit.inputs[level.levers[touching[2]].key]
			-- then evaluate the circuit and open/deal with all doors.
			self:updateAllDoors(level)
		elseif touching[1]=="terminal" then
			local id = touching[2]
			if false then
				-- draw the new terminal
				self.game:addToScreenStack(level.newTerminals[level.terminals[id].key])
			else
				-- draw the old one
				self.game:addToScreenStack(level.terminals[id])
			end
		elseif touching[1]=="treasure" then
			self.game:addToScreenStack(self.game.cutscene)
			level.currentLevel = level.currentLevel + 1 
		end
	elseif key=="space" or key == "joysticka" then
		if self.onGround and not self.onLadder then
			self.dy = -self.jumpStrength
		end
		self.onLadder = false
	end
end

function Player:updateAllDoors(level)
	for k, lever in pairs(level.levers) do
		level.circuit.inputs[lever.key] = lever.on
		-- print("BUTTON LEVER IS "..lever.key)
		-- print(lever.on)
	end
	-- level.circuit.inputs[level.levers[self:isTouchingLever(level)].key] = not level.circuit.inputs[level.levers[self:isTouchingLever(level)].key]
	level.circuit:evaluate()
	-- level.doors[1]["open"] = level.circuit.outputs["O"]
	for k, door in pairs(level.doors) do
		door.open = level.circuit.outputs[door.key]
	end
	-- print("door status")
	-- print(level.circuit.outputs["O"])
end

--Runs collision checking
function Player:gravityCollisions(dt, level)
	--level has level.walls, which holds (x, y, w)
	for i, wall in pairs(level.walls) do
		self:gravityCollision(dt, level, wall)
	end
	for i, door in pairs(level.doors) do
		if not door["open"] then
			self:gravityCollision(dt, level, door)
		end
	end
end

function Player:gravityCollision(dt, level, wall)
	if self.x + self.w > wall.x and self.x < wall.x + wall.w then
		if self.y + self.h <= wall.y + wall.h/2 and self.y + self.h + self.dy*dt > wall.y then
			self.dy = 0
			self.y = wall.y - self.h
			self.onGround = true
		elseif self.y >= wall.y + wall.h - 1 and self.y + self.dy*dt < wall.y + wall.h then
			self.dy = 0
			self.y = wall.y + wall.h
		end
	end
end

--Runs collision checking
function Player:movementCollisions(dt, level)
	--level has level.walls, which holds (x, y, w)
	for i, wall in pairs(level.walls) do
		self:movementCollision(dt, level, wall)
	end
	for i, door in pairs(level.doors) do
		if not door["open"] then
			self:movementCollision(dt, level, door)
		end
	end
end

function Player:movementCollision(dt, level, wall)
	if self.y + self.h > wall.y + 1 and self.y < wall.y + wall.h then
		if self.x < wall.x + wall.w and self.x > wall.x + 3*wall.w/4 then
			self.dx = 0
			self.x = wall.x + wall.w
		elseif self.x + self.w > wall.x and self.x < wall.x - 3*wall.w/4 then
			self.dx = 0
			self.x = wall.x - self.w
		end
	end
	if self.x + self.w > wall.x + 1 and self.x < wall.x + wall.w then
		if self.y < wall.y + wall.h and self.y > wall.y + 3*wall.h/4 then
			self.dy = 0
			self.y = wall.y + wall.h
		elseif self.y + self.h > wall.y and self.y < wall.y - 3*wall.h/4 and self.onLadder then
			if self.dy > 0 then
				self.onGround = true
				self.onLadder = false
			end
			self.dy = 0
			self.y = wall.y - self.h
		end	
	end
end

function Player:ladderCollisions(dt, level)
	self.touchingLadder = false
	for i, ladder in pairs(level.ladders) do
		if self.y +self.h > ladder.y and self.y < ladder.y + ladder.w then
			if self.x + self.w > ladder.x + (1/2)*ladder.w and self.x < ladder.x + (1/2)*ladder.w then
				self.touchingLadder = true
				return
			end
		end
	end
	self.onLadder = false
end

function Player:itemCollisions(dt, level)
	for i, gate in pairs(level.gates) do
		if not gate.taken then
			if self.y +self.h > gate.y and self.y < gate.y + gate.w then
				if self.x + self.w > gate.x + (1/2)*gate.w and self.x < gate.x + (1/2)*gate.w then
					table.insert(self.inventory, gate.gate)
					gate.taken = true
					level.gateSound:play()
				end
			end
		end
	end
end

function Player:isTouchingInteractable(level)
	for i, lever in pairs(level.levers) do
		if self:isTouching(lever, i)~=0 then
			return {"lever", self:isTouching(lever, i), level.levers[self:isTouching(lever, i)].x, level.levers[self:isTouching(lever, i)].y}
		end
	end
	for i, terminal in pairs(level.terminals) do
		if self:isTouching(terminal, i)~=0 then
			return {"terminal", self:isTouching(terminal, i), level.terminals[self:isTouching(terminal, i)].x, level.terminals[self:isTouching(terminal, i)].y}
		end
	end
	if level.treasure.x then
		if self:isTouching(level.treasure, i)~=0 then
			return {"treasure", self:isTouching(level.treasure, i), level.treasure.x, level.treasure.y}
		end
	end
	return {"nothing", 0, 0, 0}
end

function Player:isTouching(item, i)
	if self.y + self.h > item.y and self.y < item.y + item.w then
		if self.x + self.w > item.x and self.x < item.x + item.w then
			return i
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
		self.animationType = "walk"
	end
	if love.keyboard.isDown("d") then	--accelerates the player right
		self.dx = self.speed
		self.facing = 1
		if self.x > level.screen.w - level.cameraBuffer - level.camera.x then
			level.camera.dx = -self.speed
		end
		self.animationType = "walk"
	end

	if self.game.useJoystick then
		-- then move with joystick, assuming that the thing is greater than the dead value
		local c = self.game.gamepadManager.leftx
		local cR = self.game.gamepadManager.rightx
		if math.abs(cR) > math.abs(c) then
			c = cR
		end
		if math.abs(c) > .25 then
			-- use it for movement
			self.dx = c*self.speed
			if self.dx < 0 then
				self.facing = -1
				if self.x < level.cameraBuffer - level.camera.x then
					level.camera.dx = self.speed
				end
			else
				self.facing = 1
				if self.x > level.screen.w - level.cameraBuffer - level.camera.x then
					level.camera.dx = -self.speed
				end
			end
			self.animationType = "walk"
		end
		-- if math.min(self.game.gamepadManager.lefty, self.game.gamepadManager.righty) < .25 then
			
		-- end
	end

	if (love.keyboard.isDown("w") or (self.game.useJoystick and math.min(self.game.gamepadManager.lefty, self.game.gamepadManager.righty) < -.25)) and self.touchingLadder then
		self.onLadder = true
		self.dy = - self.ladderSpeed
		self.animation = (self.animation+.1)%4
	elseif (love.keyboard.isDown("s") or (self.game.useJoystick and math.max(self.game.gamepadManager.lefty, self.game.gamepadManager.righty) > .25)) and self.onLadder then
		self.dy = self.ladderSpeed
		self.animation = (self.animation+.1)%4
	end

	
end

function Player:movePlayer(dt)
	if not self.onLadder then
		self.dy = self.dy + self.gravity
	end
	
	self.y = self.y + self.dy * dt
	self.x = self.x + self.dx * dt	--moves the player

end

function Player:animate(dt)
	if self.onLadder then
		self.animationType = "climb"
	end
	if (self.animationType~="climb" and not self.onGround) then
		self.animationType = "still"
	end
	if self.animationType=="walk" then
		self.animation = (self.animation+.2)%12
	elseif self.animationType=="climb" then
		--self.animation = (self.animation+.1)%4
	elseif self.animationType=="still" then
		self.animation = (self.animation+.1)%5
	end
end

--Moves the player
function Player:update(dt, level)

	self.animationType = "still"
	
	level.camera.dx = 0
	level.camera.dy = 0
	self.dx = 0
	self.onGround = false
	
	if self.onLadder then
		self.dy = 0
	end
	
	self:ladderCollisions(dt, level)
	self:gravityCollisions(dt, level)
	self:itemCollisions(dt, level)
	self:getInput(level)
	-- if self.onGround then
	-- 	self.onLadder = false
	-- end
	self:movePlayer(dt)	
	self:movementCollisions(dt, level)
	
	
	if self.y > level.screen.h - level.cameraBuffer/2 - level.camera.y then
		level.camera.y = level.screen.h - level.cameraBuffer/2 - self.y
	end
	if self.y < level.cameraBuffer/2 - level.camera.y then
		level.camera.y = level.cameraBuffer/2 - self.y
	end
	
	if self.x + level.camera.x > level.screen.w then
		level.currentLevel = level.currentLevel + 1
		self.game:popScreenStack()
		self.game:addToScreenStack(self.game.cutscene)
		-- level:initialize()
	end
	
	self:animate(dt)
end