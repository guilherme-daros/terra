-- interceptor.lua
-- Delta-Wing Interceptor Spaceship Model

local Colors = require("src.core.colors")

local InterceptorShip = {}

function InterceptorShip.draw()
    love.graphics.setColor(Colors.getRGBA("playerHullFill"))
    love.graphics.polygon("fill", 22, -4, 26, -2, 10, 0, 26, 2, 22, 4, -4, 0)
    love.graphics.polygon("fill", 12, 0, -14, -18, -6, -8, -12, 0, -6, 8, -14, 18)
    love.graphics.setColor(Colors.getRGBA("playerHullLine"))
    love.graphics.polygon("line", 12, 0, -14, -18, -6, -8, -12, 0, -6, 8, -14, 18)
    love.graphics.polygon("line", 22, -4, 26, -2, 10, 0, 26, 2, 22, 4)
    love.graphics.setColor(Colors.getRGBA("playerCockpit"))
    love.graphics.ellipse("fill", 2, 0, 5, 3)
end

return InterceptorShip
