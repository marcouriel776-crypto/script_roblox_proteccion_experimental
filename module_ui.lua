-- module_ui.lua
-- Universal Protection UI FULL

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local UPF = _G.UPF
if not UPF then
    warn("UPF not initialized")
    return
end

--------------------------------------------------
-- PREVENT DUPLICATES
--------------------------------------------------

if PlayerGui:FindFirstChild("ProtectionUI") then
    PlayerGui.ProtectionUI:Destroy()
end

--------------------------------------------------
-- SCREEN
--------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProtectionUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

--------------------------------------------------
-- MAIN WINDOW
--------------------------------------------------

local Main = Instance.new("Frame")
Main.Size = UDim2.fromScale(0.42,0.48)
Main.Position = UDim2.fromScale(0.5,0.45)
Main.AnchorPoint = Vector2.new(0.5,0.5)
Main.BackgroundColor3 = Color3.fromRGB(20,20,35)
Main.Parent = ScreenGui

Instance.new("UICorner",Main).CornerRadius = UDim.new(0,18)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(110,80,255)
Stroke.Thickness = 2
Stroke.Parent = Main

--------------------------------------------------
-- HEADER
--------------------------------------------------

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,50)
Header.BackgroundColor3 = Color3.fromRGB(30,30,50)
Header.Parent = Main

Instance.new("UICorner",Header).CornerRadius = UDim.new(0,18)

local Title = Instance.new("TextLabel")
Title.Text = "🛡 Universal Protection"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1,0,1,0)
Title.Parent = Header

--------------------------------------------------
-- CLOSE BUTTON
--------------------------------------------------

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(30,30)
Close.Position = UDim2.new(1,-35,0,10)
Close.Text = "X"
Close.Font = Enum.Font.GothamBold
Close.TextColor3 = Color3.new(1,1,1)
Close.BackgroundColor3 = Color3.fromRGB(200,60,60)
Close.Parent = Header

Instance.new("UICorner",Close)

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

--------------------------------------------------
-- MINIMIZE
--------------------------------------------------

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(30,30)
Minimize.Position = UDim2.new(1,-70,0,10)
Minimize.Text = "-"
Minimize.Font = Enum.Font.GothamBold
Minimize.TextColor3 = Color3.new(1,1,1)
Minimize.BackgroundColor3 = Color3.fromRGB(80,80,120)
Minimize.Parent = Header

Instance.new("UICorner",Minimize)

local Floating = Instance.new("TextButton")
Floating.Size = UDim2.fromOffset(60,60)
Floating.Position = UDim2.fromScale(0.9,0.8)
Floating.Text = "UP"
Floating.Font = Enum.Font.GothamBold
Floating.TextColor3 = Color3.new(1,1,1)
Floating.BackgroundColor3 = Color3.fromRGB(110,80,255)
Floating.Visible = false
Floating.Parent = ScreenGui

Instance.new("UICorner",Floating).CornerRadius = UDim.new(1,0)

Minimize.MouseButton1Click:Connect(function()
    Main.Visible = false
    Floating.Visible = true
end)

Floating.MouseButton1Click:Connect(function()
    Main.Visible = true
    Floating.Visible = false
end)

--------------------------------------------------
-- CONTENT
--------------------------------------------------

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,0,1,-90)
Content.Position = UDim2.new(0,0,0,60)
Content.BackgroundTransparency = 1
Content.Parent = Main

--------------------------------------------------
-- PROTECTION BUTTON
--------------------------------------------------

local ProtectionBtn = Instance.new("TextButton")
ProtectionBtn.Size = UDim2.fromScale(0.7,0.12)
ProtectionBtn.Position = UDim2.fromScale(0.15,0.05)
ProtectionBtn.Font = Enum.Font.GothamBold
ProtectionBtn.TextColor3 = Color3.new(1,1,1)
ProtectionBtn.Parent = Content

Instance.new("UICorner",ProtectionBtn)

local function updateProtection()
    if UPF.State.ProtectionEnabled then
        ProtectionBtn.Text = "Disable Protection"
        ProtectionBtn.BackgroundColor3 = Color3.fromRGB(200,70,80)
    else
        ProtectionBtn.Text = "Enable Protection"
        ProtectionBtn.BackgroundColor3 = Color3.fromRGB(70,120,255)
    end
end

updateProtection()

ProtectionBtn.MouseButton1Click:Connect(function()
    UPF:ToggleProtection()
    updateProtection()
end)

--------------------------------------------------
-- GOD MODE BUTTON
--------------------------------------------------

local GodBtn = Instance.new("TextButton")
GodBtn.Size = UDim2.fromScale(0.7,0.12)
GodBtn.Position = UDim2.fromScale(0.15,0.23)
GodBtn.Text = "Toggle God Mode"
GodBtn.Font = Enum.Font.GothamBold
GodBtn.TextColor3 = Color3.new(1,1,1)
GodBtn.BackgroundColor3 = Color3.fromRGB(80,180,90)
GodBtn.Parent = Content

Instance.new("UICorner",GodBtn)

GodBtn.MouseButton1Click:Connect(function()
    UPF:ToggleGodMode()
end)

--------------------------------------------------
-- RETURN BUTTON
--------------------------------------------------

local ReturnBtn = Instance.new("TextButton")
ReturnBtn.Size = UDim2.fromScale(0.7,0.12)
ReturnBtn.Position = UDim2.fromScale(0.15,0.41)
ReturnBtn.Text = "Return To Safe Point"
ReturnBtn.Font = Enum.Font.GothamBold
ReturnBtn.TextColor3 = Color3.new(1,1,1)
ReturnBtn.BackgroundColor3 = Color3.fromRGB(70,170,140)
ReturnBtn.Parent = Content

Instance.new("UICorner",ReturnBtn)

ReturnBtn.MouseButton1Click:Connect(function()
    UPF:ReturnToSafePoint()
end)

--------------------------------------------------
-- AUDIO SHIELD
--------------------------------------------------

local AudioBtn = Instance.new("TextButton")
AudioBtn.Size = UDim2.fromScale(0.7,0.12)
AudioBtn.Position = UDim2.fromScale(0.15,0.59)
AudioBtn.Text = "Toggle Audio Shield"
AudioBtn.Font = Enum.Font.GothamBold
AudioBtn.TextColor3 = Color3.new(1,1,1)
AudioBtn.BackgroundColor3 = Color3.fromRGB(120,120,220)
AudioBtn.Parent = Content

Instance.new("UICorner",AudioBtn)

AudioBtn.MouseButton1Click:Connect(function()
    UPF:ToggleAudioShield()
end)

--------------------------------------------------
-- STATUS LABEL
--------------------------------------------------

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1,0,0,30)
Status.Position = UDim2.new(0,0,1,-30)
Status.BackgroundTransparency = 1
Status.Font = Enum.Font.Gotham
Status.TextSize = 16
Status.TextColor3 = Color3.fromRGB(180,180,255)
Status.Parent = Main

local last = tick()

RunService.RenderStepped:Connect(function()

    local now = tick()
    local fps = math.floor(1/(now-last))
    last = now

    local state = UPF.State.ProtectionEnabled and "ACTIVE" or "OFF"

    Status.Text = "FPS: "..fps.." | Status: "..state

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

    end

end)

Header.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end

end)

print("✅ Universal Protection UI Loaded")