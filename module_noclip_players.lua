-- module_noclip_players.lua (OPTIMIZADO)

local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

local LocalPlayer = Players.LocalPlayer

-- crear collision group
pcall(function()
    PhysicsService:CreateCollisionGroup("Players")
end)

PhysicsService:CollisionGroupSetCollidable("Players", "Players", false)

local function setCharacterGroup(char)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            PhysicsService:SetPartCollisionGroup(part, "Players")
        end
    end
end

-- aplicar a todos
local function apply()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            setCharacterGroup(plr.Character)
        end
    end
end

-- inicial
apply()

-- cuando aparecen jugadores
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(1)
        setCharacterGroup(char)
    end)
end)

-- tu personaje
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    setCharacterGroup(char)
end)

print("✅ NoClip Players PRO loaded")
