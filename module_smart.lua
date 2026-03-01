-- module_smart.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

repeat task.wait() until CoreReady
repeat task.wait() until Character and Character:FindFirstChild("Humanoid") and Character:FindFirstChild("HumanoidRootPart")

Humanoid = Character:FindFirstChild("Humanoid")
RootPart = Character:FindFirstChild("HumanoidRootPart")

SmartMode = SmartMode or (Settings and Settings.smart_mode) or "SAFE"
FlingDetected = false
FlingEvents = FlingEvents or 0
DangerousPlayers = DangerousPlayers or {}

local function SetPlayerCollision(char, canCollide)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = canCollide
        end
    end
end

local SmartLabel = Instance.new("TextLabel")
SmartLabel.Parent = Content
SmartLabel.Size = UDim2.fromScale(0.9, 0.12)
SmartLabel.BackgroundTransparency = 1
SmartLabel.Font = Enum.Font.GothamBold
SmartLabel.TextScaled = true
SmartLabel.TextColor3 = Color3.fromRGB(255,180,80)
SmartLabel.Text = "Smart Protection: CLEAR"

local ModeButton = Instance.new("TextButton")
ModeButton.Parent = Content
ModeButton.Size = UDim2.fromScale(0.42, 0.18)
ModeButton.Text = "Mode: " .. SmartMode
ModeButton.Font = Enum.Font.GothamBold
ModeButton.TextScaled = true
ModeButton.BackgroundColor3 = Color3.fromRGB(80,140,200)
ModeButton.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", ModeButton).CornerRadius = UDim.new(0,12)

ModeButton.MouseButton1Click:Connect(function()
    SmartMode = (SmartMode == "SAFE") and "PVP" or "SAFE"
    ModeButton.Text = "Mode: " .. SmartMode
    Settings.smart_mode = SmartMode
    if type(SaveUPFSettings) == "function" then pcall(SaveUPFSettings) end
end)

local PanicButton = Instance.new("TextButton")
PanicButton.Parent = Content
PanicButton.Size = UDim2.fromScale(0.42, 0.18)
PanicButton.Text = "🚨 PANIC"
PanicButton.Font = Enum.Font.GothamBold
PanicButton.TextScaled = true
PanicButton.BackgroundColor3 = Color3.fromRGB(180,60,60)
PanicButton.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", PanicButton).CornerRadius = UDim.new(0,12)

local PanicCooldown = false
PanicButton.MouseButton1Click:Connect(function()
    if PanicCooldown then return end
    PanicCooldown = true
    ProtectionEnabled = true
    ProtectionManualOverride = true
    SmartMode = "SAFE"
    ModeButton.Text = "Mode: SAFE"
    if LastSafePosition and RootPart then
        pcall(function() RootPart.CFrame = LastSafePosition end)
    end
    pcall(function()
        RootPart.AssemblyLinearVelocity = Vector3.zero
        RootPart.AssemblyAngularVelocity = Vector3.zero
    end)
    PanicButton.Text = "PANIC ACTIVE"
    PanicButton.BackgroundColor3 = Color3.fromRGB(120,120,120)
    task.delay(3, function()
        PanicButton.Text = "🚨 PANIC"
        PanicButton.BackgroundColor3 = Color3.fromRGB(180,60,60)
        PanicCooldown = false
    end)
end)

local function MarkDanger(plr)
    DangerousPlayers[plr] = tick()
    FlingDetected = true
    FlingEvents = (FlingEvents or 0) + 1
end

local function CleanupDanger()
    for plr, t in pairs(DangerousPlayers) do
        if tick() - t > 3 then
            if plr.Character then pcall(function() SetPlayerCollision(plr.Character, true) end) end
            DangerousPlayers[plr] = nil
        end
    end
    if next(DangerousPlayers) == nil then FlingDetected = false end
end

Connections.SmartHeartbeat = RunService.Heartbeat:Connect(function()
    if not ScriptRunning or not ProtectionEnabled then return end
    CleanupDanger()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel = 0
                pcall(function() vel = hrp.AssemblyLinearVelocity.Magnitude end)
                if vel > (SmartMode == "SAFE" and 80 or 120) then MarkDanger(plr) end
                for _, v in ipairs(hrp:GetChildren()) do
                    if v:IsA("BodyVelocity") or v:IsA("LinearVelocity") then MarkDanger(plr) end
                end
                if DangerousPlayers[plr] then pcall(function() SetPlayerCollision(plr.Character, false) end) end
            end
        end
    end
    SmartLabel.Text = FlingDetected and ("⚠ Fling Detected | Events: " .. (FlingEvents or 0)) or "Smart Protection: CLEAR"
end)

print("✅ Smart module (client-safe) loaded successfully")