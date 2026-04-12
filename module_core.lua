local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

UPF.State = UPF.State or {}
UPF.Connections = UPF.Connections or {}

UPF.State.ScriptRunning = true
UPF.State.ProtectionEnabled = true
UPF.State.CharacterReady = false

UPF.RootPart = nil
UPF.Humanoid = nil

local function SetupCharacter(char)
    if not char then return end

    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    UPF.RootPart = hrp
    UPF.Humanoid = hum
    UPF.State.CharacterReady = true

    print("✅ Character ready")
end

if UPF.Connections.CharacterAdded then
    UPF.Connections.CharacterAdded:Disconnect()
end

UPF.Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(char)
    UPF.State.CharacterReady = false
    SetupCharacter(char)
end)

if LocalPlayer.Character then
    SetupCharacter(LocalPlayer.Character)
end

print("✅ Core loaded")
