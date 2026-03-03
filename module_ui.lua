-- module_ui.lua
-- Universal Protection - Neon Pro UI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local module = {}

--------------------------------------------------
-- CREAR GUI
--------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProtectionUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

--------------------------------------------------
-- SOMBRA
--------------------------------------------------

local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.fromScale(0.42, 0.5)
Shadow.Position = UDim2.fromScale(0.5, 0.5)
Shadow.AnchorPoint = Vector2.new(0.5,0.5)
Shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
Shadow.BackgroundTransparency = 0.6
Shadow.ZIndex = 0
Shadow.Parent = ScreenGui

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 24)
ShadowCorner.Parent = Shadow

--------------------------------------------------
-- MAIN WINDOW
--------------------------------------------------

local Main = Instance.new("Frame")
Main.Size = UDim2.fromScale(0.42, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2.new(0.5,0.5)
Main.BackgroundColor3 = Color3.fromRGB(18,18,30)
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 24)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(120, 80, 255)
Stroke.Parent = Main

--------------------------------------------------
-- HEADER
--------------------------------------------------

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,60)
Header.BackgroundColor3 = Color3.fromRGB(25,25,45)
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0,24)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,1,0)
Title.BackgroundTransparency = 1
Title.Text = "Universal Protection"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Parent = Header

--------------------------------------------------
-- FPS + STATUS
--------------------------------------------------

local Info = Instance.new("TextLabel")
Info.Position = UDim2.new(0,0,1,-35)
Info.Size = UDim2.new(1,0,0,30)
Info.BackgroundTransparency = 1
Info.Font = Enum.Font.Gotham
Info.TextSize = 16
Info.TextColor3 = Color3.fromRGB(160,160,255)
Info.Parent = Main

local protectionEnabled = false

RunService.RenderStepped:Connect(function()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local status = protectionEnabled and "ACTIVE" or "OFF"
    Info.Text = "FPS: "..fps.." | Status: "..status
end)

--------------------------------------------------
-- CONTENT
--------------------------------------------------

local Content = Instance.new("Frame")
Content.Position = UDim2.new(0,0,0,70)
Content.Size = UDim2.new(1,0,1,-110)
Content.BackgroundTransparency = 1
Content.Parent = Main

--------------------------------------------------
-- ENABLE BUTTON
--------------------------------------------------

local EnableButton = Instance.new("TextButton")
EnableButton.Size = UDim2.new(0.6,0,0,45)
EnableButton.Position = UDim2.new(0.2,0,0.2,0)
EnableButton.Text = "Enable Protection"
EnableButton.Font = Enum.Font.GothamBold
EnableButton.TextSize = 18
EnableButton.TextColor3 = Color3.fromRGB(255,255,255)
EnableButton.BackgroundColor3 = Color3.fromRGB(70,100,255)
EnableButton.Parent = Content

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0,18)
ButtonCorner.Parent = EnableButton

EnableButton.MouseButton1Click:Connect(function()
    protectionEnabled = not protectionEnabled
    
    if protectionEnabled then
        EnableButton.Text = "Disable Protection"
        EnableButton.BackgroundColor3 = Color3.fromRGB(200,70,90)
    else
        EnableButton.Text = "Enable Protection"
        EnableButton.BackgroundColor3 = Color3.fromRGB(70,100,255)
    end
end)

--------------------------------------------------
-- MINIMIZE
--------------------------------------------------

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0,40,0,40)
Minimize.Position = UDim2.new(1,-90,0,10)
Minimize.Text = "-"
Minimize.Font = Enum.Font.GothamBold
Minimize.TextSize = 24
Minimize.TextColor3 = Color3.new(1,1,1)
Minimize.BackgroundColor3 = Color3.fromRGB(80,80,120)
Minimize.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(1,0)
MinCorner.Parent = Minimize

--------------------------------------------------
-- FLOAT BUTTON
--------------------------------------------------

local FloatButton = Instance.new("TextButton")
FloatButton.Size = UDim2.fromOffset(60,60)
FloatButton.Position = UDim2.fromScale(0.9,0.85)
FloatButton.Text = "UP"
FloatButton.Font = Enum.Font.GothamBold
FloatButton.TextSize = 16
FloatButton.TextColor3 = Color3.new(1,1,1)
FloatButton.BackgroundColor3 = Color3.fromRGB(120,80,255)
FloatButton.Visible = false
FloatButton.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1,0)
FloatCorner.Parent = FloatButton

--------------------------------------------------
-- MINIMIZE LOGIC
--------------------------------------------------

Minimize.MouseButton1Click:Connect(function()
    Main.Visible = false
    Shadow.Visible = false
    FloatButton.Visible = true
end)

FloatButton.MouseButton1Click:Connect(function()
    Main.Visible = true
    Shadow.Visible = true
    FloatButton.Visible = false
end)

--------------------------------------------------
-- DRAG SYSTEM
--------------------------------------------------

local dragging = false
local dragStart
local startPos

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
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        Shadow.Position = Main.Position
    end
end)

Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

--------------------------------------------------

return module