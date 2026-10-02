-- collision.lua
-- Combat Physics & Collision Detection Engine

local hasNative, native = pcall(require, "cosmic_native")
local Sound = require("src.core.sound")

local Collision = {}
local spatialGrid = nil

if hasNative and native.create_spatial_grid then
    spatialGrid = native.create_spatial_grid(64.0)
end

function Collision.check(player, bulletManager, enemyManager, particleSystem, triggerShake, onScoreGain, onPlayerDie)
    -- If native spatial grid is available and entity count warrants spatial hashing:
    if spatialGrid then
        spatialGrid:clear()

        -- Team 0: Player Bullets (ID: 1 .. #bullets)
        -- Team 1: Enemy Bullets  (ID: 10000 .. 10000 + #bullets)
        for bIdx, b in ipairs(bulletManager.bullets) do
            if b.alive then
                if not b.isEnemy then
                    spatialGrid:add_entity(bIdx, b.x, b.y, b.radius, 0)
                else
                    spatialGrid:add_entity(10000 + bIdx, b.x, b.y, b.radius, 1)
                end
            end
        end

        -- Team 2: Enemies (ID: 20000 .. 20000 + #enemies)
        for eIdx, e in ipairs(enemyManager.enemies) do
            spatialGrid:add_entity(20000 + eIdx, e.x, e.y, e.radius, 2)
        end

        -- Team 3: Player Ship (ID: 99999)
        spatialGrid:add_entity(99999, player.x, player.y, player.radius, 3)

        local pairs = spatialGrid:check_collisions()
        for i = 1, #pairs, 2 do
            local idA, idB = pairs[i], pairs[i + 1]

            -- Sort IDs so idA < idB
            if idA > idB then idA, idB = idB, idA end

            -- Case 1: Player Bullet (1..9999) vs Enemy (20000..29999)
            if idA < 10000 and idB >= 20000 and idB < 30000 then
                local bIdx = idA
                local eIdx = idB - 20000
                local b = bulletManager.bullets[bIdx]
                local e = enemyManager.enemies[eIdx]

                if b and b.alive and e and e.hp > 0 then
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
                end

            -- Case 2: Enemy Bullet (10000..19999) vs Player (99999)
            elseif idA >= 10000 and idA < 20000 and idB == 99999 then
                local bIdx = idA - 10000
                local b = bulletManager.bullets[bIdx]

                if b and b.alive then
                    b.alive = false
                    local died = player:takeDamage(20, particleSystem)
                    triggerShake(8, 0.25)
                    if died and player.lives <= 0 and onPlayerDie then
                        onPlayerDie()
                    end
                end

            -- Case 3: Enemy (20000..29999) vs Player (99999)
            elseif idA >= 20000 and idA < 30000 and idB == 99999 then
                local eIdx = idA - 20000
                local e = enemyManager.enemies[eIdx]

                if e then
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
        return
    end

    -- Pure Lua Fallback Path
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
