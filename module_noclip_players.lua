-- module_noclip_players.lua (PRO STABLE)

local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

local LocalPlayer = Players.LocalPlayer

-- =========================
-- COLLISION GROUPS
-- =========================

pcall(function()
    PhysicsService:CreateCollisionGroup("LocalPlayer")
    PhysicsService:CreateCollisionGroup("OtherPlayers")
end)

-- 🔥 clave: NO colisionan entre sí
PhysicsService:CollisionGroupSetCollidable("LocalPlayer", "OtherPlayers", false)

-- pero sí consigo mismo (importante)
PhysicsService:CollisionGroupSetCollidable("LocalPlayer", "LocalPlayer", true)
PhysicsService:CollisionGroupSetCollidable("OtherPlayers", "OtherPlayers", true)

-- =========================
-- FUNCIONES
-- =========================

local function setGroup(char, group)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            PhysicsService:SetPartCollisionGroup(part, group)
        end
    end
end

-- =========================
-- APLICAR
-- =========================

local function apply()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            if plr == LocalPlayer then
                setGroup(plr.Character, "LocalPlayer")
            else
                setGroup(plr.Character, "OtherPlayers")
            end
        end
    end
end

apply()

-- nuevos jugadores
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.5)

        if plr == LocalPlayer then
            setGroup(char, "LocalPlayer")
        else
            setGroup(char, "OtherPlayers")
        end
    end)
end)

-- tu respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    setGroup(char, "LocalPlayer")
end)

print("✅ NoClip Players PRO (stable) loaded")
