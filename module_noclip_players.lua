-- module_noclip_players.lua (CLIENT SAFE)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- =========================

local function setNoCollision(char)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- =========================

RunService.Stepped:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            setNoCollision(plr.Character)
        end
    end
end)

print("✅ NoClip Players (client-safe) loaded")
