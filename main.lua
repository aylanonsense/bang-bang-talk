local slides = require 'src/games/slides/game'
local juiceGame = require 'src/games/juice/game'
local badMathGame = require 'src/games/bad-math/game'
local inputLatencyGame = require 'src/games/input-latency/game'

local games = {
  { game = slides, args = { slides = { 0 } } },

  { game = slides, args = { slides = { 1 } } },
  { game = juiceGame, args = { enableJuice = false } },
  { game = juiceGame, args = { enableJuice = true } },
  { game = slides, args = { slides = { 5, 6 } } },

  { game = slides, args = { slides = { 2 } } },
  { game = badMathGame, args = { dynamicHitChance = false } },
  { game = slides, args = { slides = { 10, 11, 12 } } },
  { game = badMathGame, args = { dynamicHitChance = true } },
  { game = slides, args = { slides = { 6, 7 } } },

  { game = slides, args = { slides = { 3 } } },
  { game = inputLatencyGame },
  { game = slides, args = { slides = { 15, 16, 17, 18, 20, 21, 22, 25, 26, 27 } } },
  { game = inputLatencyGame },
  { game = slides, args = { slides = { 7, 8, 9 } } },

  { game = slides, args = { slides = { 4 } } }
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
  if not game.keypressed or not game.keypressed(key, ...) then
    if key == 'j' then
      switchToGame(math.max(1, currGameIndex - 1))
    elseif key == 'k' then
      switchToGame(math.min(currGameIndex + 1, #games))
    elseif key == 'r' then
      switchToGame(currGameIndex)
    end
  end
end
