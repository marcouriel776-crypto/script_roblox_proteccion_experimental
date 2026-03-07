-- module_audio.lua
-- UPF Audio Shield (Clean Architecture)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local UPF = _G.UPF
if not UPF then
    warn("UPF not initialized before Audio module")
    return
end

local LocalPlayer = Players.LocalPlayer

UPF.State = UPF.State or {}
UPF.Settings = UPF.Settings or {}
UPF.Connections = UPF.Connections or {}

--------------------------------------------------
-- STATE INIT
--------------------------------------------------

UPF.State.Audio = UPF.State.Audio or {
    Enabled = UPF.Settings.audio_shield_enabled or false,
    Radius = UPF.Settings.audio_shield_radius or 20,
    Level = UPF.Settings.audio_shield_level or 0.25
}

local OriginalVolumes = setmetatable({}, {__mode = "k"})

--------------------------------------------------
-- INTERNAL FUNCTIONS
--------------------------------------------------

local function saveOriginal(sound)
    if sound and not OriginalVolumes[sound] then
        OriginalVolumes[sound] = sound.Volume
    end
end

local function setVolume(sound, v)
    if sound then
        pcall(function()
            sound.Volume = v
        end)
    end
end

local function restoreSound(sound)
    if sound and OriginalVolumes[sound] then
        pcall(function()
            sound.Volume = OriginalVolumes[sound]
        end)
        OriginalVolumes[sound] = nil
    end
end

local function applyShieldToCharacter(plr, shieldOn)
    if not plr.Character then return end

    for _, obj in ipairs(plr.Character:GetDescendants()) do
        if obj:IsA("Sound") then
            if shieldOn then
                saveOriginal(obj)
                setVolume(obj, UPF.State.Audio.Level)
            else
                restoreSound(obj)
            end
        end
    end
end

local function isPlayerNear(plr)
    if not plr.Character or not LocalPlayer.Character then return false end
    
    local hrpA = plr.Character:FindFirstChild("HumanoidRootPart")
    local hrpB = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not hrpA or not hrpB then return false end
    
    return (hrpA.Position - hrpB.Position).Magnitude <= UPF.State.Audio.Radius
end

--------------------------------------------------
-- HEARTBEAT LOOP
--------------------------------------------------

UPF.Connections.AudioShieldHeartbeat = RunService.Heartbeat:Connect(function()
    if not UPF.State.Audio.Enabled then
        return
    end

    if not LocalPlayer.Character then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local ok, near = pcall(isPlayerNear, plr)

            if ok and near then
                applyShieldToCharacter(plr, true)
            else
                applyShieldToCharacter(plr, false)
            end
        end
    end
end)

--------------------------------------------------
-- PUBLIC METHODS
--------------------------------------------------

function UPF:ToggleAudioShield(on)
    if on == nil then
        UPF.State.Audio.Enabled = not UPF.State.Audio.Enabled
    else
        UPF.State.Audio.Enabled = on
    end

    UPF.Settings.audio_shield_enabled = UPF.State.Audio.Enabled
    if UPF.SaveSettings then
        UPF:SaveSettings()
    end

    print("🔊 Audio Shield:", UPF.State.Audio.Enabled)
end

function UPF:SetAudioShieldRadius(r)
    UPF.State.Audio.Radius = math.max(1, tonumber(r) or UPF.State.Audio.Radius)
    UPF.Settings.audio_shield_radius = UPF.State.Audio.Radius

    if UPF.SaveSettings then
        UPF:SaveSettings()
    end
end

function UPF:SetAudioShieldLevel(l)
    UPF.State.Audio.Level = math.clamp(tonumber(l) or UPF.State.Audio.Level, 0, 1)
    UPF.Settings.audio_shield_level = UPF.State.Audio.Level

    if UPF.SaveSettings then
        UPF:SaveSettings()
    end
end

print("✅ Audio module v2 loaded (UPF connected)")