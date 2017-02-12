io.stdout:setvbuf("no") -- this is so that sublime will print things when they come (rather than buffering).


require "game"
require "class"


local game = Game()

function love.load(args)
	local name = "Boolean Sunset"
	love.window.setTitle(name)
	love.filesystem.setIdentity(name)
	game:load(args)
	--local width, height = 512, 256
	love.window.setMode(1920/2, 1080/2)
	love.window.setFullscreen(false)
	-- not much here
	game:resize(width, height)
	love.mouse.setVisible(true)
end

function love.resize(w, h)
	game:resize(w, h)
end

function love.draw()
	game:draw()
end

function love.update(dt)
	--print(1/dt) -- the framerate, I think.
	game:update(dt)
end

function love.keypressed(key, unicode)
	if key == "escape" then
		if #game.screenStack == 1 then
			love.event.quit()
		-- else
		-- 	game:popScreenStack() -- this is temporary, in reality it should bring up a pause menu if you're in level.
		end
	end
	game:keypressed(key, unicode)
end

function love.keyreleased(key, unicode)
	game:keyreleased(key, unicode)
end

function love.mousepressed(x, y, button)
	game:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	game:mousereleased(x, y, button)
end

function love.joystickadded(joystick)
	game:joystickadded(joystick)
end

function love.joystickremoved(joystick)
	game:joystickremoved(joystick)
end

function love.quit()
	game:quit()
end

function love.mousemoved( x, y, dx, dy, istouch )
	game:mousemoved(x, y, dx, dy, istouch)
end

function love.gamepadpressed(gamepad, button)
	game:gamepadpressed(gamepad, button)
end

function love.gamepadaxis( joystick, axis, value )
	game:gamepadaxis(joystick, axis, value)
end