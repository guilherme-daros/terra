function love.conf(t)
    t.identity = "cosmic_defender"
    t.title = "Cosmic Defender - LÖVE2D Example"
    t.author = "Antigravity"
    t.version = "11.4"

    t.window.width = 800
    t.window.height = 600
    t.window.resizable = false
    t.window.vsync = 1
    t.window.msaa = 4

    t.modules.audio = true
    t.modules.sound = true
    t.modules.graphics = true
    t.modules.keyboard = true
    t.modules.mouse = true
    t.modules.timer = true
    t.modules.event = true
end
