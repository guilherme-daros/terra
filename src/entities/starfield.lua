local Colors = require("src.core.colors")

local Starfield = {}

function Starfield.new(width, height, count)
    local self = {
        width  = width,
        height = height,
        stars  = {}
    }

    for i = 1, count or 120 do
        table.insert(self.stars, {
            x            = math.random(0, width),
            y            = math.random(0, height),
            speed        = math.random(10, 60),
            size         = math.random() < 0.7 and 1 or 2,
            brightness   = math.random(0.3 * 100, 1.0 * 100) / 100,
            twinkleSpeed = math.random(1, 4)
        })
    end

    return setmetatable(self, { __index = Starfield })
end

function Starfield:update(dt)
    for _, star in ipairs(self.stars) do
        star.y = star.y + star.speed * dt
        if star.y > self.height then
            star.y = 0
            star.x = math.random(0, self.width)
        end
        star.brightness = 0.5 + 0.5 * math.sin(love.timer.getTime() * star.twinkleSpeed + star.x)
    end
end

function Starfield:draw()
    for _, star in ipairs(self.stars) do
        love.graphics.setColor(Colors.get("starBase", star.brightness))
        love.graphics.rectangle("fill", star.x, star.y, star.size, star.size)
    end
    love.graphics.setColor(Colors.get("white"))
end

return Starfield
