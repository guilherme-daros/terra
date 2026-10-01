-- strike.lua
-- Twin-Hull Strike Fighter Spaceship Model

local Colors = require("src.core.colors")

local StrikeShip = {}

function StrikeShip.draw()
    love.graphics.setColor(Colors.get({ 0.95, 0.55, 0.15, 1.0 }))
    love.graphics.polygon("fill", 22, -11, 22, -7, -14, -7, -14, -11)
    love.graphics.polygon("fill", 22, 7, 22, 11, -14, 11, -14, 7)
    love.graphics.polygon("fill", 6, -8, -10, -8, -10, 8, 6, 8)
    love.graphics.setColor(Colors.get("playerHullLine"))
    love.graphics.polygon("line", 22, -11, 22, -7, -14, -7, -14, -11)
    love.graphics.polygon("line", 22, 7, 22, 11, -14, 11, -14, 7)
    love.graphics.polygon("line", 6, -8, -10, -8, -10, 8, 6, 8)
    love.graphics.setColor(Colors.get({ 1.0, 0.9, 0.2, 1.0 }))
    love.graphics.circle("fill", -2, 0, 5)
end

return StrikeShip
