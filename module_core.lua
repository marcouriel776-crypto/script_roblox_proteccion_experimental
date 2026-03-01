-- MODULE PROTECTION
repeat task.wait() until CoreReady
repeat task.wait() until Character and Character:FindFirstChild("Humanoid") and Character:FindFirstChild("HumanoidRootPart")

Humanoid = Character:FindFirstChild("Humanoid")
RootPart = Character:FindFirstChild("HumanoidRootPart")

BlockedEvents = BlockedEvents or 0
LastSafePosition = LastSafePosition or nil

local MAX_DISTANCE_PER_FRAME = 35
local MAX_LINEAR_VELOCITY = 120

local function ClearForces(part)
    if not part then return end
    pcall(function()
        part.AssemblyLinearVelocity = Vector3.zero
        part.AssemblyAngularVelocity = Vector3.zero
    end)
    for _, v in ipairs(part:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyGyro") or v:IsA("LinearVelocity") or v:IsA("AngularVelocity") then
            pcall(function() v:Destroy() end)
        end
    end
end

local lastPosition = nil
Connections.ProtectionHeartbeat = RunService.Heartbeat:Connect(function()
    if not ScriptRunning then return end
    if not ProtectionEnabled then return end
    if not RootPart or not Humanoid then return end

    if not lastPosition then lastPosition = RootPart.Position return end

    local dist = (RootPart.Position - lastPosition).Magnitude
    if dist > MAX_DISTANCE_PER_FRAME then
        pcall(function() RootPart.CFrame = CFrame.new(lastPosition) end)
        ClearForces(RootPart)
        BlockedEvents = (BlockedEvents or 0) + 1
    end

    local vel = 0
    pcall(function() vel = RootPart.AssemblyLinearVelocity.Magnitude end)
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