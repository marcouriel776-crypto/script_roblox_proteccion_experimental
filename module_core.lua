-- =========================================================
-- module_core.lua
-- Universal Protection Framework - Core + UI Base
-- Android / Delta friendly
-- =========================================================

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- =========================================================
-- GLOBAL STATE (usado por otros módulos)
-- =========================================================
ScriptRunning = true

ProtectionEnabled = false
ProtectionManualOverride = nil  -- nil = sin override, true = forzado ON, false = forzado OFF

AutoReturnEnabled = (AutoReturnEnabled == nil) and true or AutoReturnEnabled
ReturnCooldown = ReturnCooldown or 5
LastAutoReturn = LastAutoReturn or 0

Connections = Connections or {}

Character = nil
Humanoid = nil
RootPart = nil

-- =========================================================
-- CHARACTER HANDLER
-- =========================================================
local function UpdateCharacter(char)
    Character = char
    Humanoid = char:FindFirstChild("Humanoid") or char:WaitForChild("Humanoid", 5)
    RootPart = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
end

if LocalPlayer.Character then
    UpdateCharacter(LocalPlayer.Character)
end

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(UpdateCharacter)

-- =========================================================
-- SHUTDOWN
-- =========================================================
local function ShutdownFramework()
    ScriptRunning = false
    ProtectionEnabled = false

    for _, c in pairs(Connections) do
        pcall(function()
            if typeof(c) == "RBXScriptConnection" then
                c:Disconnect()
            end
        end)
    end

    if CoreGui:FindFirstChild("ProtectionUI") then
        CoreGui.ProtectionUI:Destroy()
    end
end

-- =========================================================
-- UI CREATION
-- =========================================================

-- Remove previous UI if exists
if CoreGui:FindFirstChild("ProtectionUI") then
    CoreGui.ProtectionUI:Destroy()
end

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProtectionUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Main Window
Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.Size = UDim2.fromScale(0.55, 0.35)
Main.Position = UDim2.fromScale(0.225, 0.33)
Main.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

-- Gradient background
local MainGradient = Instance.new("UIGradient")
MainGradient.Parent = Main
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 32, 48)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 20, 30))
}
MainGradient.Rotation = 90

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = Main
Header.Size = UDim2.fromScale(1, 0.18)
Header.BackgroundColor3 = Color3.fromRGB(35, 45, 85)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Parent = Header
HeaderGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 60, 120)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 40, 90))
}

TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = Header
TitleLabel.Size = UDim2.fromScale(1, 1)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🛡 Universal Protection Framework"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextScaled = true
TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)

-- Content (ScrollingFrame)
Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Parent = Main
Content.Position = UDim2.fromScale(0, 0.18)
Content.Size = UDim2.fromScale(1, 0.82)
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.ScrollBarImageTransparency = 0.3
Content.ScrollBarThickness = 6
Content.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout")
UIList.Parent = Content
UIList.Padding = UDim.new(0, 12)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- =========================================================
-- BASIC UI ELEMENTS
-- =========================================================

-- Info label (FPS / Status)
InfoLabel = Instance.new("TextLabel")
InfoLabel.Name = "InfoLabel"
InfoLabel.Parent = Content
InfoLabel.Size = UDim2.fromScale(0.9, 0.12)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextScaled = true
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
InfoLabel.Text = "FPS: -- | Status: OFF"

-- Protection Toggle
ProtectionToggle = Instance.new("TextButton")
ProtectionToggle.Name = "ProtectionToggle"
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
    ProtectionManualOverride = ProtectionEnabled and true or false
    ProtectionToggle.Text = ProtectionEnabled and "Disable Protection" or "Enable Protection"
end)

-- =========================================================
-- WINDOW CONTROLS
-- =========================================================

-- Close Button
CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
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

-- Minimize Button
MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = Main
MinimizeButton.Size = UDim2.fromScale(0.12, 0.18)
MinimizeButton.Position = UDim2.fromScale(0.76, 0)
MinimizeButton.Text = "—"
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextScaled = true
MinimizeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 12)

-- Floating Button
FloatingButton = Instance.new("TextButton")
FloatingButton.Name = "FloatingButton"
FloatingButton.Parent = ScreenGui
FloatingButton.Size = UDim2.fromScale(0.12, 0.12)
FloatingButton.Position = UDim2.fromScale(0.85, 0.65)
FloatingButton.Text = "🛡"
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.TextScaled = true
FloatingButton.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
FloatingButton.TextColor3 = Color3.fromRGB(230, 230, 230)
FloatingButton.Visible = false
FloatingButton.Active = true
FloatingButton.Draggable = true
Instance.new("UICorner", FloatingButton).CornerRadius = UDim.new(1, 0)

-- Toggle UI visibility
local UIVisible = true
local function ToggleUI()
    UIVisible = not UIVisible
    Main.Visible = UIVisible
    FloatingButton.Visible = not UIVisible
end

MinimizeButton.MouseButton1Click:Connect(ToggleUI)
FloatingButton.MouseButton1Click:Connect(ToggleUI)

-- =========================================================
-- FPS MONITOR
-- =========================================================
Connections.FPS = RunService.Heartbeat:Connect(function(dt)
    if not ScriptRunning then return end
    local fps = math.floor(1 / math.max(dt, 1e-6))
    InfoLabel.Text = "FPS: " .. fps .. " | Status: " .. (ProtectionEnabled and "ACTIVE" or "OFF")
end)

-- =========================================================
-- CORE READY
-- =========================================================
CoreReady = true
print("✅ Core module fully ready - UI Pro")