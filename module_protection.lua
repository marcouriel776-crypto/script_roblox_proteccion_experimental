-- =========================================================
-- MODULE PROTECTION
-- Physical Protection (Anti-Force / Anti-Velocity)
-- Platform: Android / Delta
-- Version: 0.9.x (Stable)
-- =========================================================

-- ================= SAFETY CHECK =================
if not ScriptRunning then
    warn("❌ Core not loaded. Protection aborted.")
    return
end

-- ================= STATE =================
BlockedEvents = BlockedEvents or 0
LastSafePosition = LastSafePosition or nil

-- ================= SETTINGS =================
local MAX_DISTANCE_PER_FRAME = 35      -- studs
local MAX_LINEAR_VELOCITY = 120         -- studs/sec

-- ================= INTERNAL =================
local lastPosition = nil

-- ================= HELPERS =================
local function ClearForces(part)
    if not part then return end

    part.AssemblyLinearVelocity = Vector3.zero
    part.AssemblyAngularVelocity = Vector3.zero

    for _, v in ipairs(part:GetChildren()) do
        if v:IsA("BodyVelocity")
        or v:IsA("BodyAngularVelocity")
        or v:IsA("BodyGyro")
        or v:IsA("LinearVelocity")
        or v:IsA("AngularVelocity") then
            v:Destroy()
        end
    end
end

-- ================= MAIN PROTECTION LOOP =================
Connections.ProtectionHeartbeat = RunService.Heartbeat:Connect(function()
    if not ScriptRunning then return end
    if not ProtectionEnabled then return end
    if not RootPart or not Humanoid then return end

    -- Initialize
    if not lastPosition then
        lastPosition = RootPart.Position
        return
    end

    -- Distance jump check (anti-launch / anti-fling)
    local dist = (RootPart.Position - lastPosition).Magnitude
    if dist > MAX_DISTANCE_PER_FRAME then
        RootPart.CFrame = CFrame.new(lastPosition)
        ClearForces(RootPart)

        BlockedEvents += 1
    end

    -- Velocity check
    local vel = RootPart.AssemblyLinearVelocity.Magnitude
    if vel > MAX_LINEAR_VELOCITY then
        ClearForces(RootPart)
        BlockedEvents += 1
    end

    -- Save safe position (grounded & calm)
    if Humanoid.FloorMaterial ~= Enum.Material.Air and vel < 10 then
        LastSafePosition = RootPart.CFrame
    end

    lastPosition = RootPart.Position
end)

print("✅ Protection module loaded successfully")