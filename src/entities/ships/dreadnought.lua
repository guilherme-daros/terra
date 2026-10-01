-- dreadnought.lua
-- Navy Dreadnought Spaceship Model

local Colors = require("src.core.colors")

local DreadnoughtShip = {}

function DreadnoughtShip.draw()
    love.graphics.setColor(Colors.get({ 0.15, 0.45, 0.75, 1.0 }))
    love.graphics.polygon("fill", 18, 0, 10, -14, -10, -14, -16, -8, -16, 8, -10, 14, 10, 14)
    love.graphics.setColor(Colors.get({ 0.1, 0.3, 0.55, 1.0 }))
    love.graphics.polygon("fill", 4, -16, -8, -16, -12, -10, 0, -10)
    love.graphics.polygon("fill", 4, 16, -8, 16, -12, 10, 0, 10)
    love.graphics.setColor(Colors.get("playerHullLine"))
    love.graphics.polygon("line", 18, 0, 10, -14, -10, -14, -16, -8, -16, 8, -10, 14, 10, 14)
    love.graphics.setColor(Colors.get("playerCockpit"))
    love.graphics.rectangle("fill", -2, -3, 8, 6, 2)
end

return DreadnoughtShip
