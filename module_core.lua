-- =========================================================
-- MODULE CORE
-- Universal Protection Framework
-- Platform: Android / Delta
-- Version: 0.9.x UI Pro (CoreReady)
-- =========================================================

-- SERVICES
Players = game:GetService("Players")
RunService = game:GetService("RunService")
CoreGui = game:GetService("CoreGui")
UserInputService = game:GetService("UserInputService")

LocalPlayer = Players.LocalPlayer

-- GLOBAL STATE (intencionalmente global para que otros módulos lo usen)
ScriptRunning = true
ProtectionEnabled = false
Connections = {}

Character = nil
Humanoid = nil
RootPart = nil

-- CHARACTER HANDLER
local function UpdateCharacter(char)
    Character = char
    Humanoid = char:FindFirstChild("Humanoid") or char:WaitForChild("Humanoid", 5)
    RootPart = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
end

if LocalPlayer.Character then
    UpdateCharacter(LocalPlayer.Character)
end
Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(UpdateCharacter)

-- SHUTDOWN
function ShutdownFramework()
    ScriptRunning = false
    ProtectionEnabled = false
    for _, c in pairs(Connections) do
        pcall(function() c:Disconnect() end)
    end
    if CoreGui:FindFirstChild("ProtectionUI") then
        CoreGui.ProtectionUI:Destroy()
    end
end

-- UI CREATION (reemplaza si existe)
if CoreGui:FindFirstChild("ProtectionUI") then
    CoreGui.ProtectionUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProtectionUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- MAIN WINDOW
Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.fromScale(0.55, 0.35)
Main.Position = UDim2.fromScale(0.225, 0.33)
Main.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

-- Gradient background
local MainGradient = Instance.new("UIGradient", Main)
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 32, 48)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 20, 30))
}
MainGradient.Rotation = 90

-- HEADER
Header = Instance.new("Frame")
Header.Parent = Main
Header.Size = UDim2.fromScale(1, 0.18)
Header.BackgroundTransparency = 0
Header.BackgroundColor3 = Color3.fromRGB(35, 45, 85)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

local HeaderGradient = Instance.new("UIGradient", Header)
HeaderGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 60, 120)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 40, 90))
}

TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = Header
TitleLabel.Size = UDim2.fromScale(1, 1)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🛡 Universal Protection Framework"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextScaled = true
TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)

-- SCROLL CONTENT
Content = Instance.new("ScrollingFrame")
Content.Parent = Main
Content.Position = UDim2.fromScale(0, 0.18)
Content.Size = UDim2.fromScale(1, 0.82)
Content.BackgroundTransparency = 1
Content.ScrollBarImageTransparency = 0.3
Content.ScrollBarThickness = 6
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIList = Instance.new("UIListLayout")
UIList.Parent = Content
UIList.Padding = UDim.new(0, 12)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- SECTION HELPER
local function CreateSection(title)
    local Holder = Instance.new("Frame")
    Holder.Parent = Content
    Holder.Size = UDim2.fromScale(0.95, 0.08)
    Holder.BackgroundTransparency = 1

    local Line = Instance.new("Frame")
    Line.Parent = Holder
    Line.Size = UDim2.fromScale(1, 0.05)
    Line.Position = UDim2.fromScale(0, 0.95)
    Line.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    Line.BorderSizePixel = 0

    local Label = Instance.new("TextLabel")
    Label.Parent = Holder
    Label.Size = UDim2.fromScale(1, 0.9)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.Font = Enum.Font.GothamBold
    Label.TextScaled = true
    Label.TextColor3 = Color3.fromRGB(200, 200, 220)
    Label.TextXAlignment = Enum.TextXAlignment.Left

    return Holder
end

-- INITIAL SECTIONS & BASE UI ELEMENTS
CreateSection("🛡 PROTECTION")

InfoLabel = Instance.new("TextLabel")
InfoLabel.Parent = Content
InfoLabel.Size = UDim2.fromScale(0.9, 0.12)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextScaled = true
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
InfoLabel.Text = "FPS: -- | Status: OFF"

ProtectionToggle = Instance.new("TextButton")
ProtectionToggle.Parent = Content
ProtectionToggle.Size = UDim2.fromScale(0.6, 0.18)
ProtectionToggle.Text = "Enable Protection"
ProtectionToggle.Font = Enum.Font.GothamBold
ProtectionToggle.TextScaled = true
ProtectionToggle.BackgroundColor3 = Color3.fromRGB(60, 130, 200)
ProtectionToggle.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", ProtectionToggle).CornerRadius = UDim.new(0, 14)

ProtectionToggle.MouseButton1Click:Connect(function()
    ProtectionEnabled = not ProtectionEnabled
    ProtectionToggle.Text = ProtectionEnabled and "Disable Protection" or "Enable Protection"
end)

-- CLOSE & MINIMIZE
CloseButton = Instance.new("TextButton")
CloseButton.Parent = Main
CloseButton.Size = UDim2.fromScale(0.12, 0.18)
CloseButton.Position = UDim2.fromScale(0.88, 0)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextScaled = true
CloseButton.BackgroundColor3 = Color3.fromRGB(190, 60, 60)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 12)
CloseButton.MouseButton1Click:Connect(ShutdownFramework)

MinimizeButton = Instance.new("TextButton")
MinimizeButton.Parent = Main
MinimizeButton.Size = UDim2.fromScale(0.12, 0.18)
MinimizeButton.Position = UDim2.fromScale(0.76, 0)
MinimizeButton.Text = "—"
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextScaled = true
MinimizeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 12)

-- FLOATING BUTTON
FloatingButton = Instance.new("TextButton")
FloatingButton.Parent = ScreenGui
FloatingButton.Size = UDim2.fromScale(0.12, 0.12)
FloatingButton.Position = UDim2.fromScale(0.85, 0.65)
FloatingButton.Text = "🛡"
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.TextScaled = true
FloatingButton.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
FloatingButton.TextColor3 = Color3.fromRGB(230, 230, 230)
FloatingButton.AutoButtonColor = true
FloatingButton.Visible = false
FloatingButton.Active = true
FloatingButton.Draggable = true
Instance.new("UICorner", FloatingButton).CornerRadius = UDim.new(1, 0)

local FloatGradient = Instance.new("UIGradient", FloatingButton)
FloatGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 120, 220)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 70, 160))
}
FloatGradient.Rotation = 45

-- OPEN / CLOSE UI
UIVisible = true
local function ToggleUI()
    UIVisible = not UIVisible
    Main.Visible = UIVisible
    FloatingButton.Visible = not UIVisible
end

FloatingButton.MouseButton1Click:Connect(ToggleUI)
MinimizeButton.MouseButton1Click:Connect(ToggleUI)

-- FPS MONITOR
Connections.FPS = RunService.Heartbeat:Connect(function(dt)
    if not ScriptRunning then return end
    local fps = math.floor(1 / dt)
    InfoLabel.Text = "FPS: " .. fps .. " | Status: " .. (ProtectionEnabled and "ACTIVE" or "OFF")
end)

-- Indica que Core terminó de inicializar y las variables UI/globales están listas
CoreReady = true
print("✅ Core module fully ready - UI Pro")
