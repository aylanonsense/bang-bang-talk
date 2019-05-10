local juiceGame = require 'src/games/juice/game'

local controllerToKeys = {
  dpup = 'up',
  dpdown = 'down',
  dpleft = 'left',
  dpright = 'right',
  start = 'm',
  back = 'm',
  a = 'space',
  b = 'm',
  x = 'space',
  y = 'm',
  leftshoulder = '',
  rightshoulder = ''
}

function love.load()
  juiceGame.preload()
  juiceGame.load({ enableJuice = true })
end

function love.update(...)
  juiceGame.update(...)
end

function love.draw(...)
  love.graphics.translate(10, 10)
  love.graphics.scale(2, 2)
  juiceGame.draw(...)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle('fill', -4000, -4000, 4000, 8000)
  love.graphics.rectangle('fill', -4000, -4000, 8000, 4000)
  love.graphics.rectangle('fill', 192, -4000, 8000, 8000)
  love.graphics.rectangle('fill', -4000, 125, 8000, 8000)
end

function love.keypressed(...)
  juiceGame.keypressed(...)
end

function love.gamepadpressed(joystick, button)
  juiceGame.keypressed(controllerToKeys[button])
end
