-- =========================================================
-- MODULE RECOVERY
-- God Mode / Freeze & Recover / Safe Return / Performance
-- Platform: Android / Delta
-- Version: 0.9.x (Recovery)
-- =========================================================

-- ================= SAFETY CHECK =================
if not ScriptRunning or not RootPart or not Humanoid then
    warn("❌ Core not ready. Recovery module aborted.")
    return
end

-- ================= GOD MODE =================
GodModeEnabled = GodModeEnabled or false

GodToggle = Instance.new("TextButton")
GodToggle.Parent = Main
GodToggle.Position = UDim2.fromScale(0.2, 0.96)
GodToggle.Size = UDim2.fromScale(0.6, 0.18)
GodToggle.Text = "God Mode: OFF"
GodToggle.Font = Enum.Font.GothamBold
GodToggle.TextScaled = true
GodToggle.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
GodToggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", GodToggle).CornerRadius = UDim.new(0, 14)

GodToggle.MouseButton1Click:Connect(function()
    GodModeEnabled = not GodModeEnabled
    GodToggle.Text = GodModeEnabled and "God Mode: ON" or "God Mode: OFF"
    GodToggle.BackgroundColor3 = GodModeEnabled
        and Color3.fromRGB(60, 160, 90)
        or Color3.fromRGB(120, 60, 60)
end)

-- God Mode loop (regen 100%)
Connections.GodHeartbeat = RunService.Heartbeat:Connect(function()
    if not ScriptRunning or not GodModeEnabled then return end
    if Humanoid.Health <= 0 then return end

    if Humanoid.MaxHealth < 100 then
        Humanoid.MaxHealth = 100
    end

    if Humanoid.Health < Humanoid.MaxHealth then
        Humanoid.Health = Humanoid.MaxHealth
    end
end)

-- ================= SAFE RETURN =================
SafeAutoPoint = SafeAutoPoint or nil

Connections.SafePointTracker = RunService.Heartbeat:Connect(function()
    if not RootPart or not Humanoid then return end

    local vel = RootPart.AssemblyLinearVelocity.Magnitude
    if Humanoid.FloorMaterial ~= Enum.Material.Air and vel < 10 then
        SafeAutoPoint = RootPart.CFrame
    end

    -- Emergency void protection
    if RootPart.Position.Y > 2000 or RootPart.Position.Y < -500 then
        if SafeAutoPoint then
            RootPart.CFrame = SafeAutoPoint
        end
    end
end)

-- ================= FREEZE & RECOVER =================
FrozenDetected = false
local LastMoveTick = tick()
local LastPos = RootPart.Position

FreezeLabel = Instance.new("TextLabel")
FreezeLabel.Parent = Main
FreezeLabel.Position = UDim2.fromScale(0.05, 1.16)
FreezeLabel.Size = UDim2.fromScale(0.9, 0.12)
FreezeLabel.BackgroundTransparency = 1
FreezeLabel.Font = Enum.Font.GothamBold
FreezeLabel.TextScaled = true
FreezeLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
FreezeLabel.Text = "🧊 Freeze: NORMAL"

UnfreezeButton = Instance.new("TextButton")
UnfreezeButton.Parent = Main
UnfreezeButton.Position = UDim2.fromScale(0.2, 1.30)
UnfreezeButton.Size = UDim2.fromScale(0.6, 0.18)
UnfreezeButton.Text = "Unfreeze Player"
UnfreezeButton.Font = Enum.Font.GothamBold
UnfreezeButton.TextScaled = true
UnfreezeButton.BackgroundColor3 = Color3.fromRGB(90, 140, 200)
UnfreezeButton.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", UnfreezeButton).CornerRadius = UDim.new(0, 14)

local function RecoverPlayer()
    if not RootPart or not Humanoid then return end

    RootPart.AssemblyLinearVelocity = Vector3.zero
    RootPart.AssemblyAngularVelocity = Vector3.zero

    for _, v in ipairs(RootPart:GetChildren()) do
        if v:IsA("BodyVelocity")
        or v:IsA("LinearVelocity")
        or v:IsA("BodyAngularVelocity") then
            v:Destroy()
        end
    end

    RootPart.Anchored = true
    task.wait(0.15)
    RootPart.Anchored = false

    LastMoveTick = tick()
    FrozenDetected = false
end

UnfreezeButton.MouseButton1Click:Connect(RecoverPlayer)

Connections.FreezeDetect = RunService.Heartbeat:Connect(function()
    if not RootPart then return end

    local moved = (RootPart.Position - LastPos).Magnitude > 0.2
    local vel = RootPart.AssemblyLinearVelocity.Magnitude

    if moved or vel > 1 then
        LastMoveTick = tick()
        FrozenDetected = false
    end

    if tick() - LastMoveTick > 3 then
        FrozenDetected = true
    end

    FreezeLabel.Text = FrozenDetected
        and "🧊 Freeze: FROZEN"
        or "🧊 Freeze: NORMAL"

    LastPos = RootPart.Position
end)

-- ================= ADAPTIVE PERFORMANCE =================
PerfState = PerfState or "NORMAL"
local LowFPS = 35
local RecoverFPS = 45
local PerfCooldown = 3
local LastSwitch = 0

PerfLabel = Instance.new("TextLabel")
PerfLabel.Parent = Main
PerfLabel.Position = UDim2.fromScale(0.05, 1.52)
PerfLabel.Size = UDim2.fromScale(0.9, 0.12)
PerfLabel.BackgroundTransparency = 1
PerfLabel.Font = Enum.Font.GothamBold
PerfLabel.TextScaled = true
PerfLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PerfLabel.Text = "⚙ Performance: NORMAL"

local function SetPerf(state)
    PerfState = state
    PerfLabel.Text = "⚙ Performance: " .. state

    if state == "SAFE" then
        ProtectionEnabled = true
        SmartMode = "SAFE"
    end
end

Connections.PerfHeartbeat = RunService.Heartbeat:Connect(function(dt)
    if not ScriptRunning then return end
    if tick() - LastSwitch < PerfCooldown then return end

    local fps = math.floor(1 / dt)

    if fps < LowFPS and PerfState ~= "SAFE" then
        LastSwitch = tick()
        SetPerf("SAFE")
    elseif fps > RecoverFPS and PerfState ~= "NORMAL" then
        LastSwitch = tick()
        SetPerf("NORMAL")
    end
end)

print("✅ Recovery module loaded successfully")