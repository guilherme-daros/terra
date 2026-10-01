-- stealth.lua
-- Diamond Stealth Wing Spaceship Model

local Colors = require("src.core.colors")

local StealthShip = {}

function StealthShip.draw()
    love.graphics.setColor(Colors.get({ 0.18, 0.22, 0.28, 1.0 }))
    love.graphics.polygon("fill", 22, 0, -4, -18, -16, -10, -8, 0, -16, 10, -4, 18)
    love.graphics.setColor(Colors.get({ 0.3, 0.95, 1.0, 1.0 }))
    love.graphics.polygon("line", 22, 0, -4, -18, -16, -10, -8, 0, -16, 10, -4, 18)
    love.graphics.line(22, 0, -8, 0)
    love.graphics.line(8, -8, -4, -18)
    love.graphics.line(8, 8, -4, 18)
end

return StealthShip
