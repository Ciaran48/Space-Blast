
local buttons = {}

local font1 = love.graphics.newFont("font/nasalization-rg.ttf", 30)
local font2 = love.graphics.newFont("font/Red Seven.otf", 45)

local volume = 0.5

function love.load()
    sprites = {}
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.enemy = love.graphics.newImage('sprites/enemy.png')
    sprites.background1 = love.graphics.newImage('sprites/background1.png')
    sprites.background2 = love.graphics.newImage('sprites/background2.png')
    sprites.background3 = love.graphics.newImage('sprites/background3.png')
    sprites.background4 = love.graphics.newImage('sprites/background4.png')
    sprites.missile = love.graphics.newImage('sprites/missile.png')

    --Player Start Location--
    player = {}
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
    -- Player Move Speed--
    -- Changed speed to 180 to fit dt move equation --
    player.speed = 180
    enemies = {}
    missiles = {}
    gameState = 1
    score=0
    maxTime = 2
    timer = maxTime

    -- Game Music --
    love.audio.setVolume(volume)
    gamemusic = love.audio.newSource('soundtrack/mixkit-game-level-music-689.wav', 'stream')
    menumusic = love.audio.newSource('soundtrack/Modular_Ambient_01_by_sscheidl.mp3', 'stream')
    missilesound = love.audio.newSource('soundtrack/missile.wav', 'stream')
    buttonsound = love.audio.newSource('soundtrack/hover.wav', 'stream')
    gameoversound = love.audio.newSource('soundtrack/over.wav', 'stream')
    enemyhitsound = love.audio.newSource('soundtrack/enemyhit.wav', 'stream')
    playerhitsound = love.audio.newSource('soundtrack/playerhit.wav', 'stream')

    font = love.graphics.newFont(32)
    -- Giving the The Buttons fuctions/use --
    table.insert(buttons, newButton(
          "StartGame",
          function()
          print("Starting Game")
          gameState = 2
        end))

    table.insert(buttons, newButton(
          "Controls",
          function()
          print("Accessing the Control Screen")
          gameState = 4
        end))

    table.insert(buttons, newButton(
          "About",
          function()
          print("Accessing the About Screen")
          gameState=5
        end))

    table.insert(buttons, newButton(
          "Exit",
          function()
          print("Exiting Game")
          love.event.quit(0)
        end))



end

function love.update(dt)
  --Update volume--
  love.audio.setVolume(volume)
--if gameState == 2 then
--Player Move Controls--
--used delta-time as It will sync the game --
--to the same speed in different computers--
    if love.keyboard.isDown("d") and player.x < love.graphics.getWidth()
      then
      player.x = player.x + player.speed*dt
    end
    if love.keyboard.isDown("a") and player.x > 0
      then
      player.x = player.x - player.speed*dt
    end
    if love.keyboard.isDown("w") and player.y > 0
        then
        player.y = player.y - player.speed*dt
    end
    if love.keyboard.isDown("s") and player.y < love.graphics.getHeight()
        then
        player.y = player.y + player.speed*dt
    end
  --end
    --Enemy Movement--
    -- for every enemy in enemies / All enemies--
    for i,e in ipairs(enemies) do
        --Move from location, towards new location at speed--
        e.x = e.x + (math.cos( enemyFacePlayer(e) ) * e.speed * dt)
        e.y = e.y + (math.sin( enemyFacePlayer(e) ) * e.speed * dt)
    --Collision Of enemy and Player--
    --if the enemy and player distance/range is less than 30--
      if range(e.x, e.y, player.x, player.y) < 30 then
        --the enemy will be removed--
              for i,e in ipairs(enemies) do
                enemies[i] = nil
                gameState = 3
                --Resets the player position after the game has ended--
                player.x = love.graphics.getWidth()/2
                player.y = love.graphics.getHeight()/2
              end
          end
    end
    --Missile Movement--
    --for each missile--
    for i,m in ipairs(missiles) do
      m.x = m.x + (math.cos (m.direction) * m.speed * dt)
      m.y = m.y + (math.sin (m.direction) * m.speed * dt)
    end
    --Remove Missile if it leaves the window--
    for i=#missiles, 1, -1 do
        local m = missiles[i]
        if m.x < 0 or m.y < 0 or m.x > love.graphics.getWidth() or m.y >
        love.graphics.getHeight() then
            table.remove(missiles, i)
        end
    end
    -- enemy and missile collision--
    --if an enemy and a missile are in range of eachother--
    for i,e in ipairs(enemies) do
        for j,m in ipairs(missiles) do
            if range(e.x, e.y, m.x, m.y) < 20 then
              --they become dead--
                e.dead = true
                m.dead = true
                --score increase--
                score = score + 1
            end
        end
    end
    --if an enemy is dead remove it--
    for i=#enemies,1,-1 do
        local e = enemies[i]
        if e.dead == true then
          enemyhitsound:stop()
          enemyhitsound:play()
          table.remove(enemies, i)
        end
    end
    --if an missile is dead remove it--
    for i=#missiles,1,-1 do
        local m = missiles[i]
        if m.dead == true then
            table.remove(missiles, i)
        end
    end
    --zombie spawn time--
      if gameState == 2 then
      timer = timer - dt
        if timer <= 0 then
            spawnEnemy()
            maxTime = 0.95 * maxTime
            timer = maxTime
        end
      end

end

function love.draw()
    --loads background--
    love.graphics.draw(sprites.background1, 0, 0)
    --Main Menu--
    if gameState == 1 then
      --music--
      gamemusic:stop()
      menumusic:play()
      love.graphics.draw(sprites.background2, 0, 0)
      love.graphics.setNewFont("font/Red Seven.otf", 50)
      love.graphics.printf("Space Blast", 0, 50, love.graphics.getWidth(), "center")
    end
    --Game Play Screem--
    if gameState == 2 then
      --music
      menumusic:stop()
      gamemusic:play()
      love.graphics.setNewFont("font/Red Seven.otf", 20)
      love.graphics.printf("Score: " .. score, 0, love.graphics.getHeight()-100,
      love.graphics.getWidth(), "center")
      --draw player, location, facepmouse, size, Center--
      love.graphics.draw(sprites.player, player.x, player.y, playerFaceMouse(),
       nil, nil, sprites.player:getWidth()/2,sprites.player:getHeight()/2)
      -- draw enemies--
      -- for every enemy in enemies / All enemies--
      for i,e in ipairs(enemies) do
        --draw enemy, location, faceplayer, size, Center--
          love.graphics.draw(sprites.enemy, e.x, e.y, enemyFacePlayer(e),
           nil, nil, sprites.enemy:getWidth()/2, sprites.enemy:getHeight()/2)
      end
      -- draw missiles--
      for i,m in ipairs(missiles) do
          love.graphics.draw(sprites.missile, m.x, m.y,
          -- scale the missile to size--
          nil, 0.5, nil, sprites.missile:getWidth()/2, sprites.missile:getHeight()/2)
      end
    end

    --Game Over Screen --
    if gameState == 3 then
      love.graphics.setNewFont("font/nasalization-rg.ttf", 23)
      gamemusic:stop()
      gameoversound:play()
      love.graphics.draw(sprites.background4, 0, 0)
      love.graphics.printf("Press Enter to start again!", 0, 50, love.graphics.getWidth(), "center")
      love.graphics.printf("Press Escape to return to Home Screen", 0, 500, love.graphics.getWidth(), "center")
      love.graphics.printf("Score that Game: " .. score, 0, love.graphics.getHeight()-100,
      love.graphics.getWidth(), "center")
    end
    -- Controls Screen --
  if gameState == 4 then
    love.graphics.setNewFont("font/nasalization-rg.ttf", 23)
    love.graphics.draw(sprites.background2, 0, 0)
    love.graphics.printf("Controls", 0, 50, love.graphics.getWidth(), "center")
    love.graphics.printf("WASD for Movement", 0, 250, love.graphics.getWidth(), "center")
    love.graphics.printf("Right Mouse Button to Fire", 0, 280, love.graphics.getWidth(), "center")
    love.graphics.printf("Spacebar Spawn more Enemies (if youre brave enough)", 0, 310, love.graphics.getWidth(), "center")
    love.graphics.printf("Mouse Movement to Aim", 0, 340, love.graphics.getWidth(), "center")
    love.graphics.printf("Up Key to Increase Volume", 0, 370, love.graphics.getWidth(), "center")
    love.graphics.printf("Down Key to Decrease Volume", 0, 400, love.graphics.getWidth(), "center")
    love.graphics.printf("Esc Key to return to previous Menu(s)", 0, 430, love.graphics.getWidth(), "center")
  end
  -- About Screen --
  if gameState == 5 then
    love.graphics.setNewFont("font/nasalization-rg.ttf", 23)
    love.graphics.draw(sprites.background2, 0, 0)
    love.graphics.printf("About", 0, 50, love.graphics.getWidth(), "center")
    love.graphics.printf("Fonts by 1001fonts.com", 0, 250, love.graphics.getWidth(), "center")
    love.graphics.printf("Music by mixkit.com", 0, 280, love.graphics.getWidth(), "center")
    love.graphics.printf("Coded by Ciarán Adams", 0, 310, love.graphics.getWidth(), "center")
    love.graphics.printf("BSc Computer Science", 0, 340, love.graphics.getWidth(), "center")
    love.graphics.printf("Liverpool Hope University", 0, 370, love.graphics.getWidth(), "center")
    love.graphics.printf("Student ID: 17005609", 0, 400, love.graphics.getWidth(), "center")
    love.graphics.printf("Esc Key to return to previous Menu(s)", 0, 430, love.graphics.getWidth(), "center")
  end
  -- main menu code --
  local WindowWidth = love.graphics.getWidth()
  local WindowHeight = love.graphics.getHeight()
  local button_width = WindowWidth * (1/4)
  local button_height = WindowWidth * (1/20)
  local margin = 16
  local total_height = (button_height + margin) * #buttons
  local cursor_y = 0
    if gameState ==1 then
      for i, button in ipairs(buttons) do
        button.last = button.now
        local buttonx = (WindowWidth * 0.5) - (button_width * 0.5)
        local buttony = (WindowHeight * 0.5) - (total_height * 0.5) + cursor_y
        local color = {0, 159, 134, 0.6}
        local mx, my = love.mouse.getPosition()
        local hover = mx > buttonx and mx < buttonx + button_width
        and my > buttony and my < buttony + button_height

        if hover then
            color = {0, 159, 134, 1}
        end

        font = love.graphics.newFont("font/nasalization-rg.ttf", 30)
        button.now = love.mouse.isDown(1)
        if button.now and not button.last and hover then
          button.fn ()
          buttonsound:play()
        end

        love.graphics.setColor(unpack(color))
        love.graphics.rectangle("fill", buttonx, buttony, button_width, button_height)
        love.graphics.setColor(1, 1, 1, 1)
        local text_width = font:getWidth(button.text)
        local text_height = font:getWidth(button.text)
        love.graphics.print(button.text, font, (WindowWidth * 0.5) - text_width * 0.5,
        buttony + text_height * 0.08)
        cursor_y = cursor_y + (button_height + margin)

      end
    end

end

-- RMB spawns a missile/fires a shot
function love.mousepressed( x, y, button )
  if button == 1 and gameState == 2 then
        missilesound:stop()
        missilesound:play()
        spawnMissile()
    end

end


function love.keypressed( key )
  -- Spacebar Spawns enemy --
    if key == "space" and gameState == 3 then
        spawnEnemy()
    end
  --Return/Enter key will restart the game from game over screen--
    if key == "return" and gameState == 3 then
       startgame()
       buttonsound:play()
       print("Restarting Game")
    end
    --Esc key will return to menu--
    if key == "escape" then
      returntomenu()
      buttonsound:play()
      print("Returning to menu")
    end
    --Arrow up key will increase volume--
    if key == "up" then
      increasevolume()
      print("Increasing Volume")
    end
    --Arrow down key will decrease volume--
    if key == "down" then
      decreasevolume()
      print("Decreasing Volume")
    end
end

                              --FUNCTIONS--
--Volume increase and Decrease--
function increasevolume()
  if (volume <=1) then volume = volume + 0.1 end
end
function decreasevolume()
  if (volume >=0) then volume = volume - 0.1 end
end
--Returns user to main menu--
function returntomenu()
  gameState = 1
end
--Create Buttons--
function newButton(text, fn)
  return
     {text = text, fn = fn, now = false, last = false}
end
-- Starts the Game
function startgame()
  gameState = 2
  maxTime = 2
  timer = maxTime
  score = 0
end

--Player Face Mouse Position--
function playerFaceMouse()
    return math.atan2( player.y - love.mouse.getY(), player.x - love.mouse.getX() ) + math.pi
end
-- Enemy face Player--
function enemyFacePlayer(enemy)
    return math.atan2( player.y - enemy.y, player.x - enemy.x )
end

--adds enemy to enemys--
function spawnEnemy()
    local enemy = {}
    enemy.x = 0
    enemy.y = 0
    enemy.dead= false
    enemy.speed = 120

    --chooses spawn side randomly between 1-4--
    local side = math.random(1, 4)
    --randome spawn location within window --
    if side == 1 then
        enemy.x = -30
        enemy.y = math.random(0, love.graphics.getHeight())
    elseif side == 2 then
        enemy.x = love.graphics.getWidth() + 30
        enemy.y = math.random(0, love.graphics.getHeight())
    elseif side == 3 then
        enemy.x = math.random(0, love.graphics.getWidth())
        enemy.y = -30
    elseif side == 4 then
        enemy.x = math.random(0, love.graphics.getWidth())
        enemy.y = love.graphics.getHeight() + 30
    end
    table.insert(enemies, enemy)
end

-- adds missile to missiles--
function spawnMissile()
    local missile = {}
    missile.dead = false
    --missile start location--
    missile.x = player.x
    missile.y = player.y
    missile.speed = 500
    --aims the missile firing direction--
    missile.direction = playerFaceMouse()
    table.insert(missiles, missile)
end



--range--
function range(x1, y1, x2, y2)
    return math.sqrt( (x2 - x1)^2 + (y2 - y1)^2 )
end
