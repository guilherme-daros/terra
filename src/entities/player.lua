local Sound           = require("src.core.sound")
local Colors          = require("src.core.colors")
local StealthShip     = require("src.entities.ships.stealth")
local DreadnoughtShip = require("src.entities.ships.dreadnought")
local StrikeShip      = require("src.entities.ships.strike")
local InterceptorShip = require("src.entities.ships.interceptor")

local Player = {}

function Player.new(x, y)
    local self = {
        x                    = x,
        y                    = y,
        vx                   = 0,
        vy                   = 0,
        radius               = 16,
        angle                = -math.pi / 2,
        speed                = 650,
        drag                 = 4.5,

        health               = 100,
        maxHealth            = 100,
        lives                = 3,
        invulnerableTimer    = 0,
        invulnerableDuration = 2.0,

        -- Weapon attributes
        shootTimer           = 0,
        fireRate             = 0.15, -- seconds between shots
        weaponType           = "single", -- "single", "double", "triple"
        weaponTimer          = 0,

        -- Visuals
        isAccelerating       = false,
        shipModel            = 1 -- 1: Delta Interceptor, 2: Navy Dreadnought, 3: Twin-Hull Strike, 4: Diamond Stealth
    }
    return setmetatable(self, { __index = Player })
end

function Player:reset(x, y)
    self.x = x
    self.y = y
    self.vx = 0
    self.vy = 0
    self.health = self.maxHealth
    self.invulnerableTimer = self.invulnerableDuration
    self.weaponType = "single"
    self.weaponTimer = 0
end

function Player:update(dt, bulletManager, particleSystem, screenW, screenH)
    -- Handle input for movement
    local moveX = 0
    local moveY = 0

    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then moveY = moveY - 1 end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then moveY = moveY + 1 end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then moveX = moveX - 1 end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then moveX = moveX + 1 end

    -- Normalize diagonal movement speed
    if moveX ~= 0 and moveY ~= 0 then
        moveX = moveX * 0.7071
        moveY = moveY * 0.7071
    end

    self.isAccelerating = (moveX ~= 0 or moveY ~= 0)

    -- Apply movement acceleration
    self.vx = self.vx + moveX * self.speed * dt
    self.vy = self.vy + moveY * self.speed * dt

    -- Apply drag / friction
    self.vx = self.vx * (1 - self.drag * dt)
    self.vy = self.vy * (1 - self.drag * dt)

    -- Update position
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    -- Clamp to screen edges
    if self.x < self.radius then self.x = self.radius; self.vx = 0 end
    if self.x > screenW - self.radius then self.x = screenW - self.radius; self.vx = 0 end
    if self.y < self.radius then self.y = self.radius; self.vy = 0 end
    if self.y > screenH - self.radius then self.y = screenH - self.radius; self.vy = 0 end

    -- Rotate ship towards mouse cursor
    local mx, my = love.mouse.getPosition()
    self.angle = math.atan2(my - self.y, mx - self.x)

    -- Thruster particles when moving
    if self.isAccelerating and math.random() < 0.6 then
        local px = self.x - math.cos(self.angle) * 12
        local py = self.y - math.sin(self.angle) * 12
        particleSystem:spawn(px, py, 1, Colors.thrusterSpark, 40, 100, 0.1, 0.3, 3)
    end

    -- Update timers
    if self.shootTimer > 0 then self.shootTimer = self.shootTimer - dt end
    if self.invulnerableTimer > 0 then self.invulnerableTimer = self.invulnerableTimer - dt end

    if self.weaponTimer > 0 then
        self.weaponTimer = self.weaponTimer - dt
        if self.weaponTimer <= 0 then
            self.weaponType = "single"
        end
    end

    -- Shooting input
    if (love.mouse.isDown(1) or love.keyboard.isDown("space")) and self.shootTimer <= 0 then
        self:shoot(bulletManager)
    end
end

function Player:shoot(bulletManager)
    self.shootTimer = self.fireRate
    local bulletSpeed = 850

    if self.weaponType == "triple" then
        local spread = 0.2
        for _, angleOffset in ipairs({ -spread, 0, spread }) do
            local a = self.angle + angleOffset
            local vx = math.cos(a) * bulletSpeed
            local vy = math.sin(a) * bulletSpeed
            bulletManager:add(self.x, self.y, vx, vy, false, Colors.bulletPlayer)
        end
    else
        local vx = math.cos(self.angle) * bulletSpeed
        local vy = math.sin(self.angle) * bulletSpeed
        bulletManager:add(self.x, self.y, vx, vy, false, Colors.bulletPlayer)
    end

    Sound.play("shoot")
end

function Player:takeDamage(amount, particleSystem)
    if self.invulnerableTimer > 0 then return false end

    self.health = self.health - amount
    self.invulnerableTimer = 0.8 -- Short buffer of invulnerability

    if particleSystem then
        particleSystem:spawn(self.x, self.y, 15, Colors.damageSpark, 50, 150, 0.2, 0.6, 4)
    end

    Sound.play("hit")

    if self.health <= 0 then
        self.lives = self.lives - 1
        if self.lives > 0 then
            self:reset(self.x, self.y)
        end
        return true -- Player died
    end
    return false
end

function Player:applyPowerup(type)
    if type == "health" then
        self.health = math.min(self.maxHealth, self.health + 40)
    elseif type == "triple" then
        self.weaponType = "triple"
        self.weaponTimer = self.weaponTimer + 10.0 -- Stacks +10s duration
    elseif type == "shield" then
        self.invulnerableTimer = self.invulnerableTimer + 6.0 -- Stacks +6s duration
    end
    Sound.play("powerup")
end

function Player:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)

    -- Invulnerability blinking effect
    if self.invulnerableTimer > 0 and math.floor(love.timer.getTime() * 15) % 2 == 0 then
        -- Draw shield bubble when active
        love.graphics.setColor(Colors.getRGBA("playerShield"))
        love.graphics.circle("line", 0, 0, self.radius + 6)
        love.graphics.circle("fill", 0, 0, self.radius + 4)
    end

    -- Thruster flame when accelerating
    if self.isAccelerating then
        love.graphics.setColor(Colors.getRGBA("flameOuter"))
        love.graphics.polygon("fill", -12, -5, -22 - math.random(0, 5), 0, -12, 5)
        love.graphics.setColor(Colors.getRGBA("flameInner"))
        love.graphics.polygon("fill", -12, -3, -17 - math.random(0, 3), 0, -12, 3)
    end

    -- Draw active spaceship model
    self:drawShipModel(self.shipModel)

    love.graphics.pop()
    love.graphics.setColor(Colors.getRGBA("white"))
end

function Player:drawShipModel(model)
    model = model or self.shipModel or 1

    if model == 1 then
        StealthShip.draw()
    elseif model == 2 then
        DreadnoughtShip.draw()
    elseif model == 3 then
        StrikeShip.draw()
    elseif model == 4 then
        InterceptorShip.draw()
    end
end

return Player
