local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

pcall(function()
    PhysicsService:CreateCollisionGroup("Players")
end)

PhysicsService:CollisionGroupSetCollidable("Players","Players",false)

local function apply(char)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            PhysicsService:SetPartCollisionGroup(part,"Players")
        end
    end
end

for _, plr in ipairs(Players:GetPlayers()) do
    if plr.Character then apply(plr.Character) end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(1)
        apply(char)
    end)
end)

print("✅ NoClip Players loaded")
