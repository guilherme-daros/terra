local Sound = require("src.core.sound")
local Colors = require("src.core.colors")

local Enemy = {}

local EnemyManager = {}
EnemyManager.iconCache = {}

function EnemyManager.preloadIcons(font, iconList)
    iconList = iconList or { "", "󱐋", "" }
    local canvasSize = 40
    local origin = 10
    local canvas = love.graphics.newCanvas(canvasSize, canvasSize)

    love.graphics.push("all")

    for _, icon in ipairs(iconList) do
        if not EnemyManager.iconCache[icon] then
            -- 1. Bind canvas & render icon
            love.graphics.setCanvas(canvas)
            love.graphics.clear(0, 0, 0, 0)
            love.graphics.setFont(font)
            love.graphics.setColor(Colors.getRGBA("white"))
            love.graphics.print(icon, origin, origin)

            -- 2. Unbind canvas BEFORE calling newImageData()
            love.graphics.setCanvas()

            -- 3. Read image pixel data safely
            local imgData = canvas:newImageData()
            local minX, minY, maxX, maxY = canvasSize, canvasSize, 0, 0

            for y = 0, canvasSize - 1 do
                for x = 0, canvasSize - 1 do
                    local _, _, _, a = imgData:getPixel(x, y)
                    if a > 0.1 then
                        if x < minX then minX = x end
                        if x > maxX then maxX = x end
                        if y < minY then minY = y end
                        if y > maxY then maxY = y end
                    end
                end
            end

            local dx, dy = 0, 0
            if maxX >= minX and maxY >= minY then
                dx = (minX + maxX) / 2 - origin
                dy = (minY + maxY) / 2 - origin
            end

            EnemyManager.iconCache[icon] = { dx = dx, dy = dy }
        end
    end

    love.graphics.pop()
end

function EnemyManager.getIconOffset(font, text)
    if not EnemyManager.iconCache[text] then
        EnemyManager.preloadIcons(font, { text })
    end
    local offset = EnemyManager.iconCache[text]
    return (offset and offset.dx or 4), (offset and offset.dy or 9.5)
end

-- Generate procedurally jagged asteroid polygon vertices
local function generateAsteroidShape(radius, pointsCount)
    local points = {}
    local step = (math.pi * 2) / pointsCount
    for i = 1, pointsCount do
        local angle = (i - 1) * step
        local offset = radius * (0.75 + math.random() * 0.4)
        table.insert(points, math.cos(angle) * offset)
        table.insert(points, math.sin(angle) * offset)
    end
    return points
end

function Enemy.newAsteroid(x, y, sizeType)
    sizeType = sizeType or "large" -- "large", "medium", "small"

    local radius = 32
    local hp = 3
    local scoreValue = 100
    local speed = math.random(40, 90)

    if sizeType == "medium" then
        radius = 20
        hp = 2
        scoreValue = 50
        speed = math.random(80, 140)
    elseif sizeType == "small" then
        radius = 12
        hp = 1
        scoreValue = 25
        speed = math.random(130, 220)
    end

    local angle = math.random() * math.pi * 2
    local rotSpeed = (math.random() - 0.5) * 2.5

    return {
        type       = "asteroid",
        sizeType   = sizeType,
        x          = x,
        y          = y,
        vx         = math.cos(angle) * speed,
        vy         = math.sin(angle) * speed,
        radius     = radius,
        hp         = hp,
        maxHp      = hp,
        scoreValue = scoreValue,
        rotation   = math.random() * math.pi * 2,
        rotSpeed   = rotSpeed,
        vertices   = generateAsteroidShape(radius, 8),
        color      = Colors.asteroidFill
    }
end

function Enemy.newDrone(x, y)
    return {
        type       = "drone",
        x          = x,
        y          = y,
        vx         = 0,
        vy         = 0,
        radius     = 14,
        hp         = 4,
        maxHp      = 4,
        scoreValue = 250,
        speed      = 120,
        shootTimer = math.random() * 2.0 + 1.0,
        rotation   = 0,
        color      = Colors.droneFill
    }
end

local Powerup = {}
function Powerup.new(x, y, type)
    local types = { "health", "triple", "shield" }
    type = type or types[math.random(#types)]

    local color = Colors.powerupHealth
    if type == "triple" then color = Colors.powerupTriple end
    if type == "shield" then color = Colors.powerupShield end

    return {
        x      = x,
        y      = y,
        vy     = 30,
        type   = type,
        radius = 12,
        color  = color,
        life   = 12.0 -- Despawns after 12s
    }
end

function EnemyManager.new(screenW, screenH)
    local self = {
        screenW         = screenW,
        screenH         = screenH,
        enemies         = {},
        powerups        = {},
        wave            = 1,
        waveState       = "active", -- "active", "cleared", "spawning"
        spawnTimer      = 0,
        waveBannerTimer = 0,
        waveBannerText  = ""
    }
    return setmetatable(self, { __index = EnemyManager })
end

function EnemyManager:startWave(waveNum)
    self.wave = waveNum
    self.enemies = {}
    self.waveBannerTimer = 2.2
    self.waveBannerText = "WAVE " .. waveNum
    Sound.play("powerup")

    local count = 3 + waveNum * 2
    for i = 1, count do
        -- Spawn along outer screen edges
        local x, y
        if math.random() < 0.5 then
            x = math.random() < 0.5 and -30 or (self.screenW + 30)
            y = math.random(0, self.screenH)
        else
            x = math.random(0, self.screenW)
            y = math.random() < 0.5 and -30 or (self.screenH + 30)
        end
        table.insert(self.enemies, Enemy.newAsteroid(x, y, "large"))
    end

    -- Add hunter drones starting at wave 2
    if waveNum >= 2 then
        local droneCount = math.min(5, math.floor(waveNum / 2))
        for i = 1, droneCount do
            local x = math.random(50, self.screenW - 50)
            local y = -40
            table.insert(self.enemies, Enemy.newDrone(x, y))
        end
    end

    self.waveState = "active"
end

function EnemyManager:update(dt, player, bulletManager, particleSystem)
    if self.waveBannerTimer and self.waveBannerTimer > 0 then
        self.waveBannerTimer = self.waveBannerTimer - dt
    end
    -- Update Enemies
    for i = #self.enemies, 1, -1 do
        local e = self.enemies[i]

        if e.type == "asteroid" then
            e.x = e.x + e.vx * dt
            e.y = e.y + e.vy * dt
            e.rotation = e.rotation + e.rotSpeed * dt

            -- Screen wrap for asteroids
            if e.x < -e.radius then e.x = self.screenW + e.radius end
            if e.x > self.screenW + e.radius then e.x = -e.radius end
            if e.y < -e.radius then e.y = self.screenH + e.radius end
            if e.y > self.screenH + e.radius then e.y = -e.radius end

        elseif e.type == "drone" then
            -- Drone AI: follow player & stay at medium distance
            local dx = player.x - e.x
            local dy = player.y - e.y
            local dist = math.sqrt(dx * dx + dy * dy)
            e.rotation = math.atan2(dy, dx)

            if dist > 0 then
                local targetVx = (dx / dist) * e.speed
                local targetVy = (dy / dist) * e.speed
                e.vx = e.vx + (targetVx - e.vx) * 2.0 * dt
                e.vy = e.vy + (targetVy - e.vy) * 2.0 * dt
            end

            e.x = e.x + e.vx * dt
            e.y = e.y + e.vy * dt

            -- Drone shooting
            e.shootTimer = e.shootTimer - dt
            if e.shootTimer <= 0 then
                e.shootTimer = 2.5
                local bulletSpeed = 350
                local bvx = math.cos(e.rotation) * bulletSpeed
                local bvy = math.sin(e.rotation) * bulletSpeed
                bulletManager:add(e.x, e.y, bvx, bvy, true, Colors.bulletEnemy, 4)
                Sound.play("enemyShoot")
            end
        end
    end

    -- Update Powerups
    for i = #self.powerups, 1, -1 do
        local p = self.powerups[i]
        p.y = p.y + p.vy * dt
        p.life = p.life - dt

        -- Check collision with player
        local dx = player.x - p.x
        local dy = player.y - p.y
        if dx * dx + dy * dy < (player.radius + p.radius) ^ 2 then
            player:applyPowerup(p.type)
            particleSystem:spawn(p.x, p.y, 10, p.color, 30, 80, 0.2, 0.5, 3)
            table.remove(self.powerups, i)
        elseif p.life <= 0 or p.y > self.screenH + 30 then
            table.remove(self.powerups, i)
        end
    end

    -- Check if wave cleared
    if #self.enemies == 0 and self.waveState == "active" then
        self.waveState = "cleared"
        self.spawnTimer = 2.0 -- 2 second transition to next wave
    end

    if self.waveState == "cleared" then
        self.spawnTimer = self.spawnTimer - dt
        if self.spawnTimer <= 0 then
            self:startWave(self.wave + 1)
        end
    end
end

function EnemyManager:destroyEnemy(index, particleSystem)
    local e = self.enemies[index]
    if not e then return 0 end

    Sound.play("explosion")
    particleSystem:spawn(e.x, e.y, e.type == "drone" and 25 or 15, e.color, 40, 180, 0.3, 0.8, 3)

    -- Powerup drop chance (15%)
    if math.random() < 0.15 then
        table.insert(self.powerups, Powerup.new(e.x, e.y))
    end

    -- Split asteroids
    if e.type == "asteroid" then
        if e.sizeType == "large" then
            table.insert(self.enemies, Enemy.newAsteroid(e.x, e.y, "medium"))
            table.insert(self.enemies, Enemy.newAsteroid(e.x, e.y, "medium"))
        elseif e.sizeType == "medium" then
            table.insert(self.enemies, Enemy.newAsteroid(e.x, e.y, "small"))
            table.insert(self.enemies, Enemy.newAsteroid(e.x, e.y, "small"))
        end
    end

    local score = e.scoreValue
    table.remove(self.enemies, index)
    return score
end

function EnemyManager:draw(fonts)
    -- Draw Enemies
    for _, e in ipairs(self.enemies) do
        love.graphics.push()
        love.graphics.translate(e.x, e.y)
        love.graphics.rotate(e.rotation)

        if e.type == "asteroid" then
            love.graphics.setColor(Colors.getRGBA(e.color, 0.9))
            love.graphics.polygon("fill", e.vertices)
            love.graphics.setColor(Colors.getRGBA("asteroidLine"))
            love.graphics.polygon("line", e.vertices)
        elseif e.type == "drone" then
            love.graphics.setColor(Colors.getRGBA(e.color))
            love.graphics.polygon("fill", 14, 0, -10, -10, -4, 0, -10, 10)
            love.graphics.setColor(Colors.getRGBA("droneLine"))
            love.graphics.polygon("line", 14, 0, -10, -10, -4, 0, -10, 10)
            love.graphics.setColor(Colors.getRGBA("droneEye"))
            love.graphics.circle("fill", 2, 0, 3)
        end

        love.graphics.pop()
    end

    -- Draw Powerups with Generic Pre-Calculated Icon Offsets
    for _, p in ipairs(self.powerups) do
        local pulse = 1 + 0.15 * math.sin(love.timer.getTime() * 8)
        local r = p.radius * pulse
        love.graphics.setColor(Colors.getRGBA(p.color, 0.9))
        love.graphics.circle("fill", p.x, p.y, r)
        love.graphics.setColor(Colors.getRGBA("white", 0.9))
        love.graphics.circle("line", p.x, p.y, r)

        local font = (fonts and fonts.medium) or love.graphics.getFont()
        local icon = ""
        if p.type == "triple" then icon = "󱐋" end
        if p.type == "shield" then icon = "" end

        -- Retrieve preloaded visual center offset
        local dx, dy = EnemyManager.getIconOffset(font, icon)

        love.graphics.setFont(font)
        love.graphics.setColor(Colors.getRGBA("powerupIcon"))
        love.graphics.print(icon, math.floor(p.x - dx), math.floor(p.y - dy))
    end

    love.graphics.setColor(Colors.getRGBA("white"))
end

function EnemyManager:clear()
    self.enemies = {}
    self.powerups = {}
end

return EnemyManager
