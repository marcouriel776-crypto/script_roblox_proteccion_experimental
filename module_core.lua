local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

UPF.Character = nil
UPF.Humanoid = nil
UPF.Root = nil

local function Setup(char)
    UPF.Character = char
    UPF.Humanoid = char:WaitForChild("Humanoid")
    UPF.Root = char:WaitForChild("HumanoidRootPart")
end

if LocalPlayer.Character then
    Setup(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(Setup)

print("✅ Core loaded")
