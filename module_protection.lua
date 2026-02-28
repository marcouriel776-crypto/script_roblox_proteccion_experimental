-- =========================================================
-- MODULE PROTECTION
-- Physical Protection (Anti-Force / Anti-Velocity)
-- Platform: Android / Delta
-- Version: 0.9.x (Stable)
-- =========================================================

-- Espera a que Core esté listo
repeat task.wait() until CoreReady

-- Espera a que Character/Humanoid/RootPart existan
repeat task.wait() until Character and Character:FindFirstChild("Humanoid") and Character:FindFirstChild("HumanoidRootPart")

-- Asegura referencias globales (core las creó)
Humanoid = Character:FindFirstChild("Humanoid")
RootPart = Character:FindFirstChild("HumanoidRootPart")

-- STATE
BlockedEvents = BlockedEvents or 0
LastSafePosition = LastSafePosition or nil

-- SETTINGS
local MAX_DISTANCE_PER_FRAME = 35      -- studs
local MAX_LINEAR_VELOCITY = 120        -- studs/sec

-- HELPERS
local function ClearForces(part)
    if not part then return end

    pcall(function()
        part.AssemblyLinearVelocity = Vector3.zero
        part.AssemblyAngularVelocity = Vector3.zero
    end)

    for _, v in ipairs(part:GetChildren()) do
        if v:IsA("BodyVelocity")
        or v:IsA("BodyAngularVelocity")
        or v:IsA("BodyGyro")
        or v:IsA("LinearVelocity")
        or v:IsA("AngularVelocity") then
            pcall(function() v:Destroy() end)
        end
    end
end

-- MAIN PROTECTION LOOP
local lastPosition = nil
Connections.ProtectionHeartbeat = RunService.Heartbeat:Connect(function()
    if not ScriptRunning then return end
    if not ProtectionEnabled then return end
    if not RootPart or not Humanoid then return end

    if not lastPosition then
        lastPosition = RootPart.Position
        return
    end

    local dist = (RootPart.Position - lastPosition).Magnitude
    if dist > MAX_DISTANCE_PER_FRAME then
        -- rollback
        pcall(function() RootPart.CFrame = CFrame.new(lastPosition) end)
        ClearForces(RootPart)
        BlockedEvents = (BlockedEvents or 0) + 1
    end

    local vel = RootPart.AssemblyLinearVelocity.Magnitude
    if vel > MAX_LINEAR_VELOCITY then
        ClearForces(RootPart)
        BlockedEvents = (BlockedEvents or 0) + 1
    end

    if Humanoid.FloorMaterial ~= Enum.Material.Air and vel < 10 then
        LastSafePosition = RootPart.CFrame
    end

    lastPosition = RootPart.Position
end)

print("✅ Protection module loaded successfully")
