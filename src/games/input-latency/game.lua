local game = {}

local tableUtils = require 'src/utils/table'

-- Render constants
local GAME_WIDTH = 192
local GAME_HEIGHT = 125
local RENDER_SCALE = 2

-- Game constants
local LEVEL_NUM_COLUMNS = 12
local LEVEL_NUM_ROWS = 8
local LEVEL_DATA = [[
............
............
............
............
...........o
X..........X
X.P...oooo.X
XXXXXXXXXXXX
]]

-- Game variables
local player
local platforms
local gems
local currKeyPresses

-- The number of frames of input latency
local inputLatency

-- A history of game states and inputs
  -- history[2] is a full second in the past
  -- history[62] is the current frame
  -- history[122] is a full second in the future
local history

-- Assets
local playerImage
local objectsImage
local uiImage
local walkSounds
local jumpSound
local landSound
local gemSound

-- Draws a sprite from a sprite sheet, spriteNum=1 is the upper-leftmost sprite
local drawSprite = function(spriteSheetImage, spriteWidth, spriteHeight, sprite, x, y, flipHorizontal, flipVertical, rotation)
  local width, height = spriteSheetImage:getDimensions()
  local numColumns = math.floor(width / spriteWidth)
  local col, row = (sprite - 1) % numColumns, math.floor((sprite - 1) / numColumns)
  love.graphics.draw(spriteSheetImage,
    love.graphics.newQuad(spriteWidth * col, spriteHeight * row, spriteWidth, spriteHeight, width, height),
    x + spriteWidth / 2, y + spriteHeight / 2,
    rotation or 0,
    flipHorizontal and -1 or 1, flipVertical and -1 or 1,
    spriteWidth / 2, spriteHeight / 2)
end

local drawSprite2 = function(spriteSheetImage, sx, sy, sw, sh, x, y, flipHorizontal, flipVertical, rotation)
  local width, height = spriteSheetImage:getDimensions()
  love.graphics.draw(spriteSheetImage,
    love.graphics.newQuad(sx, sy, sw, sh, width, height),
    x + sw / 2, y + sh / 2,
    rotation or 0,
    flipHorizontal and -1 or 1, flipVertical and -1 or 1,
    sw / 2, sh / 2)
end

-- Determine whether two rectangles are overlapping
local rectsOverlapping = function(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 + w1 > x2 and x2 + w2 > x1 and y1 + h1 > y2 and y2 + h2 > y1
end

-- Returns true if two entities are overlapping, by checking their bounding boxes
local entitiesOverlapping = function(a, b)
  return rectsOverlapping(a.x, a.y, a.width, a.height, b.x, b.y, b.width, b.height)
end

-- Checks to see if two entities are colliding, and if so from which side. This is
-- accomplished by checking the four quadrants of the axis-aligned bounding boxes
local checkForCollision = function(a, b)
  local indent = 3
  if rectsOverlapping(a.x + indent, a.y + a.height / 2, a.width - 2 * indent, a.height / 2, b.x, b.y, b.width, b.height) then
    return 'bottom'
  elseif rectsOverlapping(a.x + indent, a.y, a.width - 2 * indent, a.height / 2, b.x, b.y, b.width, b.height) then
    return 'top'
  elseif rectsOverlapping(a.x, a.y + indent, a.width / 2, a.height - 2 * indent, b.x, b.y, b.width, b.height) then
    return 'left'
  elseif rectsOverlapping(a.x + a.width / 2, a.y + indent, a.width / 2, a.height - 2 * indent, b.x, b.y, b.width, b.height) then
    return 'right'
  end
end

-- Gets the current state of the application
local getState = function()
  return tableUtils.cloneTable({
    player = player,
    gems = gems
  })
end

local applyState = function(state)
  player = tableUtils.cloneTable(state.player)
  gems = tableUtils.cloneTable(state.gems)
end

local getInputs = function(ignoreInstantInputs)
  return {
    left = currKeyPresses.left, -- love.keyboard.isDown('left'),
    right = currKeyPresses.right, -- love.keyboard.isDown('right'),
    jump = not ignoreInstantInputs and currKeyPresses.space -- love.keyboard.isDown('space')
  }
end

function game.preload()
  -- Load assets
  playerImage = love.graphics.newImage('src/games/input-latency/img/player.png')
  objectsImage = love.graphics.newImage('src/games/input-latency/img/objects.png')
  uiImage = love.graphics.newImage('src/games/input-latency/img/ui.png')
  playerImage:setFilter('nearest', 'nearest')
  objectsImage:setFilter('nearest', 'nearest')
  uiImage:setFilter('nearest', 'nearest')
  walkSounds = {
    love.audio.newSource('src/games/input-latency/sfx/walk1.wav', 'static'),
    love.audio.newSource('src/games/input-latency/sfx/walk2.wav', 'static')
  }
  jumpSound = love.audio.newSource('src/games/input-latency/sfx/jump.wav', 'static')
  landSound = love.audio.newSource('src/games/input-latency/sfx/land.wav', 'static')
  gemSound = love.audio.newSource('src/games/input-latency/sfx/gem.wav', 'static')
end

-- Initializes the game
function game.load(args)
  currKeyPresses = {}
  -- Create platforms and game objects from the level data
  platforms = {}
  gems = {}
  for col = 1, LEVEL_NUM_COLUMNS do
    for row = 1, LEVEL_NUM_ROWS do
      local i = (LEVEL_NUM_COLUMNS + 1) * (row - 1) + col
      local x, y = 16 * (col - 1), 16 * (row - 1)
      local symbol = string.sub(LEVEL_DATA, i, i)
      if symbol == 'P' then
        -- Create the player
        player = {
          x = x,
          y = y,
          vx = 0,
          vy = 0,
          width = 16,
          height = 16,
          isFacingLeft = false,
          isGrounded = false,
          landingTimer = 0.00,
          walkTimer = 0.00
        }
      elseif symbol == 'X' then
        -- Create a platform
        table.insert(platforms, {
          x = x,
          y = y,
          width = 16,
          height = 16
        })
      elseif symbol == 'o' then
        -- Create a gem
        table.insert(gems, {
          x = x,
          y = y,
          width = 16,
          height = 16,
          isCollected = false
        })
      end
    end
  end

  -- Create constructs necessary for simulated input latency
  inputLatency = 0
  history = {}
  for i = 1, 62 do
    history[i] = {
      dt = 1 / 60,
      inputs = getInputs(),
      state = getState(),
      playedJumpSound = false
    }
  end
  for i = 63, 122 do
    history[i] = {}
  end
end

-- Updates the game state
local updateGame = function(dt, inputs, allowSounds, allowJumpSound)
  local playedJumpSound = false

  player.landingTimer = math.max(0, player.landingTimer - dt)

  -- Figure out which direction the player is moving
  local moveX = (inputs.left and -1 or 0) + (inputs.right and 1 or 0)

  -- Keep track of the player's walk cycle
  if player.isGrounded and allowSounds then
    if player.walkTimer < 0.20 and player.walkTimer + dt >= 0.20 then
      love.audio.play(walkSounds[1]:clone())
    elseif player.walkTimer < 0.50 and player.walkTimer + dt >= 0.50 then
      love.audio.play(walkSounds[2]:clone())
    end
  end
  player.walkTimer = moveX == 0 and 0.00 or ((player.walkTimer + dt) % 0.60)

  -- Move the player left / right
  player.vx = 62 * moveX
  if moveX < 0 then
    player.isFacingLeft = true
  elseif moveX > 0 then
    player.isFacingLeft = false
  end

  -- Jump when space is pressed
  if player.isGrounded and inputs.jump then
    player.vy = -200
    if allowJumpSound then
      love.audio.play(jumpSound:clone())
      playedJumpSound = true
    end
  end

  -- Accelerate downward (a la gravity)
  player.vy = player.vy + 480 * dt

  -- Apply the player's velocity to her position
  player.x = player.x + player.vx * dt
  player.y = player.y + player.vy * dt

  -- Check for collisions with platforms
  local wasGrounded = player.isGrounded
  player.isGrounded = false
  for _, platform in ipairs(platforms) do
    local collisionDir = checkForCollision(player, platform)
    if collisionDir == 'top' then
      player.y = platform.y + platform.height
      player.vy = math.max(0, player.vy)
    elseif collisionDir == 'bottom' then
      player.y = platform.y - player.height
      player.vy = math.min(0, player.vy)
      player.isGrounded = true
      if not wasGrounded then
        player.landingTimer = 0.15
        if allowSounds then
          love.audio.play(landSound:clone())
        end
      end
    elseif collisionDir == 'left' then
      player.x = platform.x + platform.width
      player.vx = math.max(0, player.vx)
    elseif collisionDir == 'right' then
      player.x = platform.x - player.width
      player.vx = math.min(0, player.vx)
    end
  end

  -- Check for gem collection
  for _, gem in ipairs(gems) do
    if not gem.isCollected and entitiesOverlapping(player, gem) then
      gem.isCollected = true
      if allowSounds then
        love.audio.play(gemSound:clone())
      end
    end
  end

  -- Keep the player in bounds
  if player.x < 0 then
    player.x = 0
  elseif player.x > GAME_WIDTH - player.width then
    player.x = GAME_WIDTH - player.width
  end
  if player.y > GAME_HEIGHT + 50 then
    player.y = -10
  end

  return playedJumpSound
end

function game.update(dt)
  -- Move history along
  for i = 1, 121 do
    history[i] = history[i + 1]
  end
  history[122] = {}

  -- Record the player's inputs with input latency taken into acount
  history[62 + inputLatency].inputs = getInputs()
  for i = 63 + inputLatency, 62 do
    history[i].inputs = getInputs(true)
  end

  -- Regenerate all the state history, including the current frame
  history[62].dt = dt
  applyState(history[1].state)
  for i = 2, 62 do
    local allowSounds = i == 62
    local allowJumpSound = not history[i].playedJumpSound
    local playedJumpSound = updateGame(history[i].dt, history[i].inputs or {}, allowSounds, allowJumpSound)
    if allowJumpSound and playedJumpSound then
      history[i].playedJumpSound = true
    end
    history[i].state = getState()
  end
end

-- Renders the game
function game.draw()
  -- Scale and crop the screen
  love.graphics.scale(RENDER_SCALE, RENDER_SCALE)
  love.graphics.setColor(251 / 255, 134 / 255, 199 / 255)
  love.graphics.rectangle('fill', 0, 0, GAME_WIDTH, GAME_HEIGHT)
  love.graphics.setColor(1, 1, 1, 1)

  -- Draw input latency
  drawSprite2(uiImage, 1, 1, 108, 10, 46, 8)
  local latencyText = '' .. math.abs(inputLatency)
  for i = 1, #latencyText do
    local c = string.sub(latencyText, i, i)
    drawSprite2(uiImage, 6 + 6 * tonumber(c), 14, 5, 8, 137 + 6 * i - 3 * #latencyText, 5)
  end
  if inputLatency < 0 then
    drawSprite2(uiImage, 1, 17, 4, 2, 132, 8)
  end

  -- Draw inputs
  drawSprite2(uiImage, currKeyPresses.left and 29 or 1, 23, 13, 14, 82, 29)
  drawSprite2(uiImage, currKeyPresses.right and 43 or 15, 23, 13, 14, 96, 29)
  drawSprite2(uiImage, currKeyPresses.space and 29 or 1, 38, 27, 13, 82, 44)

  -- Draw  the platforms
  for _, platform in ipairs(platforms) do
    drawSprite(objectsImage, 16, 16, 1, platform.x, platform.y + 3)
  end

  -- Draw the gems
  for _, gem in ipairs(gems) do
    if not gem.isCollected then
      drawSprite(objectsImage, 16, 16, 2, gem.x, gem.y + 3)
    end
  end

  -- Draw the player
  local sprite
  if player.isGrounded then
    -- When standing
    if player.vx == 0 then
      if player.landingTimer > 0.00 then
        sprite = 7
      else
        sprite = 1
      end
    -- When running
    elseif player.walkTimer < 0.2 then
      sprite = 2
    elseif player.walkTimer < 0.3 then
      sprite = 3
    elseif player.walkTimer < 0.5 then
      sprite = 4
    else
      sprite = 3
    end
  -- When jumping
  elseif player.vy > 0 then
    sprite = 6
  else
    sprite = 5
  end
  drawSprite(playerImage, 16, 16, sprite, player.x, player.y + 3, player.isFacingLeft)
end

function game.keypressed(key)
  currKeyPresses[key] = true
  local amt = (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) and 1 or 5
  if key == 'up' then
    inputLatency = math.min(inputLatency + amt, 60)
  elseif key == 'down' then
    inputLatency = math.max(-60, inputLatency - amt)
  end
end

function game.keyreleased(key)
  currKeyPresses[key] = false
end

return game
