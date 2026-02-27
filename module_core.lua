-- =========================================================
-- MODULE CORE
-- Universal Protection Framework
-- Platform: Android / Delta
-- Version: 0.9.x (Core Stable)
-- =========================================================

-- ================= SERVICES =================
Players = game:GetService("Players")
RunService = game:GetService("RunService")
CoreGui = game:GetService("CoreGui")
UserInputService = game:GetService("UserInputService")

LocalPlayer = Players.LocalPlayer

-- ================= GLOBAL STATE =================
ScriptRunning = true
ProtectionEnabled = false
Connections = {}

-- Character refs (global, usados por otros módulos)
Character = nil
Humanoid = nil
RootPart = nil

-- ================= CHARACTER HANDLER =================
local function UpdateCharacter(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid", 5)
    RootPart = char:WaitForChild("HumanoidRootPart", 5)
end

if LocalPlayer.Character then
    UpdateCharacter(LocalPlayer.Character)
end

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(UpdateCharacter)

-- ================= SHUTDOWN =================
function ShutdownFramework()
    ScriptRunning = false
    ProtectionEnabled = false

    for _, c in pairs(Connections) do
        pcall(function()
            c:Disconnect()
        end)
    end

    if CoreGui:FindFirstChild("ProtectionUI") then
        CoreGui.ProtectionUI:Destroy()
    end
end

-- ================= UI BASE =================
if CoreGui:FindFirstChild("ProtectionUI") then
    CoreGui.ProtectionUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProtectionUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

Main = Instance.new("Frame")
-- ================= HEADER =================
Header = Instance.new("Frame")
Header.Parent = Main
Header.Size = UDim2.fromScale(1, 0.18)
Header.BackgroundTransparency = 1

-- Title
TitleLabel.Parent = Header
TitleLabel.Position = UDim2.fromScale(0, 0)
TitleLabel.Size = UDim2.fromScale(1, 1)

-- ================= SCROLL CONTENT =================
Content = Instance.new("ScrollingFrame")
Content.Parent = Main
Content.Position = UDim2.fromScale(0, 0.18)
Content.Size = UDim2.fromScale(1, 0.82)
Content.CanvasSize = UDim2.new(0, 0, 2, 0) -- scroll vertical
Content.ScrollBarImageTransparency = 0.3
Content.ScrollBarThickness = 6
Content.BackgroundTransparency = 1
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
CreateSection("🛡 PROTECTION")

UIList = Instance.new("UIListLayout")
UIList.Parent = Content
UIList.Padding = UDim.new(0, 12)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
Main.Parent = ScreenGui
Main.Size = UDim2.fromScale(0.55, 0.30)
Main.Position = UDim2.fromScale(0.225, 0.35)
Main.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

-- ================= TITLE BAR =================
TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = Main
TitleLabel.Size = UDim2.fromScale(1, 0.18)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🛡 Universal Protection Framework"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextScaled = true
TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)

-- Close Button
CloseButton = Instance.new("TextButton")
CloseButton.Parent = Main
CloseButton.Size = UDim2.fromScale(0.12, 0.18)
CloseButton.Position = UDim2.fromScale(0.88, 0)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextScaled = true
CloseButton.BackgroundColor3 = Color3.fromRGB(170, 60, 60)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 12)

CloseButton.MouseButton1Click:Connect(ShutdownFramework)

-- Minimize Button
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

local Minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    Main.Size = Minimized
        and UDim2.fromScale(0.55, 0.08)
        or UDim2.fromScale(0.55, 0.30)
end)

-- ================= INFO LABEL (FPS + STATUS) =================
InfoLabel = Instance.new("TextLabel")
InfoLabel.Parent = Content
InfoLabel.Position = UDim2.fromScale(0.05, 0.22)
InfoLabel.Size = UDim2.fromScale(0.9, 0.15)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextScaled = true
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoLabel.Text = "FPS: -- | Status: OFF"

-- ================= PROTECTION TOGGLE =================
ProtectionToggle = Instance.new("TextButton")
ProtectionToggle.Parent = Content
ProtectionToggle.Position = UDim2.fromScale(0.2, 0.42)
ProtectionToggle.Size = UDim2.fromScale(0.6, 0.20)
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

-- ================= FPS MONITOR =================
Connections.FPS = RunService.Heartbeat:Connect(function(dt)
    if not ScriptRunning then return end

    local fps = math.floor(1 / dt)
    InfoLabel.Text = "FPS: " .. fps .. " | Status: " .. (ProtectionEnabled and "ACTIVE" or "OFF")
end)

-- ================= CORE READY =================
print("✅ Core module loaded successfully")
-- ================= SECTION HELPER =================
function CreateSection(title)
    local Section = Instance.new("TextLabel")
    Section.Parent = Content
    Section.Size = UDim2.fromScale(0.9, 0.06)
    Section.BackgroundTransparency = 1
    Section.Text = title
    Section.Font = Enum.Font.GothamBold
    Section.TextScaled = true
    Section.TextColor3 = Color3.fromRGB(180, 180, 180)
    Section.TextXAlignment = Enum.TextXAlignment.Left
    return Section
end
