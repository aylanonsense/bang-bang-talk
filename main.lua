local slides = require 'src/games/slides/game'
local myGamesGame = require 'src/games/my-games/game'
local juiceGame = require 'src/games/juice/game'
local badMathGame = require 'src/games/bad-math/game'
local inputLatencyGame = require 'src/games/input-latency/game'

local SCALE = 2
local OFFSET_X = 384 + 10
local OFFSET_Y = 250 + 10

local games = {
  { game = slides, args = { slides = { 0 } } },

  -- { game = myGamesGame, hideBlinders = true },
  -- { game = slides, args = { slides = { 5 } } },
  { game = slides, args = { slides = { 14 } } },

  { game = juiceGame, args = { enableJuice = false } },
  { game = juiceGame, args = { enableJuice = true } },
  { game = slides, args = { slides = { 24 } } },
  { game = slides, args = { slides = { 1 } } },
  -- { game = slides, args = { slides = { 5, 6 } } },

  { game = badMathGame, args = { dynamicHitChance = false } },
  { game = slides, args = { slides = { 10, 11, 12 } } },
  { game = badMathGame, args = { dynamicHitChance = true } },
  { game = slides, args = { slides = { 2 } } },
  -- { game = slides, args = { slides = { 12, 23 } } },
  -- { game = slides, args = { slides = { 6, 7 } } },

  { game = inputLatencyGame },
  { game = slides, args = { slides = { 15, 16, 17, 18, 20, 21, 22, 25, 26, 27 } } },
  { game = inputLatencyGame },
  { game = slides, args = { slides = { 28, 3 } } },
  -- { game = slides, args = { slides = { 7, 8, 9 } } },

  { game = slides, args = { slides = { 19, 4 } } }
}

local currGameIndex
local game
local hideBlinders

function switchToGame(index, isGoingBack)
  -- Find the game
  currGameIndex = index
  game = games[currGameIndex].game
  hideBlinders = games[currGameIndex].hideBlinders
  local args = games[currGameIndex].args
  -- Load the game
  if game.load then
    game.load(args, isGoingBack)
  end
end

function love.load()
  -- Preload all games
  for _, game in ipairs(games) do
    if game.game.preload then
      game.game.preload()
    end
  end
  -- Switch to our first game
  switchToGame(1)
end

function love.update(...)
  -- Update the current game
  if game.update then
    game.update(...)
  end
end

function love.draw(...)
  love.graphics.translate(OFFSET_X - SCALE * 192, OFFSET_Y - SCALE * 125)
  love.graphics.scale(SCALE, SCALE)
  -- Draw the current game
  if game.draw then
    game.draw(...)
  end
  if not hideBlinders then
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', -4000, -4000, 4000, 8000)
    love.graphics.rectangle('fill', -4000, -4000, 8000, 4000)
    love.graphics.rectangle('fill', 192, -4000, 8000, 8000)
    love.graphics.rectangle('fill', -4000, 125, 8000, 8000)
  end
end

function love.keypressed(key, ...)
  if not game.keypressed or not game.keypressed(key, ...) then
    local amt = (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) and 30 or 5
    if key == 'j' and currGameIndex > 1 then
      switchToGame(currGameIndex - 1, true)
    elseif key == 'k' and currGameIndex < #games then
      switchToGame(currGameIndex + 1)
    elseif key == 'r' then
      switchToGame(currGameIndex)
    elseif key == 'w' then
      OFFSET_Y = OFFSET_Y - SCALE * amt
    elseif key == 'a' then
      OFFSET_X = OFFSET_X - SCALE * amt
    elseif key == 's' then
      OFFSET_Y = OFFSET_Y + SCALE * amt
    elseif key == 'd' then
      OFFSET_X = OFFSET_X + SCALE * amt
    elseif key == 'q' then
      SCALE = math.max(1, SCALE - 1)
    elseif key == 'e' then
      SCALE = SCALE + 1
    end
  end
end

function love.keyreleased(...)
  if game.keyreleased then
    game.keyreleased(...)
  end
end
