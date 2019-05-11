local inputLatencyGame = require 'src/games/input-latency/game'

local controllerToKeys = {
  dpup = '',
  dpdown = '',
  dpleft = 'left',
  dpright = 'right',
  start = 'r',
  back = 'r',
  a = 'space',
  b = 'space',
  x = 'space',
  y = 'space',
  leftshoulder = 'down',
  rightshoulder = 'up'
}

function love.load()
  inputLatencyGame.preload()
  inputLatencyGame.load()
end

function love.update(...)
  inputLatencyGame.update(...)
end

function love.draw(...)
  love.graphics.translate(10, 10)
  love.graphics.scale(2, 2)
  inputLatencyGame.draw(...)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle('fill', -4000, -4000, 4000, 8000)
  love.graphics.rectangle('fill', -4000, -4000, 8000, 4000)
  love.graphics.rectangle('fill', 192, -4000, 8000, 8000)
  love.graphics.rectangle('fill', -4000, 125, 8000, 8000)
end

function love.keypressed(...)
  inputLatencyGame.keypressed(...)
end

function love.keyreleased(...)
  inputLatencyGame.keyreleased(...)
end

function love.gamepadpressed(joystick, button)
  inputLatencyGame.keypressed(controllerToKeys[button])
end

function love.gamepadreleased(joystick, button)
  if controllerToKeys[button] == 'r' then
    inputLatencyGame.load()
  else
    inputLatencyGame.keyreleased(controllerToKeys[button])
  end
end
