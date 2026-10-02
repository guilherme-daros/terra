-- colors.lua
-- Centralized Color Palette Configuration for Cosmic Defender

local Colors = {
    -- Base Utilities
    white           = { 1.0, 1.0, 1.0, 1.0 },
    black           = { 0.0, 0.0, 0.0, 1.0 },
    overlayBg       = { 0.0, 0.0, 0.0, 0.68 },

    -- Title Screen & UI Guide Box
    titleText       = { 0.3, 0.85, 1.0, 0.95 },
    menuBoxBg       = { 0.1, 0.15, 0.25, 0.75 },
    menuBoxBorder   = { 0.3, 0.6, 0.9, 0.80 },
    menuTextPrimary = { 1.0, 1.0, 1.0, 0.95 },
    menuTextBody    = { 0.85, 0.9, 1.0, 0.90 },
    menuTextFooter  = { 0.7, 0.8, 0.95, 0.80 },
    menuPrompt      = { 1.0, 0.9, 0.3, 1.00 },
    pauseHeader     = { 1.0, 0.3, 0.4, 0.95 },

    -- HUD Elements
    hpBg            = { 0.15, 0.2, 0.3, 0.80 },
    hpBorder        = { 1.0, 1.0, 1.0, 0.80 },
    heartIcon       = { 1.0, 0.35, 0.4, 0.95 },
    scoreText       = { 1.0, 1.0, 1.0, 0.95 },
    highScoreText   = { 0.7, 0.7, 0.8, 0.75 },
    waveText        = { 0.4, 0.9, 1.0, 0.95 },
    activeTriple    = { 1.0, 0.8, 0.2, 0.95 },
    activeShield    = { 0.3, 0.75, 1.0, 0.95 },

    -- Player Spaceship & Thrusters
    playerHullFill  = { 0.2, 0.8, 1.0, 1.00 },
    playerHullLine  = { 0.9, 0.95, 1.0, 1.00 },
    playerCockpit   = { 1.0, 0.3, 0.5, 1.00 },
    playerShield    = { 0.3, 0.7, 1.0, 0.40 },
    flameOuter      = { 1.0, 0.5, 0.1, 0.90 },
    flameInner      = { 1.0, 0.9, 0.2, 0.90 },

    -- Projectiles (Bullets)
    bulletPlayer    = { 0.3, 0.9, 1.0, 1.00 },
    bulletEnemy     = { 1.0, 0.2, 0.3, 1.00 },

    -- Enemies
    asteroidFill    = { 0.7, 0.7, 0.75, 0.90 },
    asteroidLine    = { 1.0, 1.0, 1.0, 0.80 },
    droneFill       = { 1.0, 0.3, 0.4, 1.00 },
    droneLine       = { 1.0, 1.0, 1.0, 0.90 },
    droneEye        = { 1.0, 1.0, 0.0, 1.00 },

    -- Power-Up Items
    powerupHealth   = { 0.2, 1.0, 0.3, 1.00 },
    powerupTriple   = { 1.0, 0.8, 0.2, 1.00 },
    powerupShield   = { 0.3, 0.7, 1.0, 1.00 },
    powerupIcon     = { 0.1, 0.1, 0.15, 0.95 },

    -- Particle Sparks
    thrusterSpark   = { 1.0, 0.5, 0.1 },
    damageSpark     = { 1.0, 0.2, 0.2 },
    powerupSpark    = { 1.0, 0.8, 0.2 },

    -- Starfield Background
    starBase        = { 0.8, 0.9, 1.0, 1.00 }
}

--- Retrieves RGBA scalar components for the specified color key or table, with optional alpha override.
--- Zero-allocation helper for love.graphics.setColor(Colors.getRGBA(...))
---@param color string|table|nil
---@param alpha number|nil
---@return number, number, number, number
function Colors.getRGBA(color, alpha)
    local c = type(color) == "string" and Colors[color] or color
    c = c or Colors.white
    return c[1], c[2], c[3], alpha or c[4] or 1.0
end

--- Retrieves an RGBA table for the specified color key or table, with optional alpha override.
---@param color string|table|nil
---@param alpha number|nil
---@return table
function Colors.get(color, alpha)
    local c = type(color) == "string" and Colors[color] or color
    c = c or Colors.white

    if alpha then
        return { c[1], c[2], c[3], alpha }
    else
        return { c[1], c[2], c[3], c[4] or 1.0 }
    end
end

--- Helper to calculate dynamic health bar color gradient (Red -> Yellow -> Green) as RGBA scalars
---@param hpPercent number
---@return number, number, number, number
function Colors.getHealthColorRGBA(hpPercent)
    local r = 1.0 - hpPercent
    local g = hpPercent * 0.9
    local b = 0.3
    return r, g, b, 0.9
end

--- Helper to calculate dynamic health bar color gradient (Red -> Yellow -> Green)
---@param hpPercent number
---@return table
function Colors.getHealthColor(hpPercent)
    local r, g, b, a = Colors.getHealthColorRGBA(hpPercent)
    return { r, g, b, a }
end

return Colors
