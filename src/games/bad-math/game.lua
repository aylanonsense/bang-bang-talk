local game = {}

local spriteSheet

-- Render constants
local GAME_WIDTH = 192
local GAME_HEIGHT = 125
local RENDER_SCALE = 3

local pointerCol
local pointerRow
local dialogIndex
local animationFrames
local hitChanceSprite
local dynamicHitChance
local isHit

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

function game.load(args)
  pointerCol = 0
  pointerRow = 0
  dialogIndex = 0
  animationFrames = 0
  hitChanceSprite = 0
  dynamicHitChance = args and args.dynamicHitChance
  isHit = false
end

function game.update(dt)
  animationFrames = animationFrames + 1
  if dialogIndex == 2 and animationFrames > 160 then
    dialogIndex = 0
    if dynamicHitChance then
      if isHit then
        hitChanceSprite = 0
      else
        hitChanceSprite = math.min(hitChanceSprite + 1, 2)
      end
    end
  end
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
  local mailPersonSprite = 0
  if dialogIndex == 2 then
    if animationFrames < 35 then
      mailPersonSprite = 1
    elseif animationFrames < 39 then
      mailPersonSprite = 2
    elseif animationFrames < 45 then
      mailPersonSprite = 3
    elseif animationFrames < 51 then
      mailPersonSprite = 4
    elseif animationFrames < 140 then
      mailPersonSprite = 5
    end
  end
  drawSprite(spriteSheet, 50 * mailPersonSprite + 1, 127, 49, 40, 41, 51)

  -- Draw the mailbox
  local mailboxSprite
  if not isHit and dialogIndex == 2 and 39 <= animationFrames and animationFrames < 85 then
    mailboxSprite = 1
  else
    mailboxSprite = 0
  end
  drawSprite(spriteSheet, 194 + 41 * mailboxSprite, 89, 40, 35, 111, 57)

  -- Draw mail
  if dialogIndex == 2 and 44 <= animationFrames and animationFrames < 51 then
    drawSprite(spriteSheet, 285, 71, 29, 5, 95, 63)
  elseif not isHit and dialogIndex == 2 and 51 <= animationFrames and animationFrames < 58 then
    drawSprite(spriteSheet, 285, 71, 29, 5, 120, 63)
  end

  -- Draw miss
  if not isHit then
    if dialogIndex == 2 and animationFrames >= 39 then
      local missSprite
      if animationFrames < 43 then
        missSprite = 0
      elseif animationFrames < 47 then
        missSprite = 1
      else
        missSprite = 2
      end
      drawSprite(spriteSheet, 285, 1 + 12 * missSprite, 42, 11, 111, 47)
    end
  end

  -- Draw the hit chance
  drawSprite(spriteSheet, 285 + 41 * hitChanceSprite, 39, 40, 29, 77, 10)
end

function game.keypressed(key)
  if key == 'up' or key == 'down' then
    pointerRow = 1 - pointerRow
  elseif key == 'left' or key == 'right' then
    pointerCol = 1 - pointerCol
  elseif (key == 'z' or key == 'h') and dialogIndex ~= 2 then
    isHit = (key == 'h')
    dialogIndex = dialogIndex + 1
    pointerCol = 0
    pointerRow = 0
    animationFrames = 0
  end
end

return game
