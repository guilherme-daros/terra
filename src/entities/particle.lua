local Colors = require("src.core.colors")

local ParticleSystem = {}

function ParticleSystem.new()
    local self = {
        particles = {}
    }
    return setmetatable(self, { __index = ParticleSystem })
end

function ParticleSystem:spawn(x, y, count, color, speedMin, speedMax, lifeMin, lifeMax, size)
    for i = 1, count do
        local angle = math.random() * math.pi * 2
        local speed = math.random(speedMin or 20, speedMax or 150)
        local life = math.random() * ((lifeMax or 0.8) - (lifeMin or 0.3)) + (lifeMin or 0.3)
        table.insert(self.particles, {
            x       = x,
            y       = y,
            vx      = math.cos(angle) * speed,
            vy      = math.sin(angle) * speed,
            color   = color or Colors.powerupSpark,
            radius  = size or math.random(2, 4),
            life    = life,
            maxLife = life
        })
    end
end

function ParticleSystem:update(dt)
    for i = #self.particles, 1, -1 do
        local p = self.particles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.vx = p.vx * 0.96 -- air resistance
        p.vy = p.vy * 0.96
        p.life = p.life - dt
        if p.life <= 0 then
            table.remove(self.particles, i)
        end
    end
end

function ParticleSystem:draw()
    for _, p in ipairs(self.particles) do
        local alpha = p.life / p.maxLife
        love.graphics.setColor(Colors.get(p.color, alpha))
        local currentRadius = p.radius * alpha
        love.graphics.circle("fill", p.x, p.y, math.max(0.5, currentRadius))
    end
    love.graphics.setColor(Colors.get("white"))
end

function ParticleSystem:clear()
    self.particles = {}
end

return ParticleSystem
