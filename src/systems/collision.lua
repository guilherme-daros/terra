-- collision.lua
-- Combat Physics & Collision Detection Engine

local Sound = require("src.core.sound")

local Collision = {}

function Collision.check(player, bulletManager, enemyManager, particleSystem, triggerShake, onScoreGain, onPlayerDie)
    -- 1. Collision: Player Bullets vs Enemies
    for bIdx = #bulletManager.bullets, 1, -1 do
        local b = bulletManager.bullets[bIdx]
        if not b.isEnemy then
            for eIdx = #enemyManager.enemies, 1, -1 do
                local e = enemyManager.enemies[eIdx]
                local dx = b.x - e.x
                local dy = b.y - e.y
                local distSq = dx * dx + dy * dy

                if distSq < (b.radius + e.radius) ^ 2 then
                    b.alive = false
                    e.hp = e.hp - 1
                    particleSystem:spawn(b.x, b.y, 4, b.color, 20, 60, 0.1, 0.3, 2)

                    if e.hp <= 0 then
                        local gainedScore = enemyManager:destroyEnemy(eIdx, particleSystem)
                        triggerShake(5, 0.15)
                        if onScoreGain then onScoreGain(gainedScore) end
                    else
                        Sound.play("hit")
                    end
                    break
                end
            end
        end
    end

    -- 2. Collision: Enemy Bullets vs Player
    for bIdx = #bulletManager.bullets, 1, -1 do
        local b = bulletManager.bullets[bIdx]
        if b.isEnemy then
            local dx = b.x - player.x
            local dy = b.y - player.y
            if dx * dx + dy * dy < (b.radius + player.radius) ^ 2 then
                b.alive = false
                local died = player:takeDamage(20, particleSystem)
                triggerShake(8, 0.25)
                if died and player.lives <= 0 and onPlayerDie then
                    onPlayerDie()
                end
            end
        end
    end

    -- 3. Collision: Enemies vs Player
    for eIdx = #enemyManager.enemies, 1, -1 do
        local e = enemyManager.enemies[eIdx]
        local dx = e.x - player.x
        local dy = e.y - player.y
        if dx * dx + dy * dy < (e.radius + player.radius) ^ 2 then
            local damage = (e.type == "drone" and 25 or e.radius * 0.8)
            local died = player:takeDamage(damage, particleSystem)
            triggerShake(12, 0.35)

            if e.type == "asteroid" and e.sizeType == "small" then
                enemyManager:destroyEnemy(eIdx, particleSystem)
            end

            if died and player.lives <= 0 and onPlayerDie then
                onPlayerDie()
            end
        end
    end
end

return Collision
