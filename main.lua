local badMathGame = require 'src/games/bad-math/game'
local inputLatencyGame = require 'src/games/input-latency/game'

local games = {
  { game = badMathGame, args = { dynamicHitChance = true } },
  { game = inputLatencyGame }
}

local currGameIndex
local game

function switchToGame(index)
  -- Find the game
  currGameIndex = index
  game = games[currGameIndex].game
  local args = games[currGameIndex].args
  -- Load the game
  if game.load then
    game.load(args)
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
  -- Draw the current game
  if game.draw then
    game.draw(...)
  end
end

function love.keypressed(key, ...)
  if key == 'j' then
    switchToGame(math.max(1, currGameIndex - 1))
  elseif key == 'k' then
    switchToGame(math.min(currGameIndex + 1, #games))
  elseif key == 'r' then
    switchToGame(currGameIndex)
  elseif game.keypressed then
    game.keypressed(key, ...)
  end
end
