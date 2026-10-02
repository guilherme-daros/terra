local Colors = require("src.core.colors")

local ParticleSystem = {}

function ParticleSystem.new()
    local self = {
        particles = {},
        pool      = {}
    }
    return setmetatable(self, { __index = ParticleSystem })
end

function ParticleSystem:spawn(x, y, count, color, speedMin, speedMax, lifeMin, lifeMax, size)
    for i = 1, count do
        local angle = math.random() * math.pi * 2
        local speed = math.random(speedMin or 20, speedMax or 150)
        local life  = math.random() * ((lifeMax or 0.8) - (lifeMin or 0.3)) + (lifeMin or 0.3)
        
        -- Recycle particle from pool or allocate if pool is empty
        local p = table.remove(self.pool)
        if not p then
            p = {}
        end

        p.x       = x
        p.y       = y
        p.vx      = math.cos(angle) * speed
        p.vy      = math.sin(angle) * speed
        p.color   = color or Colors.powerupSpark
        p.radius  = size or math.random(2, 4)
        p.life    = life
        p.maxLife = life

        table.insert(self.particles, p)
    end
end

function ParticleSystem:update(dt)
    local len = #self.particles
    for i = len, 1, -1 do
        local p = self.particles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.vx = p.vx * 0.96 -- air resistance
        p.vy = p.vy * 0.96
        p.life = p.life - dt

        if p.life <= 0 then
            -- Recycle to object pool
            table.insert(self.pool, p)
            -- O(1) swap-and-pop removal from active array
            self.particles[i] = self.particles[#self.particles]
            self.particles[#self.particles] = nil
        end
    end
end

function ParticleSystem:draw()
    for _, p in ipairs(self.particles) do
        local alpha = p.life / p.maxLife
        love.graphics.setColor(Colors.getRGBA(p.color, alpha))
        local currentRadius = p.radius * alpha
        love.graphics.circle("fill", p.x, p.y, math.max(0.5, currentRadius))
    end
    love.graphics.setColor(Colors.getRGBA("white"))
end

function ParticleSystem:clear()
    for _, p in ipairs(self.particles) do
        table.insert(self.pool, p)
    end
    self.particles = {}
end

return ParticleSystem
