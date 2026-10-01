local Starfield = require("src.entities.starfield")
local ParticleSystem = require("src.entities.particle")
local Sound = require("src.core.sound")
local BulletManager = require("src.entities.bullet")
local Player = require("src.entities.player")
local EnemyManager = require("src.entities.enemy")
local Fonts = require("src.core.fonts")
local Collision = require("src.systems.collision")
local UI = require("src.systems.ui")
local Shaders = require("src.core.shaders")

-- Game Variables
local screenW, screenH = 800, 600
local gameState = "menu" -- "menu", "playing", "paused", "gameover"

local starfield
local particleSystem
local bulletManager
local player
local enemyManager

local score = 0
local highScore = 0
local screenShakeTime = 0
local screenShakeMag = 0
local notificationText = ""
local notificationTimer = 0

local function showNotification(msg)
    notificationText = msg
    notificationTimer = 1.5
end

-- Helper for triggering screen shake & chromatic aberration
local function triggerShake(magnitude, duration)
    screenShakeMag = magnitude
    screenShakeTime = duration
    Shaders.triggerChromatic(magnitude * 0.002)
end

function love.load()
    math.randomseed(os.time())

    screenW = love.graphics.getWidth()
    screenH = love.graphics.getHeight()

    Sound.init()
    Fonts.init()
    Shaders.init(screenW, screenH)

    -- Pre-calculate generic icon visual center offsets at startup outside love.draw()
    EnemyManager.preloadIcons(Fonts.medium, { Fonts.icons.heart, Fonts.icons.triple, Fonts.icons.shield })

    starfield = Starfield.new(screenW, screenH, 140)
    particleSystem = ParticleSystem.new()
    bulletManager = BulletManager.new()
    player = Player.new(screenW / 2, screenH / 2)
    enemyManager = EnemyManager.new(screenW, screenH)
end

local function resetGame()
    score = 0
    bulletManager:clear()
    particleSystem:clear()
    enemyManager:clear()
    player:reset(screenW / 2, screenH / 2)
    player.lives = 3
    player.health = 100
    enemyManager:startWave(1)
    gameState = "playing"
end

function love.update(dt)
    starfield:update(dt)
    Shaders.update(dt)

    if notificationTimer > 0 then
        notificationTimer = notificationTimer - dt
    end

    -- Screen shake decay
    if screenShakeTime > 0 then
        screenShakeTime = screenShakeTime - dt
        if screenShakeTime <= 0 then
            screenShakeMag = 0
        end
    end

    if gameState == "playing" then
        particleSystem:update(dt)
        player:update(dt, bulletManager, particleSystem, screenW, screenH)
        bulletManager:update(dt, screenW, screenH)
        enemyManager:update(dt, player, bulletManager, particleSystem)

        -- Collision detection & combat processing
        Collision.check(player, bulletManager, enemyManager, particleSystem, triggerShake,
            function(gainedScore)
                score = score + gainedScore
                if score > highScore then highScore = score end
            end,
            function()
                gameState = "gameover"
                Sound.play("gameover")
            end
        )
    end
end

function love.keypressed(key)
    if key == "f1" then
        Shaders.crtEnabled = not Shaders.crtEnabled
        Sound.play("powerup")
        showNotification("CRT Scanlines & Curvature: " .. (Shaders.crtEnabled and "ON" or "OFF"))
    elseif key == "f2" then
        Shaders.bloomEnabled = not Shaders.bloomEnabled
        Sound.play("powerup")
        showNotification("Bloom Glow: " .. (Shaders.bloomEnabled and "ON" or "OFF"))
    elseif key == "f3" then
        Shaders.chromaticEnabled = not Shaders.chromaticEnabled
        if Shaders.chromaticEnabled then
            Shaders.triggerChromatic(0.03)
        end
        Sound.play("powerup")
        showNotification("Chromatic Aberration: " .. (Shaders.chromaticEnabled and "ON" or "OFF"))
    elseif key == "1" or key == "2" or key == "3" or key == "4" then
        local m = tonumber(key)
        if player then player.shipModel = m end
        local modelNames = { "Diamond Stealth", "Navy Dreadnought", "Twin-Hull Strike", "Delta Interceptor" }
        showNotification("Ship Selected: " .. modelNames[m])
        Sound.play("powerup")
    elseif key == "c" then
        if player then
            player.shipModel = (player.shipModel % 4) + 1
            local modelNames = { "Diamond Stealth", "Navy Dreadnought", "Twin-Hull Strike", "Delta Interceptor" }
            showNotification("Ship Selected: " .. modelNames[player.shipModel])
            Sound.play("powerup")
        end
    end

    if gameState == "playing" then
        if key == "escape" or key == "p" then
            gameState = "paused"
        end

    elseif gameState == "paused" then
        if key == "p" or key == "escape" then
            gameState = "playing"
        elseif key == "m" or key == "q" or key == "r" then
            gameState = "menu"
            Sound.play("hit")
        end

    elseif gameState == "menu" then
        if key == "return" or key == "space" then
            resetGame()
        elseif key == "q" or key == "escape" then
            love.event.quit()
        end

    elseif gameState == "gameover" then
        if key == "return" or key == "space" then
            resetGame()
        elseif key == "m" or key == "q" or key == "escape" then
            gameState = "menu"
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if gameState == "menu" or gameState == "gameover" then
            resetGame()
        end
    end
end

function love.draw()
    Shaders.startCapture()

    -- Apply Screen Shake
    love.graphics.push()
    if screenShakeTime > 0 then
        local dx = (math.random() - 0.5) * screenShakeMag
        local dy = (math.random() - 0.5) * screenShakeMag
        love.graphics.translate(dx, dy)
    end

    -- Draw Starfield Background
    starfield:draw()

    if gameState == "playing" or gameState == "paused" then
        bulletManager:draw()
        enemyManager:draw(Fonts)
        particleSystem:draw()
        player:draw()

        UI.drawHUD(player, enemyManager, score, highScore, screenW)
        UI.drawWaveBanner(enemyManager, screenW, screenH)

        if gameState == "paused" then
            UI.drawOverlay("PAUSED", "Press 'P' or ESC to Resume\nPress 'M' or 'Q' to Return to Main Menu", screenW, screenH)
        end

    elseif gameState == "menu" then
        UI.drawMenu(screenW, screenH)
    elseif gameState == "gameover" then
        particleSystem:draw()
        UI.drawGameOver(score, enemyManager.wave, screenW, screenH)
    end

    love.graphics.pop()

    Shaders.endCaptureAndRender()

    -- Draw Shader Toggle Notification Toast (rendered on top of post-processing)
    UI.drawNotification(notificationText, math.min(1, notificationTimer), screenW)
end
