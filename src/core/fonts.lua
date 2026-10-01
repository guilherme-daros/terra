-- fonts.lua
-- Centralized Font and Typography Manager for Cosmic Defender

local Fonts = {
    pathRegular = "assets/fonts/JetBrainsMonoNerdFont-Regular.ttf",
    pathBold    = "assets/fonts/JetBrainsMonoNerdFont-Bold.ttf",

    -- Icon references
    icons = {
        heart     = "",
        triple    = "󱐋",
        shield    = "",
        rocket    = "󰓎",
        keyboard  = "󰌌",
        mouse     = "󰍽",
        laser     = "󰓅",
        chip      = "",
        pause     = "󰏤",
        quit      = "󰗼"
    }
}

local function safeLoadFont(path, size)
    if love.filesystem.getInfo(path) then
        return love.graphics.newFont(path, size)
    else
        return love.graphics.newFont(size)
    end
end

function Fonts.init()
    Fonts.small   = safeLoadFont(Fonts.pathRegular, 12)
    Fonts.medium  = safeLoadFont(Fonts.pathRegular, 14)
    Fonts.regular = safeLoadFont(Fonts.pathRegular, 16)
    Fonts.bold    = safeLoadFont(Fonts.pathBold, 16)
    Fonts.large   = safeLoadFont(Fonts.pathBold, 22)
    Fonts.title   = safeLoadFont(Fonts.pathBold, 36)

    love.graphics.setFont(Fonts.regular)
end

return Fonts
