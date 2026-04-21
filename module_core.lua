local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

UPF.Character = nil
UPF.Root = nil

local function setup(char)
    local root = char:WaitForChild("HumanoidRootPart")

    UPF.Character = char
    UPF.Root = root

    print("✅ Character ready")
end

LocalPlayer.CharacterAdded:Connect(setup)

if LocalPlayer.Character then
    setup(LocalPlayer.Character)
end
