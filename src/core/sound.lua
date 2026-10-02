local hasNative, native = pcall(require, "cosmic_native")

local Sound = {}
Sound.enabled = true

function Sound.init()
    local status, err = pcall(function()
        Sound.sounds = {
            shoot      = Sound.generateLaser(600, 150, 0.12),
            enemyShoot = Sound.generateLaser(220, 90, 0.15),
            explosion  = Sound.generateNoise(0.35),
            hit        = Sound.generateTone(250, 100, 0.08, "square"),
            powerup    = Sound.generateArpeggio({ 400, 550, 700, 950 }, 0.25),
            gameover   = Sound.generateTone(300, 60, 0.6, "saw")
        }
    end)
    if not status then
        print("[Sound] Procedural sound notice: " .. tostring(err))
        Sound.enabled = false
    end
end

function Sound.play(name)
    if not Sound.enabled or not Sound.sounds or not Sound.sounds[name] then
        return
    end
    pcall(function()
        local s = Sound.sounds[name]:clone()
        s:setVolume(0.4)
        s:play()
    end)
end

function Sound.generateLaser(startFreq, endFreq, duration)
    local sampleRate = 44100
    local samplesCount = math.floor(sampleRate * duration)
    local soundData = love.sound.newSoundData(samplesCount, sampleRate, 16, 1)

    if hasNative and native.generate_laser then
        local rawBuf = native.generate_laser(startFreq, endFreq, duration, sampleRate)
        for i = 0, #rawBuf - 1 do
            soundData:setSample(i, rawBuf[i + 1])
        end
    else
        for i = 0, samplesCount - 1 do
            local progress = i / samplesCount
            local freq = startFreq + (endFreq - startFreq) * progress
            local phase = 2 * math.pi * freq * (i / sampleRate)
            local val = math.sin(phase) * (1 - progress) * 0.4
            soundData:setSample(i, val)
        end
    end

    return love.audio.newSource(soundData, "static")
end

function Sound.generateNoise(duration)
    local sampleRate = 44100
    local samplesCount = math.floor(sampleRate * duration)
    local soundData = love.sound.newSoundData(samplesCount, sampleRate, 16, 1)

    if hasNative and native.generate_noise then
        local rawBuf = native.generate_noise(duration, sampleRate)
        for i = 0, #rawBuf - 1 do
            soundData:setSample(i, rawBuf[i + 1])
        end
    else
        for i = 0, samplesCount - 1 do
            local progress = i / samplesCount
            local envelope = (1 - progress) ^ 2
            local val = (math.random() * 2 - 1) * envelope * 0.4
            soundData:setSample(i, val)
        end
    end

    return love.audio.newSource(soundData, "static")
end

function Sound.generateTone(startFreq, endFreq, duration, waveType)
    local sampleRate = 44100
    local samplesCount = math.floor(sampleRate * duration)
    local soundData = love.sound.newSoundData(samplesCount, sampleRate, 16, 1)

    if hasNative and native.generate_tone then
        local rawBuf = native.generate_tone(startFreq, endFreq, duration, waveType or "sine", sampleRate)
        for i = 0, #rawBuf - 1 do
            soundData:setSample(i, rawBuf[i + 1])
        end
    else
        for i = 0, samplesCount - 1 do
            local progress = i / samplesCount
            local currentFreq = startFreq + (endFreq - startFreq) * progress
            local t = i / sampleRate
            local val = 0
            if waveType == "square" then
                val = math.sin(2 * math.pi * currentFreq * t) >= 0 and 0.3 or -0.3
            elseif waveType == "saw" then
                val = (2 * (t * currentFreq - math.floor(0.5 + t * currentFreq))) * 0.3
            else
                val = math.sin(2 * math.pi * currentFreq * t) * 0.3
            end
            val = val * (1 - progress)
            soundData:setSample(i, val)
        end
    end

    return love.audio.newSource(soundData, "static")
end

function Sound.generateArpeggio(notes, totalDuration)
    local sampleRate = 44100
    local samplesCount = math.floor(sampleRate * totalDuration)
    local soundData = love.sound.newSoundData(samplesCount, sampleRate, 16, 1)

    if hasNative and native.generate_arpeggio then
        local rawBuf = native.generate_arpeggio(notes, totalDuration, sampleRate)
        for i = 0, #rawBuf - 1 do
            soundData:setSample(i, rawBuf[i + 1])
        end
    else
        local noteDuration = totalDuration / #notes
        for i = 0, samplesCount - 1 do
            local t = i / sampleRate
            local noteIdx = math.min(#notes, math.floor(t / noteDuration) + 1)
            local freq = notes[noteIdx]
            local progress = i / samplesCount
            local val = math.sin(2 * math.pi * freq * t) * (1 - progress) * 0.3
            soundData:setSample(i, val)
        end
    end

    return love.audio.newSource(soundData, "static")
end

return Sound
