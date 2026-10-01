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
    for i = #self.bullets, 1, -1 do
        local b = self.bullets[i]
        b.x = b.x + b.vx * dt
        b.y = b.y + b.vy * dt

        -- Out of screen check
        if b.x < -20 or b.x > screenW + 20 or b.y < -20 or b.y > screenH + 20 or not b.alive then
            table.remove(self.bullets, i)
        end
    end
end

function BulletManager:draw()
    for _, b in ipairs(self.bullets) do
        local speed = math.sqrt(b.vx * b.vx + b.vy * b.vy)
        local dirX, dirY = 1, 0
        if speed > 0 then
            dirX = b.vx / speed
            dirY = b.vy / speed
        end

        local len = b.isEnemy and 12 or 16
        local tailX = b.x - dirX * len
        local tailY = b.y - dirY * len

        -- Outer laser glow
        love.graphics.setLineWidth(b.isEnemy and 4 or 5)
        love.graphics.setColor(Colors.get(b.color, 0.35))
        love.graphics.line(tailX, tailY, b.x, b.y)

        -- Inner bright laser beam
        love.graphics.setLineWidth(b.isEnemy and 2 or 2.5)
        love.graphics.setColor(Colors.get(b.color, 0.95))
        love.graphics.line(tailX, tailY, b.x, b.y)

        -- Core white highlight tip
        love.graphics.setLineWidth(1)
        love.graphics.setColor(Colors.get("white", 0.9))
        love.graphics.line(tailX + dirX * 3, tailY + dirY * 3, b.x, b.y)
    end

    love.graphics.setLineWidth(1)
    love.graphics.setColor(Colors.get("white"))
end

function BulletManager:clear()
    self.bullets = {}
end

return BulletManager
