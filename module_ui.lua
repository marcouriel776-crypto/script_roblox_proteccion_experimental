-- module_ui.lua (UPF-connected Neon Pro)
local UPF = _G.UPF
if not UPF then warn("UPF missing"); return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- remove old copy if any
if PlayerGui:FindFirstChild("ProtectionUI") then
    PlayerGui.ProtectionUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProtectionUI"
ScreenGui.Parent = PlayerGui

-- Main (layout simplified)
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromScale(0.48, 0.54)
Main.Position = UDim2.fromScale(0.26, 0.23)
Main.AnchorPoint = Vector2.new(0,0)
Main.BackgroundColor3 = Color3.fromRGB(18,18,30)
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,18)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(100,80,220)

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1,0,0,56)
Header.Position = UDim2.new(0,0,0,0)
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0,18)

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.fromScale(1,1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "🛡 Universal Protection"
Title.TextScaled = true
Title.TextColor3 = Color3.fromRGB(230,230,240)

local Info = Instance.new("TextLabel")
Info.Parent = Main
Info.Size = UDim2.new(1,0,0,24)
Info.Position = UDim2.fromScale(0,0.92)
Info.BackgroundTransparency = 1
Info.Font = Enum.Font.Gotham
Info.TextScaled = true
Info.TextColor3 = Color3.fromRGB(180,180,255)

local Content = Instance.new("ScrollingFrame")
Content.Parent = Main
Content.Position = UDim2.fromScale(0,0.13)
Content.Size = UDim2.fromScale(1,0.78)
Content.BackgroundTransparency = 1
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
local UIList = Instance.new("UIListLayout", Content)
UIList.Padding = UDim.new(0,10)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Expose UI root for modules
UPF.UI = UPF.UI or {}
UPF.UI.ScreenGui = ScreenGui
UPF.UI.Main = Main
UPF.UI.Content = Content
UPF.UI.InfoLabel = Info

-- FPS / Status update
local last = tick()
RunService.Heartbeat:Connect(function(dt)
    if not UPF.State.ScriptRunning then return end
    local now = tick()
    local fps = math.floor(1 / math.max(now - last, 1e-6))
    last = now
    local status = UPF.State.ProtectionEnabled and "ACTIVE" or "OFF"
    Info.Text = "FPS: "..fps.." | Status: "..status
end)

-- Enable button (main)
local enableBtn = Instance.new("TextButton")
enableBtn.Size = UDim2.fromScale(0.8, 0.12)
enableBtn.Parent = Content
enableBtn.Font = Enum.Font.GothamBold
enableBtn.TextScaled = true
enableBtn.BackgroundColor3 = Color3.fromRGB(70,100,255)
enableBtn.TextColor3 = Color3.fromRGB(1,1,1)
local uc = Instance.new("UICorner", enableBtn)

local function updateEnableBtn()
    if UPF.State.ProtectionEnabled then
        enableBtn.Text = "Disable Protection"
        enableBtn.BackgroundColor3 = Color3.fromRGB(200,70,90)
    else
        enableBtn.Text = "Enable Protection"
        enableBtn.BackgroundColor3 = Color3.fromRGB(70,100,255)
    end
end
updateEnableBtn()

enableBtn.MouseButton1Click:Connect(function()
    UPF:ToggleProtection()
    updateEnableBtn()
end)

print("✅ UI module ready and exposed at UPF.UI")