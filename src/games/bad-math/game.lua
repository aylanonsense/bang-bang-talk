local game = {}

local spriteSheet

-- Render constants
local GAME_WIDTH = 192
local GAME_HEIGHT = 125
local RENDER_SCALE = 3

local pointerCol
local pointerRow
local dialogIndex

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
  spriteSheet = love.graphics.newImage('src/games/bad-math/img/sprite-sheet.png')
  spriteSheet:setFilter('nearest', 'nearest')
end

function game.load()
  pointerCol = 0
  pointerRow = 0
  dialogIndex = 0
end

function game.update(dt)
end

function game.draw()
  -- Scale and crop the screen
  love.graphics.setScissor(0, 0, RENDER_SCALE * GAME_WIDTH, RENDER_SCALE * GAME_HEIGHT)
  love.graphics.scale(RENDER_SCALE, RENDER_SCALE)
  love.graphics.clear(0, 1, 0)
  love.graphics.setColor(1, 1, 1)

  -- Draw the background
  drawSprite(spriteSheet, 0, 0, 192, 125, 0, 0)

  -- Draw the dialog box + pointer
  drawSprite(spriteSheet, 194, 29 * dialogIndex, 88, 29, 51, 95)
  if dialogIndex ~= 2 then
    drawSprite(spriteSheet, 330, 1, 4, 7, 62 + 35 * pointerCol, 100 + 10 * pointerRow)
  end

  -- Draw the mailperson
  drawSprite(spriteSheet, 1, 127, 49, 40, 41, 51)

  -- Draw the mailbox
  drawSprite(spriteSheet, 194, 89, 40, 35, 111, 57)
end

function game.keypressed(key)
  if key == 'up' or key == 'down' then
    pointerRow = 1 - pointerRow
  elseif key == 'left' or key == 'right' then
    pointerCol = 1 - pointerCol
  elseif key == 'z' then
    if dialogIndex == 2 then
      dialogIndex = 0
    else
      dialogIndex = dialogIndex + 1
    end
    pointerCol = 0
    pointerRow = 0
  end
end

return game
