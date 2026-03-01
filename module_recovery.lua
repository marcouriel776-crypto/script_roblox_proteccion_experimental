-- MODULE RECOVERY
repeat task.wait() until CoreReady
repeat task.wait() until Character and Character:FindFirstChild("Humanoid") and Character:FindFirstChild("HumanoidRootPart")

Humanoid = Character:FindFirstChild("Humanoid")
RootPart = Character:FindFirstChild("HumanoidRootPart")

-- God Mode
GodModeEnabled = GodModeEnabled or false
local GodToggle = Instance.new("TextButton")
GodToggle.Parent = Content
GodToggle.Size = UDim2.fromScale(0.6, 0.18)
GodToggle.Text = "God Mode: OFF"
GodToggle.Font = Enum.Font.GothamBold
GodToggle.TextScaled = true
GodToggle.BackgroundColor3 = Color3.fromRGB(120,60,60)
GodToggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", GodToggle).CornerRadius = UDim.new(0,14)

GodToggle.MouseButton1Click:Connect(function()
    GodModeEnabled = not GodModeEnabled
    GodToggle.Text = GodModeEnabled and "God Mode: ON" or "God Mode: OFF"
    GodToggle.BackgroundColor3 = GodModeEnabled and Color3.fromRGB(60,160,90) or Color3.fromRGB(120,60,60)
end)

Connections.GodHeartbeat = RunService.Heartbeat:Connect(function()
    if not ScriptRunning or not GodModeEnabled then return end
    if not Humanoid or Humanoid.Health <= 0 then return end
    pcall(function()
        if Humanoid.MaxHealth < 100 then Humanoid.MaxHealth = 100 end
        if Humanoid.Health < Humanoid.MaxHealth then Humanoid.Health = Humanoid.MaxHealth end
    end)
end)

-- SAFE RETURN + AutoReturn toggle + cooldown
SafeAutoPoint = SafeAutoPoint or nil
AutoReturnEnabled = (AutoReturnEnabled == nil) and true or AutoReturnEnabled
ReturnCooldown = ReturnCooldown or 5
LastAutoReturn = LastAutoReturn or 0

local AutoReturnToggle = Instance.new("TextButton")
AutoReturnToggle.Parent = Content
AutoReturnToggle.Size = UDim2.fromScale(0.6, 0.18)
AutoReturnToggle.Text = AutoReturnEnabled and "Auto Return: ON" or "Auto Return: OFF"
AutoReturnToggle.Font = Enum.Font.GothamBold
AutoReturnToggle.TextScaled = true
AutoReturnToggle.BackgroundColor3 = AutoReturnEnabled and Color3.fromRGB(60,160,90) or Color3.fromRGB(120,120,120)
AutoReturnToggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", AutoReturnToggle).CornerRadius = UDim.new(0,14)

AutoReturnToggle.MouseButton1Click:Connect(function()
    AutoReturnEnabled = not AutoReturnEnabled
    AutoReturnToggle.Text = AutoReturnEnabled and "Auto Return: ON" or "Auto Return: OFF"
    AutoReturnToggle.BackgroundColor3 = AutoReturnEnabled and Color3.fromRGB(60,160,90) or Color3.fromRGB(120,120,120)
end)

-- Save safe point automatically when grounded & calm
Connections.SafePointTracker = RunService.Heartbeat:Connect(function()
    if not RootPart or not Humanoid then return end
    local vel = 0
    pcall(function() vel = RootPart.AssemblyLinearVelocity.Magnitude end)

    if Humanoid.FloorMaterial ~= Enum.Material.Air and vel < 10 then
        SafeAutoPoint = RootPart.CFrame
    end

    -- auto-return by void/height with cooldown and only if allowed
    if AutoReturnEnabled and SafeAutoPoint then
        local ok, y = pcall(function() return RootPart.Position.Y end)
        if ok and (y > 2000 or y < -500) and (tick() - LastAutoReturn > ReturnCooldown) then
            LastAutoReturn = tick()
            pcall(function() RootPart.CFrame = SafeAutoPoint end)
        end
    end
end)

-- Manual return UI (if you had it)
local ReturnAutoBtn = Instance.new("TextButton")
ReturnAutoBtn.Parent = Content
ReturnAutoBtn.Size = UDim2.fromScale(0.6, 0.18)
ReturnAutoBtn.Text = "Return to Safe Point"
ReturnAutoBtn.Font = Enum.Font.GothamBold
ReturnAutoBtn.TextScaled = true
ReturnAutoBtn.BackgroundColor3 = Color3.fromRGB(70,160,120)
ReturnAutoBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", ReturnAutoBtn).CornerRadius = UDim.new(0,14)

ReturnAutoBtn.MouseButton1Click:Connect(function()
    if SafeAutoPoint and RootPart then
        pcall(function() RootPart.CFrame = SafeAutoPoint end)
    end
end)

-- Death recovery: teleport after respawn, but only once and respecting cooldown & AutoReturnEnabled
if Humanoid then
    Connections.OnDeath = Humanoid.Died:Connect(function()
        local conn
        conn = LocalPlayer.CharacterAdded:Connect(function(newChar)
            conn:Disconnect()
            local hrp = newChar:WaitForChild("HumanoidRootPart", 5)
            task.delay(0.6, function()
                if AutoReturnEnabled and SafeAutoPoint and (tick() - LastAutoReturn > ReturnCooldown) then
                    LastAutoReturn = tick()
                    pcall(function() hrp.CFrame = SafeAutoPoint end)
                end
            end)
        end)
    end)
end

-- FREEZE & RECOVER (UI and logic)
local FreezeLabel = Instance.new("TextLabel")
FreezeLabel.Parent = Content
FreezeLabel.Size = UDim2.fromScale(0.9, 0.12)
FreezeLabel.BackgroundTransparency = 1
FreezeLabel.Font = Enum.Font.GothamBold
FreezeLabel.TextScaled = true
FreezeLabel.TextColor3 = Color3.fromRGB(180,220,255)
FreezeLabel.Text = "🧊 Freeze: NORMAL"

local UnfreezeButton = Instance.new("TextButton")
UnfreezeButton.Parent = Content
UnfreezeButton.Size = UDim2.fromScale(0.6, 0.18)
UnfreezeButton.Text = "Unfreeze Player"
UnfreezeButton.Font = Enum.Font.GothamBold
UnfreezeButton.TextScaled = true
UnfreezeButton.BackgroundColor3 = Color3.fromRGB(90, 140, 200)
UnfreezeButton.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", UnfreezeButton).CornerRadius = UDim.new(0,14)

local LastMoveTick = tick()
local LastPos = RootPart.Position
local FrozenDetected = false

Connections.FreezeDetect = RunService.Heartbeat:Connect(function()
    if not RootPart then return end
    local moved = (RootPart.Position - LastPos).Magnitude > 0.2
    local vel = 0
    pcall(function() vel = RootPart.AssemblyLinearVelocity.Magnitude end)

    if moved or vel > 1 then
        LastMoveTick = tick()
        FrozenDetected = false
    end

    if tick() - LastMoveTick > 3 then
        FrozenDetected = true
    end

    FreezeLabel.Text = FrozenDetected and "🧊 Freeze: FROZEN" or "🧊 Freeze: NORMAL"
    LastPos = RootPart.Position
end)

local function RecoverPlayer()
    if not RootPart or not Humanoid then return end
    pcall(function()
        RootPart.AssemblyLinearVelocity = Vector3.zero
        RootPart.AssemblyAngularVelocity = Vector3.zero
        for _, v in ipairs(RootPart:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("LinearVelocity") or v:IsA("BodyAngularVelocity") then
                v:Destroy()
            end
        end
        RootPart.Anchored = true
        task.wait(0.15)
        RootPart.Anchored = false
    end)
    LastMoveTick = tick()
    FrozenDetected = false
end

UnfreezeButton.MouseButton1Click:Connect(RecoverPlayer)

-- ADAPTIVE PERFORMANCE (respect manual override)
PerfState = PerfState or "NORMAL"
local LowFPS = 35
local RecoverFPS = 45
local PerfCooldown = 3
local LastSwitch = 0

local PerfLabel = Instance.new("TextLabel")
PerfLabel.Parent = Content
PerfLabel.Size = UDim2.fromScale(0.9, 0.12)
PerfLabel.BackgroundTransparency = 1
PerfLabel.Font = Enum.Font.GothamBold
PerfLabel.TextScaled = true
PerfLabel.TextColor3 = Color3.fromRGB(200,200,200)
PerfLabel.Text = "⚙ Performance: NORMAL"

local function SetPerf(state)
    PerfState = state
    PerfLabel.Text = "⚙ Performance: " .. state
    if state == "SAFE" then
        -- only auto-enable protection if user didn't manually turn it off
        if ProtectionManualOverride ~= false then
            ProtectionEnabled = true
        end
        SmartMode = "SAFE"
    end
end

Connections.PerfHeartbeat = RunService.Heartbeat:Connect(function(dt)
    if not ScriptRunning then return end
    if tick() - LastSwitch < PerfCooldown then return end
    local ok, fps = pcall(function() return math.floor(1 / dt) end)
    if not ok then return end

    if fps < LowFPS and PerfState ~= "SAFE" then
        LastSwitch = tick()
        SetPerf("SAFE")
    elseif fps > RecoverFPS and PerfState ~= "NORMAL" then
        LastSwitch = tick()
        PerfState = "NORMAL"
        PerfLabel.Text = "⚙ Performance: NORMAL"
    end
end)

print("✅ Recovery module loaded successfully")