-- shaders.lua
-- Post-Processing Shader Engine for Cosmic Defender (CRT, Chromatic Aberration, Bloom)

local Shaders = {
    enabled = true,
    crtEnabled = true,
    bloomEnabled = true,
    chromaticEnabled = true,
    chromaticAmount = 0.0
}

function Shaders.init(screenW, screenH)
    Shaders.screenW = screenW
    Shaders.screenH = screenH

    local status, err = pcall(function()
        Shaders.crtShader = love.graphics.newShader("assets/shaders/crt.glsl")
        Shaders.chromaticShader = love.graphics.newShader("assets/shaders/chromatic.glsl")
        Shaders.bloomShader = love.graphics.newShader("assets/shaders/bloom.glsl")

        Shaders.mainCanvas = love.graphics.newCanvas(screenW, screenH)
        Shaders.tempCanvas = love.graphics.newCanvas(screenW, screenH)

        if Shaders.crtShader:hasUniform("screen_size") then
            Shaders.crtShader:send("screen_size", { screenW, screenH })
        end
        if Shaders.bloomShader:hasUniform("screen_size") then
            Shaders.bloomShader:send("screen_size", { screenW, screenH })
        end
    end)

    if not status then
        print("[Shader Warning] Post-processing shaders disabled: " .. tostring(err))
        Shaders.enabled = false
    end
end

function Shaders.triggerChromatic(amount)
    Shaders.chromaticAmount = math.max(Shaders.chromaticAmount, amount or 0.03)
end

function Shaders.update(dt)
    if not Shaders.enabled then return end

    if Shaders.chromaticAmount > 0 then
        Shaders.chromaticAmount = math.max(0, Shaders.chromaticAmount - dt * 0.15)
    end

    if Shaders.crtShader and Shaders.crtShader:hasUniform("time") then
        Shaders.crtShader:send("time", love.timer.getTime())
    end
end

function Shaders.startCapture()
    if not Shaders.enabled or not Shaders.mainCanvas then return end
    love.graphics.setCanvas(Shaders.mainCanvas)
    love.graphics.clear(0, 0, 0, 1)
end

function Shaders.endCaptureAndRender()
    if not Shaders.enabled or not Shaders.mainCanvas then return end

    local currentInput = Shaders.mainCanvas

    -- Pass 1: Bloom Glow Effect
    if Shaders.bloomEnabled and Shaders.bloomShader then
        love.graphics.setCanvas(Shaders.tempCanvas)
        love.graphics.clear(0, 0, 0, 1)
        love.graphics.setShader(Shaders.bloomShader)
        love.graphics.draw(currentInput, 0, 0)
        currentInput = Shaders.tempCanvas
    end

    -- Pass 2: Chromatic Aberration Effect
    if Shaders.chromaticEnabled and Shaders.chromaticAmount > 0.0005 and Shaders.chromaticShader then
        local target = (currentInput == Shaders.mainCanvas) and Shaders.tempCanvas or Shaders.mainCanvas
        love.graphics.setCanvas(target)
        love.graphics.clear(0, 0, 0, 1)
        Shaders.chromaticShader:send("amount", Shaders.chromaticAmount)
        love.graphics.setShader(Shaders.chromaticShader)
        love.graphics.draw(currentInput, 0, 0)
        currentInput = target
    end

    -- Pass 3: CRT Scanlines & Curvature (Final draw to screen)
    love.graphics.setCanvas()
    love.graphics.clear(0, 0, 0, 1)

    if Shaders.crtEnabled and Shaders.crtShader then
        love.graphics.setShader(Shaders.crtShader)
    else
        love.graphics.setShader()
    end

    love.graphics.draw(currentInput, 0, 0)
    love.graphics.setShader()
end

return Shaders
