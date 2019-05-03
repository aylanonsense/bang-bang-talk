local badMathGame = require 'src/games/bad-math/game'
-- local inputLatencyGame = require 'src/games/input-latency/game'

local games = {
  { game = badMathGame, args = { dynamicHitChance = true } }
  -- { game = inputLatencyGame }
}

local currGameIndex
local game

function switchToGame(index)
  -- Find the game
  currGameIndex = index
  game = games[currGameIndex].game
  local args = games[currGameIndex].args
  -- Preload the game
  if not games[currGameIndex].hasBeenPreloaded then
    games[currGameIndex].hasBeenPreloaded = true
    if game.preload then
      game.preload()
    end
  end
  -- Load the game
  if game.load then
    game.load(args)
  end
end

function love.load()
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
  -- Draw the current game
  if game.draw then
    game.draw(...)
  end
end

function love.keypressed(...)
  if game.keypressed then
    game.keypressed(...)
  end
end
