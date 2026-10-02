local Colors = require("src.core.colors")

local Bullet = {}

function Bullet.new(x, y, vx, vy, isEnemy, color, radius)
    return {
        x       = x,
        y       = y,
        vx      = vx,
        vy      = vy,
        isEnemy = isEnemy or false,
        color   = color or (isEnemy and Colors.bulletEnemy or Colors.bulletPlayer),
        radius  = radius or (isEnemy and 4 or 3),
        alive   = true
    }
end

local BulletManager = {}

function BulletManager.new()
    local self = {
        bullets = {}
    }
    return setmetatable(self, { __index = BulletManager })
end

function BulletManager:add(x, y, vx, vy, isEnemy, color, radius)
    table.insert(self.bullets, Bullet.new(x, y, vx, vy, isEnemy, color, radius))
end

function BulletManager:update(dt, screenW, screenH)
    local count = #self.bullets
    for i = count, 1, -1 do
        local b = self.bullets[i]
        b.x = b.x + b.vx * dt
        b.y = b.y + b.vy * dt

        -- Out of screen check & O(1) swap-and-pop array removal
        if b.x < -20 or b.x > screenW + 20 or b.y < -20 or b.y > screenH + 20 or not b.alive then
            self.bullets[i] = self.bullets[#self.bullets]
            self.bullets[#self.bullets] = nil
        end
    end
end

function BulletManager:draw()
    if #self.bullets == 0 then return end

    -- Precompute tail vectors for all bullets once
    local tails = {}
    for i, b in ipairs(self.bullets) do
        local speed = math.sqrt(b.vx * b.vx + b.vy * b.vy)
        local dirX, dirY = 1, 0
        if speed > 0 then
            dirX = b.vx / speed
            dirY = b.vy / speed
        end
        local len = b.isEnemy and 12 or 16
        tails[i] = {
            dirX  = dirX,
            dirY  = dirY,
            tailX = b.x - dirX * len,
            tailY = b.y - dirY * len
        }
    end

    -- Pass 1: Outer laser glow pass
    for i, b in ipairs(self.bullets) do
        local t = tails[i]
        love.graphics.setLineWidth(b.isEnemy and 4 or 5)
        love.graphics.setColor(Colors.getRGBA(b.color, 0.35))
        love.graphics.line(t.tailX, t.tailY, b.x, b.y)
    end

    -- Pass 2: Inner bright laser beam pass
    for i, b in ipairs(self.bullets) do
        local t = tails[i]
        love.graphics.setLineWidth(b.isEnemy and 2 or 2.5)
        love.graphics.setColor(Colors.getRGBA(b.color, 0.95))
        love.graphics.line(t.tailX, t.tailY, b.x, b.y)
    end

    -- Pass 3: Core white highlight tip pass
    love.graphics.setLineWidth(1)
    love.graphics.setColor(Colors.getRGBA("white", 0.9))
    for i, b in ipairs(self.bullets) do
        local t = tails[i]
        love.graphics.line(t.tailX + t.dirX * 3, t.tailY + t.dirY * 3, b.x, b.y)
    end

    love.graphics.setLineWidth(1)
    love.graphics.setColor(Colors.getRGBA("white"))
end

function BulletManager:clear()
    self.bullets = {}
end

return BulletManager
