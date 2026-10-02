local hasNative, native = pcall(require, "cosmic_native")
local hasFFI, ffi       = pcall(require, "ffi")
local Colors            = require("src.core.colors")

local Starfield = {}

function Starfield.new(width, height, count)
    count = count or 120
    local self = {
        width  = width,
        height = height,
        stars  = {}
    }

    if hasNative and native.create_starfield then
        self.nativeEngine = native.create_starfield(width, height, count)
    else
        for i = 1, count do
            table.insert(self.stars, {
                x            = math.random(0, width),
                y            = math.random(0, height),
                speed        = math.random(10, 60),
                size         = math.random() < 0.7 and 1 or 2,
                brightness   = math.random(0.3 * 100, 1.0 * 100) / 100,
                twinkleSpeed = math.random(1, 4)
            })
        end
    end

    return setmetatable(self, { __index = Starfield })
end

function Starfield:update(dt)
    if self.nativeEngine then
        self.nativeEngine:update(dt, love.timer.getTime())
    else
        for _, star in ipairs(self.stars) do
            star.y = star.y + star.speed * dt
            if star.y > self.height then
                star.y = 0
                star.x = math.random(0, self.width)
            end
            star.brightness = 0.5 + 0.5 * math.sin(love.timer.getTime() * star.twinkleSpeed + star.x)
        end
    end
end

function Starfield:draw()
    if self.nativeEngine then
        if hasFFI and self.nativeEngine.get_raw_bytes and self.nativeEngine.get_star_count then
            local rawBytes = self.nativeEngine:get_raw_bytes()
            local count = self.nativeEngine:get_star_count()
            local floatPtr = ffi.cast("const float*", rawBytes)
            for i = 0, count - 1 do
                local offset = i * 4
                local x = floatPtr[offset]
                local y = floatPtr[offset + 1]
                local sz = floatPtr[offset + 2]
                local br = floatPtr[offset + 3]
                love.graphics.setColor(Colors.getRGBA("starBase", br))
                love.graphics.rectangle("fill", x, y, sz, sz)
            end
        else
            local buf = self.nativeEngine:get_buffer()
            for i = 1, #buf, 4 do
                local x, y, sz, br = buf[i], buf[i + 1], buf[i + 2], buf[i + 3]
                love.graphics.setColor(Colors.getRGBA("starBase", br))
                love.graphics.rectangle("fill", x, y, sz, sz)
            end
        end
    else
        for _, star in ipairs(self.stars) do
            love.graphics.setColor(Colors.getRGBA("starBase", star.brightness))
            love.graphics.rectangle("fill", star.x, star.y, star.size, star.size)
        end
    end
    love.graphics.setColor(Colors.getRGBA("white"))
end

return Starfield
