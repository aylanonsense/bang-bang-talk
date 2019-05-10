local game = {}

-- Render constants
local GAME_WIDTH = 192
local GAME_HEIGHT = 125
local RENDER_SCALE = 2

local isInMenu
local isHit
local canSwing
local swingFrames
local hitFrames
local freezeFrames
local screenShakeFrames
local balls
local pointerCol
local pointerRow
local spriteSheet
local uiImage

local useElasticAnimations
local useFastBall
local useFreezeFrames
local useScreenShake
local useParticles
local useHitEffects
local useCrunchySounds
local moreMoreMore

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
  uiImage = love.graphics.newImage('src/games/juice/img/ui.png')
  uiImage:setFilter('nearest', 'nearest')
end

function game.load(args)
  isInMenu = false
  isHit = false
  canSwing = true
  swingFrames = 9999
  hitFrames = 0
  freezeFrames = 0
  screenShakeFrames = 0
  balls = {
    {
      x = 9999,
      y = 87,
      vx = 0,
      vy = 0,
      sprite = 1,
      hit = false
    }
  }
  pointerCol = 0
  pointerRow = 0

  useElasticAnimations = args and args.enableJuice
  useFastBall = args and args.enableJuice
  useFreezeFrames = args and args.enableJuice
  useScreenShake = args and args.enableJuice
  useParticles = args and args.enableJuice
  useHitEffects = args and args.enableJuice
  useCrunchySounds = args and args.enableJuice
  moreMoreMore = false
end

function game.update(dt)
  if not isInMenu then
    if freezeFrames > 0 then
      freezeFrames = math.max(0, freezeFrames - 1)
    else
      if #balls < 30 and moreMoreMore then
        table.insert(balls, {
          x = 9999,
          y = 87,
          vx = 0,
          vy = 0,
          sprite = 1,
          hit = false
        })
      elseif #balls > 1 and not moreMoreMore then
        balls = { balls[1] }
      end
      screenShakeFrames = math.max(0, screenShakeFrames - 1)
      swingFrames = math.min(swingFrames + 1, 9999)
      hitFrames = math.min(hitFrames + 1, 9999)
      -- Swing
      if swingFrames > (moreMoreMore and 12 or 19) then
        canSwing = true
      end
      if (useElasticAnimations and swingFrames == 7) or (not useElasticAnimations and swingFrames == 9) then
        for _, ball in ipairs(balls) do
          if 16 <= ball.x and ball.x <= 80 then
            isHit = true
            hitFrames = 1
            if useFreezeFrames then
              freezeFrames = 8
            end
            if useScreenShake then
              screenShakeFrames = 12
            end
            ball.x = 54 + (moreMoreMore and 6 * math.random() - 3 or 0)
            ball.y = 87 + (moreMoreMore and 6 * math.random() - 3 or 0)
            local speed = moreMoreMore and (0.5 + 1.0 * math.random()) or 1.0
            ball.vx = speed * (useFastBall and (700 + 400 * math.random()) or 75)
            ball.vy = speed * (useFastBall and (-500 + 100 * math.random()) or 0)
            ball.sprite = useFastBall and 0 or 2
            ball.hit = true
          end
        end
      end
      -- Update ball
      for _, ball in ipairs(balls) do
        ball.x = ball.x + ball.vx * dt
        ball.y = ball.y + ball.vy * dt
        if ball.x < -10 or ball.x > (useFastBall and 600 or 300) then
          ball.x = useFastBall and 300 + (moreMoreMore and 200 * math.random() or 0) or 220 + (moreMoreMore and 70 * math.random() or 0)
          ball.y = 87 + (moreMoreMore and 6 * math.random() - 3 or 0)
          ball.vx = useFastBall and -325 or -75
          ball.vy = 0
          ball.sprite = useFastBall and 1 or 2
          ball.hit = false
        end
      end
    end
  end
end

function game.draw()
  local f = math.ceil(swingFrames / 2)
  local h = math.ceil(hitFrames / 2)

  local screenShakeX
  if screenShakeFrames > 0 and not isInMenu then
    screenShakeX = f % 2 == 0 and 1 or -1
  else
    screenShakeX = 0
  end

  -- Scale and crop the screen
  love.graphics.scale(RENDER_SCALE, RENDER_SCALE)
  love.graphics.setColor(isInMenu and { 37 / 255, 2 / 255, 72 / 255 } or { 169 / 255, 232 / 255, 85 / 255 })
  love.graphics.rectangle('fill', 0, 0, GAME_WIDTH, GAME_HEIGHT)
  love.graphics.setColor(1, 1, 1)
  love.graphics.translate((moreMoreMore and 2 or 1) * screenShakeX, 0)

  if isInMenu then
    -- Draw the highlight
    drawSprite(uiImage, 55, 82, 87, 17, 12 + 88 * pointerCol, 19 + 23 * pointerRow)

    -- Draw the menu
    drawSprite(uiImage, 1, 1, 162, 80, 15, 23)

    -- Draw checkboxes
    if useScreenShake then
      drawSprite(uiImage, 41, 82, 13, 10, 14, 20)
    end
    if useFreezeFrames then
      drawSprite(uiImage, 41, 82, 13, 10, 14, 43)
    end
    if useElasticAnimations then
      drawSprite(uiImage, 41, 82, 13, 10, 14, 66)
    end
    if useCrunchySounds then
      drawSprite(uiImage, 41, 82, 13, 10, 14, 89)
    end
    if useParticles then
      drawSprite(uiImage, 41, 82, 13, 10, 102, 20)
    end
    if useHitEffects then
      drawSprite(uiImage, 41, 82, 13, 10, 102, 43)
    end
    if useFastBall then
      drawSprite(uiImage, 41, 82, 13, 10, 102, 66)
    end
    if moreMoreMore then
      drawSprite(uiImage, 41, 82, 13, 10, 102, 89)
    end
  else
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
    for _, ball in ipairs(balls) do
      if not ball.hit or hitFrames > 2 or not useHitEffects then
        drawSprite(spriteSheet, 194, 65 + 15 * ball.sprite, 32, 14, ball.x - 22, ball.y - 2)
      end
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
end

function game.keypressed(key)
  if key == 'm' then
    isInMenu = not isInMenu
    for _, ball in ipairs(balls) do
      ball.x = 9999
    end
  end
  if isInMenu then
    if key == 'space' then
      if pointerCol == 0 and pointerRow == 0 then
        useScreenShake = not useScreenShake
      elseif pointerCol == 0 and pointerRow == 1 then
        useFreezeFrames = not useFreezeFrames
      elseif pointerCol == 0 and pointerRow == 2 then
        useElasticAnimations = not useElasticAnimations
      elseif pointerCol == 0 and pointerRow == 3 then
        useCrunchySounds = not useCrunchySounds
      elseif pointerCol == 1 and pointerRow == 0 then
        useParticles = not useParticles
      elseif pointerCol == 1 and pointerRow == 1 then
        useHitEffects = not useHitEffects
      elseif pointerCol == 1 and pointerRow == 2 then
        useFastBall = not useFastBall
      elseif pointerCol == 1 and pointerRow == 3 then
        moreMoreMore = not moreMoreMore
      end
    elseif key == 'up' then
      pointerRow = pointerRow - 1
      if pointerRow < 0 then
        pointerRow = 2
      end
    elseif key == 'down' then
      pointerRow = (pointerRow + 1) % 4
    elseif key == 'left' then
      pointerCol = 1 - pointerCol
    elseif key == 'right' then
      pointerCol = 1 - pointerCol
    end
  else
    if key == 'space' and canSwing then
      isHit = false
      canSwing = false
      swingFrames = 0
    end
  end
end

return game
