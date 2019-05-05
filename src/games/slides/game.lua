local game = {}

-- Render constants
local GAME_WIDTH = 192
local GAME_HEIGHT = 125
local RENDER_SCALE = 4

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

function game.load(args)
  currSlideIndex = 1
  slides = args.slides
end

function game.draw()
  -- Scale and crop the screen
  love.graphics.setScissor(0, 0, RENDER_SCALE * GAME_WIDTH, RENDER_SCALE * GAME_HEIGHT)
  love.graphics.scale(RENDER_SCALE, RENDER_SCALE)
  love.graphics.clear(1, 1, 1)
  love.graphics.setColor(1, 1, 1)

  -- Draw current slide
  local slide = slides[currSlideIndex]
  drawSprite(spriteSheet, 1 + 195 * (slide % 5), 1 + 128 * math.floor(slide / 5), 192, 125, 0, 0)
end

function game.keypressed(key)
  if key == 'left' then
    currSlideIndex = math.max(1, currSlideIndex - 1)
  elseif key == 'right' then
    currSlideIndex = math.min(currSlideIndex + 1, #slides)
  end
end

return game
