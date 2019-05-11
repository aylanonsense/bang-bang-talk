local game = {}

local spriteSheet
local frame

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
  spriteSheet = love.graphics.newImage('src/games/my-games/img/sprite-sheet.png')
  spriteSheet:setFilter('nearest', 'nearest')
end

function game.load(args)  
  frame = 10
end

function game.update(dt)
  frame = frame + 1
end

function game.draw()
  love.graphics.translate(-96.0, -62.5)
  love.graphics.setColor(1, 1, 1)
  drawSprite(spriteSheet, 0, frame % 60 < 30 and 0 or 376, 576, 375, 0, 0)
end

return game
