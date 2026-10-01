-- ui.lua
-- User Interface and HUD Renderer for Cosmic Defender

local Colors = require("src.core.colors")
local Fonts = require("src.core.fonts")

local UI = {}

function UI.drawHUD(player, enemyManager, score, highScore, screenW)
    -- Health Bar Container
    love.graphics.setColor(Colors.get("hpBg"))
    love.graphics.rectangle("fill", 20, 20, 150, 16, 4)
    local hpPercent = math.max(0, player.health / player.maxHealth)

    love.graphics.setColor(Colors.getHealthColor(hpPercent))
    love.graphics.rectangle("fill", 20, 20, 150 * hpPercent, 16, 4)

    love.graphics.setColor(Colors.get("hpBorder"))
    love.graphics.rectangle("line", 20, 20, 150, 16, 4)

    -- Lives (Nerd Font Heart icons)
    love.graphics.setFont(Fonts.regular)
    for i = 1, player.lives do
        love.graphics.setColor(Colors.get("heartIcon"))
        love.graphics.print(Fonts.icons.heart, 20 + (i - 1) * 20, 42)
    end

    -- Score & High Score
    love.graphics.setFont(Fonts.bold)
    love.graphics.setColor(Colors.get("scoreText"))
    love.graphics.printf(string.format("SCORE: %06d", score), 0, 18, screenW, "center")

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(Colors.get("highScoreText"))
    love.graphics.printf(string.format("HIGH: %06d", highScore), 0, 38, screenW, "center")

    -- Wave Number
    love.graphics.setFont(Fonts.bold)
    love.graphics.setColor(Colors.get("waveText"))
    love.graphics.printf(Fonts.icons.rocket .. " WAVE " .. enemyManager.wave, screenW - 160, 18, 140, "right")

    -- Active Powerup Indicators
    love.graphics.setFont(Fonts.medium)
    local activeY = 40
    if player.weaponTimer > 0 then
        love.graphics.setColor(Colors.get("activeTriple"))
        local weaponText = Fonts.icons.triple .. " " .. string.upper(player.weaponType) .. " (" .. math.ceil(player.weaponTimer) .. "s)"
        love.graphics.printf(weaponText, screenW - 240, activeY, 220, "right")
        activeY = activeY + 20
    end
    if player.invulnerableTimer > 0 then
        love.graphics.setColor(Colors.get("activeShield"))
        local shieldText = Fonts.icons.shield .. " SHIELD (" .. math.ceil(player.invulnerableTimer) .. "s)"
        love.graphics.printf(shieldText, screenW - 240, activeY, 220, "right")
    end
end

function UI.drawMenu(screenW, screenH)
    -- Title Header
    local pulse = 1 + 0.04 * math.sin(love.timer.getTime() * 4)

    love.graphics.push()
    love.graphics.translate(screenW / 2, 175)
    love.graphics.scale(pulse, pulse)
    love.graphics.setFont(Fonts.title)
    love.graphics.setColor(Colors.get("titleText"))
    love.graphics.printf(Fonts.icons.rocket .. " COSMIC DEFENDER " .. Fonts.icons.rocket, -screenW / 2, -20, screenW, "center")
    love.graphics.pop()

    -- Controls & Powerups Guide Box
    local boxWidth = 520
    local boxHeight = 220
    local boxX = (screenW - boxWidth) / 2
    local boxY = 225

    love.graphics.setColor(Colors.get("menuBoxBg"))
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight, 8)
    love.graphics.setColor(Colors.get("menuBoxBorder"))
    love.graphics.rectangle("line", boxX, boxY, boxWidth, boxHeight, 8)

    love.graphics.setFont(Fonts.bold)
    love.graphics.setColor(Colors.get("menuTextPrimary"))
    love.graphics.printf("CONTROLS & POWER-UPS", 0, boxY + 10, screenW, "center")

    -- 3 Left-Aligned Columns for Controls
    local col1X = boxX + 24  -- Left column (Input key/icon)
    local col2X = boxX + 215 -- Middle column (Colon)
    local col3X = boxX + 235 -- Right column (Action description)
    local startY = boxY + 34
    local lineHeight = 21

    local controlRows = {
        { Fonts.icons.keyboard .. "  WASD / Arrows", ":", "Move Spaceship" },
        { Fonts.icons.mouse .. "  Mouse Cursor",    ":", "Aim Plasma Cannon" },
        { Fonts.icons.laser .. "  Space / Click",    ":", "Fire Lasers" },
        { Fonts.icons.chip .. "  F1 / F2 / F3",      ":", "Toggle CRT / Bloom / Chromatic" },
        { Fonts.icons.pause .. "  P / ESC",          ":", "Pause Game" },
        { Fonts.icons.quit .. "  Q / ESC",           ":", "Quit Game (from Title)" }
    }

    love.graphics.setFont(Fonts.medium)
    love.graphics.setColor(Colors.get("menuTextBody"))

    for i, row in ipairs(controlRows) do
        local ry = startY + (i - 1) * lineHeight
        love.graphics.print(row[1], col1X, ry)
        love.graphics.print(row[2], col2X, ry)
        love.graphics.print(row[3], col3X, ry)
    end

    -- Bottom Power-ups Summary Line
    love.graphics.setColor(Colors.get("menuTextFooter"))
    love.graphics.printf(Fonts.icons.heart .. " Health    " .. Fonts.icons.triple .. " Triple Shot    " .. Fonts.icons.shield .. " Energy Shield", 0, boxY + 188, screenW, "center")

    -- Start / Quit Prompt
    local blink = math.floor(love.timer.getTime() * 2) % 2 == 0
    if blink then
        love.graphics.setFont(Fonts.bold)
        love.graphics.setColor(Colors.get("menuPrompt"))
        love.graphics.printf("PRESS SPACE / ENTER TO START  •  PRESS Q / ESC TO QUIT", 0, 475, screenW, "center")
    end
end

function UI.drawNotification(text, opacity, screenW)
    if not text or opacity <= 0 then return end
    love.graphics.setFont(Fonts.medium)
    love.graphics.setColor(Colors.get("menuBoxBg", opacity * 0.9))
    love.graphics.rectangle("fill", screenW / 2 - 170, 18, 340, 32, 6)
    love.graphics.setColor(Colors.get("menuBoxBorder", opacity))
    love.graphics.rectangle("line", screenW / 2 - 170, 18, 340, 32, 6)
    love.graphics.setColor(Colors.get("white", opacity))
    love.graphics.printf(text, 0, 24, screenW, "center")
end

function UI.drawGameOver(score, wave, screenW, screenH)
    UI.drawOverlay("GAME OVER", "Final Score: " .. score .. "  |  Wave Reached: " .. wave .. "\n\nPress SPACE or Click to Play Again\nPress 'M' or 'Q' for Main Menu", screenW, screenH)
end

function UI.drawOverlay(title, subtitle, screenW, screenH)
    love.graphics.setColor(Colors.get("overlayBg"))
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    love.graphics.setFont(Fonts.large)
    love.graphics.setColor(Colors.get("pauseHeader"))
    love.graphics.printf(title, 0, screenH / 2 - 50, screenW, "center")

    love.graphics.setFont(Fonts.regular)
    love.graphics.setColor(Colors.get("menuTextPrimary", 0.9))
    love.graphics.printf(subtitle, 0, screenH / 2 + 10, screenW, "center")
end

function UI.drawWaveBanner(enemyManager, screenW, screenH)
    if not enemyManager.waveBannerTimer or enemyManager.waveBannerTimer <= 0 then
        return
    end

    local duration = 2.2
    local timer = enemyManager.waveBannerTimer
    local progress = 1 - (timer / duration)

    local alpha = 1.0
    if progress < 0.2 then
        alpha = progress / 0.2
    elseif progress > 0.7 then
        alpha = (1.0 - progress) / 0.3
    end
    alpha = math.max(0, math.min(1, alpha))

    local scale = 1.0 + 0.12 * math.sin(progress * math.pi)
    local text = enemyManager.waveBannerText or ("WAVE " .. enemyManager.wave)

    love.graphics.push()
    love.graphics.translate(screenW / 2, screenH / 2 - 20)
    love.graphics.scale(scale, scale)

    -- Background overlay banner
    love.graphics.setColor(Colors.get("menuBoxBg", alpha * 0.85))
    love.graphics.rectangle("fill", -screenW / 2, -45, screenW, 90)

    -- Glowing top & bottom border lines
    love.graphics.setColor(Colors.get("titleText", alpha * 0.9))
    love.graphics.rectangle("fill", -screenW / 2, -45, screenW, 2)
    love.graphics.rectangle("fill", -screenW / 2, 43, screenW, 2)

    -- Drop shadow for text
    love.graphics.setFont(Fonts.title)
    love.graphics.setColor(Colors.get("black", alpha * 0.9))
    love.graphics.printf(text, -screenW / 2 + 2, -33, screenW, "center")

    -- Main title text
    love.graphics.setColor(Colors.get("titleText", alpha))
    love.graphics.printf(text, -screenW / 2, -35, screenW, "center")

    -- Subtitle prompt
    love.graphics.setFont(Fonts.bold)
    love.graphics.setColor(Colors.get("menuPrompt", alpha))
    love.graphics.printf("PREPARE FOR BATTLE!", -screenW / 2, 12, screenW, "center")

    love.graphics.pop()
end

return UI
