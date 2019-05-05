local game = {}

-- Render constants
local GAME_WIDTH = 192
local GAME_HEIGHT = 125
local RENDER_SCALE = 4

local isHit
local canSwing
local swingFrames
local hitFrames
local freezeFrames
local screenShakeFrames
local spriteSheet
local ball

local useElasticAnimations
local useFastBall
local useFreezeFrames
local useScreenShake
local useParticles
local useHitEffects

local drawSprite = function(spriteSheetImage, sx, sy, sw, sh, x, y, flipHorizontal, flipVertical, rotation)
  local width, height = spriteSheetImage:getDimensions()
  love.graphics.draw(spriteSheetImage,
    love.graphics.newQuad(sx, sy, sw, sh, width, height),
    x + sw / 2, y + sh / 2,
    rotation or 0,
    flipHorizontal and -1 or 1, flipVertical and -1 or 1,
    sw / 2, sh / 2)
end

local animations = {
  elasticBat = { 1, 2, 3, 4, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 10, 10, 11, 12, 13, 14, 15, 16, 16, 17, 17, 17 },
  rigidBat = { 0, 1, 2, 3, 4, 5, 6, 7 },
  yellowHitEffect = { 1, 0 },
  whiteHitEffect = { 0, 1, 1, 1 },
  pinkParticles = { 0, 1, 1, 2, 2, 3, 3, 3, 3, 4, 4 },
  grass = { 1, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1 },
  whiteParticles = { 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7 },
  pinkParticles = { 0, 1, 1, 2, 2, 3, 3, 3, 3, 4, 4 }
}

function game.preload()
  -- Load assets
  spriteSheet = love.graphics.newImage('src/games/juice/img/sprite-sheet.png')
  spriteSheet:setFilter('nearest', 'nearest')
end

function game.load(args)
  isHit = false
  canSwing = true
  swingFrames = 9999
  hitFrames = 0
  freezeFrames = 0
  screenShakeFrames = 0
  ball = {
    x = 9999,
    y = 87,
    vx = 0,
    vy = 0,
    sprite = 1
  }

  useElasticAnimations = true
  useFastBall = true
  useFreezeFrames = true
  useScreenShake = true
  useParticles = true
  useHitEffects = true
end

-- local frames = 0
function game.update(dt)
  -- frames = frames + 1
  -- if frames % 20 > 1 then return end
  if freezeFrames > 0 then
    freezeFrames = math.max(0, freezeFrames - 1)
  else
    screenShakeFrames = math.max(0, screenShakeFrames - 1)
    swingFrames = math.min(swingFrames + 1, 9999)
    hitFrames = math.min(hitFrames + 1, 9999)
    -- Swing
    if swingFrames > 19 then
      canSwing = true
    end
    if (useElasticAnimations and swingFrames == 7) or (not useElasticAnimations and swingFrames == 9) then
      if 16 <= ball.x and ball.x <= 80 then
        isHit = true
        hitFrames = 1
        if useFreezeFrames then
          freezeFrames = 8
        end
        if useScreenShake then
          screenShakeFrames = 12
        end
        ball.x = 54
        ball.y = 87
        ball.vx = useFastBall and 900 or 75
        ball.vy = useFastBall and -450 or 0
        ball.sprite = useFastBall and 0 or 2
      end
    end
    -- Update ball
    ball.x = ball.x + ball.vx * dt
    ball.y = ball.y + ball.vy * dt
    if ball.x < -10 or ball.x > (useFastBall and 600 or 300) then
      ball.x = useFastBall and 300 or 220
      ball.y = 87
      ball.vx = useFastBall and -275 or -75
      ball.vy = 0
      ball.sprite = useFastBall and 1 or 2
    end
  end
end

function game.draw()
  local f = math.ceil(swingFrames / 2)
  local h = math.ceil(hitFrames / 2)

  local screenShakeX
  if screenShakeFrames > 0 then
    screenShakeX = f % 2 == 0 and 1 or -1
  else
    screenShakeX = 0
  end

  -- Scale and crop the screen
  love.graphics.setScissor(0, 0, RENDER_SCALE * GAME_WIDTH, RENDER_SCALE * GAME_HEIGHT)
  love.graphics.scale(RENDER_SCALE, RENDER_SCALE)
  love.graphics.clear(169 / 255, 232 / 255, 85 / 255)
  love.graphics.setColor(1, 1, 1)
  love.graphics.translate(screenShakeX, 0)

  -- Draw the grass
  local grassSprite
  if isHit and useHitEffects and 0 < h and h <= #animations.grass then
     grassSprite = animations.grass[h]
  else
    grassSprite = 0
  end
  drawSprite(spriteSheet, 1, 1 + 49 * grassSprite, 192, 48, 0, 77)

  -- Draw yellow hit effect
  if isHit and useHitEffects and 0 < h and h <= #animations.yellowHitEffect then
    local yellowHitSprite = animations.yellowHitEffect[h]
    drawSprite(spriteSheet, 1, 148 + 126 * yellowHitSprite, 192, 125, 0, 0)
  end

  -- Draw bat
  if useElasticAnimations then
    local batSprite
    if 0 < f and f <= #animations.elasticBat then
      batSprite = animations.elasticBat[f]
    else
      batSprite = 0
    end
    drawSprite(spriteSheet, 298 + 82 * (batSprite % 6), 1 + 55 * math.floor(batSprite / 6), 81, 54, 0, 48)
  else
    local batSprite
    if 0 < f and f <= #animations.rigidBat then
      batSprite = animations.rigidBat[f]
    else
      batSprite = 0
    end
    drawSprite(spriteSheet, 298 + 82 * (batSprite % 6), 166 + 55 * math.floor(batSprite / 6), 81, 54, 5, 48)
  end

  -- Draw ball
  if not isHit or hitFrames > 2 or not useHitEffects then
    drawSprite(spriteSheet, 194, 65 + 15 * ball.sprite, 32, 14, ball.x - 22, ball.y - 2)
  end

  if isHit then
    -- Draw white hit effect
    if useHitEffects and 0 < h and h <= #animations.whiteHitEffect then
      local whiteHitSprite = animations.whiteHitEffect[h]
      drawSprite(spriteSheet, 194 + 52 * whiteHitSprite, 1, 51, 63, 45, 52)
    end

    -- Draw white particles
    if useParticles and 0 < h - 1 and h - 1 <= #animations.whiteParticles then
      local whiteParticlesSprite = animations.whiteParticles[h - 1]
      drawSprite(spriteSheet, 1 + 193 * (whiteParticlesSprite % 4), 400 + 126 * math.floor(whiteParticlesSprite / 4), 192, 125, 0, 0)
    end

    -- Draw pink particles
    if useParticles and 0 < h and h <= #animations.pinkParticles then
      local pinkParticlesSprite = animations.pinkParticles[h]
      drawSprite(spriteSheet, 194 + 49 * pinkParticlesSprite, 321, 48, 78, 44, 27)
    end
  end
end

function game.keypressed(key)
  if key == 'space' then
    if canSwing then
      isHit = false
      canSwing = false
      swingFrames = 0
    end
  end
end

return game
