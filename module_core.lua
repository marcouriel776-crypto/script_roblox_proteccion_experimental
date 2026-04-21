local Players = game:GetService("Players")
local player = Players.LocalPlayer

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

local function setup(char)
    UPF.Root = char:WaitForChild("HumanoidRootPart")
    print("✅ Character ready")
end

player.CharacterAdded:Connect(setup)

if player.Character then
    setup(player.Character)
end
