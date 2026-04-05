-- module_core.lua (ULTRA STABLE)

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

UPF.State = UPF.State or {}
UPF.Connections = UPF.Connections or {}

UPF.State.ScriptRunning = true
UPF.State.ProtectionEnabled = true
UPF.State.CharacterReady = false -- 🔥 NUEVO

UPF.RootPart = nil
UPF.Humanoid = nil

-- =========================
-- CHARACTER SETUP
-- =========================

local function SetupCharacter(char)
    if not char then return end

    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    if not hrp or not hum then
        warn("[UPF] Failed to get character parts")
        return
    end

    UPF.RootPart = hrp
    UPF.Humanoid = hum
    UPF.State.CharacterReady = true -- 🔥 CLAVE

    print("✅ Character fully ready")
end

-- =========================
-- CHARACTER EVENTS
-- =========================

if UPF.Connections.CharacterAdded then
    pcall(function()
        UPF.Connections.CharacterAdded:Disconnect()
    end)
end

UPF.Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(char)
    UPF.State.CharacterReady = false

    -- 🔥 ESPERA REAL (no tiempo fijo)
    SetupCharacter(char)
end)

-- inicial
if LocalPlayer.Character then
    SetupCharacter(LocalPlayer.Character)
end

print("✅ Core ULTRA STABLE loaded")
