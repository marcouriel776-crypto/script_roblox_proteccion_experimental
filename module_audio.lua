-- module_audio.lua
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

repeat task.wait() until CoreReady
repeat task.wait() until LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

local enabled = (Settings and Settings.audio_shield_enabled) or false
local radius = (Settings and Settings.audio_shield_radius) or 20
local level = (Settings and Settings.audio_shield_level) or 0.25

local OriginalVolumes = setmetatable({}, {__mode = "k"})

local function saveOriginal(sound)
    if not sound then return end
    if not OriginalVolumes[sound] then OriginalVolumes[sound] = sound.Volume end
end

local function setVolume(sound, v)
    if not sound then return end
    pcall(function() sound.Volume = v end)
end

local function restoreSound(sound)
    if not sound then return end
    if OriginalVolumes[sound] then
        pcall(function() sound.Volume = OriginalVolumes[sound] end)
        OriginalVolumes[sound] = nil
    end
end

local function applyShieldToCharacter(plr, shieldOn)
    if not plr or not plr.Character then return end
    for _, s in ipairs(plr.Character:GetDescendants()) do
        if s:IsA("Sound") then
            if shieldOn then saveOriginal(s); setVolume(s, level) else restoreSound(s) end
        end
    end
end

local function isPlayerNear(plr)
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    local a = plr.Character.HumanoidRootPart.Position
    local b = LocalPlayer.Character.HumanoidRootPart.Position
    return (a - b).Magnitude <= radius
end

Connections.AudioShieldHeartbeat = RunService.Heartbeat:Connect(function()
    if not CoreReady then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local ok, near = pcall(isPlayerNear, plr)
            if ok and near then
                applyShieldToCharacter(plr, enabled)
            else
                applyShieldToCharacter(plr, false)
            end
        end
    end
end)

function ToggleAudioShield(on)
    if on == nil then enabled = not enabled else enabled = on end
    Settings = Settings or {}
    Settings.audio_shield_enabled = enabled
    if type(SaveUPFSettings) == "function" then pcall(SaveUPFSettings) end
    print("Audio shield:", enabled)
end

function SetAudioShieldRadius(r)
    radius = math.max(1, tonumber(r) or radius)
    Settings = Settings or {}
    Settings.audio_shield_radius = radius
    if type(SaveUPFSettings) == "function" then pcall(SaveUPFSettings) end
end

function SetAudioShieldLevel(l)
    level = math.clamp(tonumber(l) or level, 0, 1)
    Settings = Settings or {}
    Settings.audio_shield_level = level
    if type(SaveUPFSettings) == "function" then pcall(SaveUPFSettings) end
end

print("✅ module_audio loaded — spatial shield ready (client-side only)")