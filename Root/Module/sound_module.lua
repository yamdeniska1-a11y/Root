-- ====================================================================
-- Sound_Module.lua
-- 3 ссылки с GitHub в самом начале для загрузки звуков
-- Звуки сохраняются локально в папку RootLib/Sound, чтобы Roblox не
-- скачивал их каждый раз с GitHub и воспроизводил без задержки!
-- ====================================================================
local SCROLL_SOUND_URL       = "https://github.com/yamdeniska1-a11y/Root/blob/main/Root/Module/Scroll.ogg"
local CLICK_SOUND_URL        = "https://github.com/yamdeniska1-a11y/Root/blob/main/Root/Module/Click.ogg"
local NOTIFICATION_SOUND_URL = "https://github.com/yamdeniska1-a11y/Root/blob/main/Root/Module/Notification.ogg"

local SoundService = game:GetService("SoundService")

local SoundController = {
    ScrollEnabled = true,
    ClickEnabled = true,
    NotificationVolume = 1,
    ScrollVolume = 0.2,
    ClickVolume = 0.2,
    LastScrollPlay = 0,
    Initialized = false,
    Assets = {
        Scroll = {
            Url = SCROLL_SOUND_URL,
            File = "RootLib/Sound/Scroll.ogg",
            SoundId = nil,
            Instance = nil
        },
        Click = {
            Url = CLICK_SOUND_URL,
            File = "RootLib/Sound/Click.ogg",
            SoundId = nil,
            Instance = nil
        },
        Notification = {
            Url = NOTIFICATION_SOUND_URL,
            File = "RootLib/Sound/Notification.ogg",
            SoundId = nil,
            Instance = nil
        }
    }
}

function SoundController:EnsureSoundFolder()
    pcall(function()
        if makefolder and isfolder then
            if not isfolder("RootLib") then makefolder("RootLib") end
            if not isfolder("RootLib/Config") then makefolder("RootLib/Config") end
            if not isfolder("RootLib/Save") then makefolder("RootLib/Save") end
            if not isfolder("RootLib/Sound") then makefolder("RootLib/Sound") end
        end
    end)
end

function SoundController:DownloadAndCacheSounds(onProgress)
    self:EnsureSoundFolder()
    local getAsset = getcustomasset or getsynasset
    for key, info in pairs(self.Assets) do
        pcall(function()
            if writefile and isfile and getAsset then
                -- Скачиваем звук с GitHub только если файла еще нет в RootLib/Sound
                if not isfile(info.File) or (readfile and #readfile(info.File) < 64) then
                    if onProgress then pcall(onProgress, "Downloading " .. key .. ".ogg...") end
                    local ok, data = pcall(function()
                        return game:HttpGet(info.Url)
                    end)
                    if ok and type(data) == "string" and #data > 64 then
                        writefile(info.File, data)
                    end
                end
                if isfile(info.File) then
                    info.SoundId = getAsset(info.File)
                end
            end

            local existing = SoundService:FindFirstChild("RootLibSound_" .. key)
            local snd = existing or Instance.new("Sound")
            snd.Name = "RootLibSound_" .. key
            if info.SoundId then
                snd.SoundId = info.SoundId
            end
            snd.Volume = (key == "Notification") and self.NotificationVolume or 0.2
            snd.Parent = SoundService
            info.Instance = snd
        end)
    end
    self.Initialized = true
    if onProgress then pcall(onProgress, "Ready (Cached in RootLib/Sound)") end
end

function SoundController:Init(onProgress)
    task.spawn(function()
        self:DownloadAndCacheSounds(onProgress)
    end)
end

function SoundController:PlayScroll()
    if not self.ScrollEnabled then return end
    local now = tick()
    if now - self.LastScrollPlay < 0.035 then return end
    self.LastScrollPlay = now
    pcall(function()
        local info = self.Assets.Scroll
        local snd = info and info.Instance
        if snd and snd.SoundId and snd.SoundId ~= "" then
            snd.Volume = self.ScrollVolume
            snd.TimePosition = 0
            snd:Play()
        end
    end)
end

function SoundController:PlayClick()
    if not self.ClickEnabled then return end
    pcall(function()
        local info = self.Assets.Click
        local snd = info and info.Instance
        if snd and snd.SoundId and snd.SoundId ~= "" then
            snd.Volume = self.ClickVolume
            snd.TimePosition = 0
            snd:Play()
        end
    end)
end

function SoundController:PlayNotification()
    if self.NotificationVolume <= 0 then return end
    pcall(function()
        local info = self.Assets.Notification
        local snd = info and info.Instance
        if snd and snd.SoundId and snd.SoundId ~= "" then
            snd.Volume = self.NotificationVolume
            snd.TimePosition = 0
            snd:Play()
        end
    end)
end

SoundController:Init()

if getgenv then
    getgenv().RootLib_SoundModule = SoundController
    getgenv().SoundController = SoundController
end
_G.RootLib_SoundModule = SoundController
_G.SoundController = SoundController

return SoundController
