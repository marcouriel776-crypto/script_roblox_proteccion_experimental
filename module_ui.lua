-- module_ui.lua
-- Universal Protection - Robust UI (close/minimize/drag + floating button)
-- Designed to be defensive and compatible with CoreGui and PlayerGui.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- ensure UPF table
_G.UPF = _G.UPF or {}
local UPF = _G.UPF

-- avoid duplicate GUIs: destroy previous ProtectionUI in PlayerGui/CoreGui
local function safe_find_and_destroy(name)
    pcall(function()
        if LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
        if CoreGui:FindFirstChild(name) then
            CoreGui[name]:Destroy()
        end
    end)
end
safe_find_and_destroy("ProtectionUI")

-- Create ScreenGui in PlayerGui (preferred) but fall back to CoreGui
local parentGui = LocalPlayer:FindFirstChild("PlayerGui") or CoreGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProtectionUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentGui

-- MAIN FRAME
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromScale(0.5, 0.32)
Main.Position = UDim2.fromScale(0.25, 0.34)
Main.BackgroundColor3 = Color3.fromRGB(18,18,30)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
local UICor = Instance.new("UICorner", Main); UICor.CornerRadius = UDim.new(0,12)

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1,0,0,48)
Header.Position = UDim2.new(0,0,0,0)
Header.BackgroundColor3 = Color3.fromRGB(30,30,44)
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(240,240,240)
Title.Text = "Universal Protection"
Title.Parent = Header

-- Control buttons
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0,40,0,32)
CloseButton.Position = UDim2.new(1, -48, 0, 8)
CloseButton.Text = "✕"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 20
CloseButton.BackgroundColor3 = Color3.fromRGB(180,60,60)
CloseButton.TextColor3 = Color3.new(1,1,1)
CloseButton.Parent = Header
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0,8)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0,40,0,32)
MinimizeButton.Position = UDim2.new(1, -96, 0, 8)
MinimizeButton.Text = "—"
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 20
MinimizeButton.BackgroundColor3 = Color3.fromRGB(70,70,80)
MinimizeButton.TextColor3 = Color3.new(1,1,1)
MinimizeButton.Parent = Header
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0,8)

-- Content
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Position = UDim2.new(0, 0, 0, 48)
Content.Size = UDim2.new(1, 0, 1, -48)
Content.BackgroundTransparency = 1
Content.Parent = Main

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Name = "InfoLabel"
InfoLabel.Size = UDim2.new(1,0,0,28)
InfoLabel.Position = UDim2.new(0,0,0,8)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 16
InfoLabel.TextColor3 = Color3.fromRGB(180,180,220)
InfoLabel.Text = "FPS: -- | Status: OFF"
InfoLabel.TextScaled = false
InfoLabel.Parent = Content

-- Protection Toggle (example button, you can map to ProtectionEnabled)
local ProtectionToggle = Instance.new("TextButton")
ProtectionToggle.Name = "ProtectionToggle"
ProtectionToggle.Size = UDim2.new(0.6,0,0,42)
ProtectionToggle.Position = UDim2.new(0.2,0,0,52)
ProtectionToggle.Text = "Enable Protection"
ProtectionToggle.Font = Enum.Font.GothamBold
ProtectionToggle.TextSize = 18
ProtectionToggle.TextColor3 = Color3.fromRGB(255,255,255)
ProtectionToggle.BackgroundColor3 = Color3.fromRGB(70,100,255)
ProtectionToggle.Parent = Content
Instance.new("UICorner", ProtectionToggle).CornerRadius = UDim.new(0,18)

-- Floating Button (restaurador cuando minimizado)
local FloatingButton = Instance.new("TextButton")
FloatingButton.Name = "FloatingButton"
FloatingButton.Size = UDim2.fromOffset(60,60)
FloatingButton.Position = UDim2.fromScale(0.88, 0.78)
FloatingButton.AnchorPoint = Vector2.new(0.5,0.5)
FloatingButton.Text = "UP"
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.TextSize = 16
FloatingButton.BackgroundColor3 = Color3.fromRGB(120,80,255)
FloatingButton.TextColor3 = Color3.new(1,1,1)
FloatingButton.Visible = false
FloatingButton.Parent = ScreenGui
Instance.new("UICorner", FloatingButton).CornerRadius = UDim.new(1,0)

-- Ensure single connection to RenderStepped for FPS display
local lastRender = tick()
local function updateInfo()
    local dt = math.max(1/60, (tick() - lastRender))
    lastRender = tick()
    local fps = math.floor(1 / dt)
    local status = (UPF and UPF.ProtectionEnabled) and "ACTIVE" or "OFF"
    pcall(function() InfoLabel.Text = "FPS: "..tostring(fps).." | Status: "..status end)
end
RunService.RenderStepped:Connect(updateInfo)

-- Protection toggle behavior (connect to global flag if exists)
if UPF.ProtectionEnabled == nil then UPF.ProtectionEnabled = false end
ProtectionToggle.MouseButton1Click:Connect(function()
    UPF.ProtectionEnabled = not UPF.ProtectionEnabled
    ProtectionToggle.Text = UPF.ProtectionEnabled and "Disable Protection" or "Enable Protection"
    ProtectionToggle.BackgroundColor3 = UPF.ProtectionEnabled and Color3.fromRGB(200,70,90) or Color3.fromRGB(70,100,255)
    -- persist settings if SaveUPFSettings exists
    if type(UPF.SaveUPFSettings) == "function" then pcall(UPF.SaveUPFSettings) end
end)

-- Close and Minimize handlers
CloseButton.MouseButton1Click:Connect(function()
    pcall(function() ScreenGui:Destroy() end)
end)

MinimizeButton.MouseButton1Click:Connect(function()
    Main.Visible = false
    FloatingButton.Visible = true
end)

FloatingButton.MouseButton1Click:Connect(function()
    Main.Visible = true
    FloatingButton.Visible = false
end)

-- Drag implementation (works on mouse)
do
    local dragging = false
    local dragStart = Vector2.new(0,0)
    local startPos = Main.Position

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    Header.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newX = startPos.X.Offset + delta.X
            local newY = startPos.Y.Offset + delta.Y
            Main.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        end
    end)
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Safe initialization message
print("✅ module_ui loaded - UI ready")