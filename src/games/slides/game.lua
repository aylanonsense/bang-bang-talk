local game = {}

-- Render constants
local GAME_WIDTH = 192
local GAME_HEIGHT = 125
local RENDER_SCALE = 2

local spriteSheet
local currSlideIndex
local slides

local drawSprite = function(spriteSheetImage, sx, sy, sw, sh, x, y, flipHorizontal, flipVertical, rotation)
  local width, height = spriteSheetImage:getDimensions()
  love.graphics.draw(spriteSheetImage,
    love.graphics.newQuad(sx, sy, sw, sh, width, height),
    x + sw / 2, y + sh / 2,
    rotation or 0,
    flipHorizontal and -1 or 1, flipVertical and -1 or 1,
    sw / 2, sh / 2)
end

function game.preload()
  -- Load assets
  spriteSheet = love.graphics.newImage('src/games/slides/img/sprite-sheet.png')
  spriteSheet:setFilter('nearest', 'nearest')
end

function game.load(args, isGoingBack)
  slides = args.slides
  currSlideIndex = isGoingBack and #slides or 1
end

function game.draw()
  -- Scale and crop the screen
  love.graphics.scale(RENDER_SCALE, RENDER_SCALE)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle('fill', 0, 0, GAME_WIDTH, GAME_HEIGHT)
  love.graphics.setColor(1, 1, 1)

  -- Draw current slide
  local slide = slides[currSlideIndex]
  drawSprite(spriteSheet, 1 + 195 * (slide % 5), 1 + 128 * math.floor(slide / 5), 192, 125, 0, 0)
end

function game.keypressed(key)
  if key == 'j' and currSlideIndex > 1 then
    currSlideIndex = currSlideIndex - 1
    return true
  elseif key == 'k' and currSlideIndex < #slides then
    currSlideIndex = currSlideIndex + 1
    return true
  end
end

return game
