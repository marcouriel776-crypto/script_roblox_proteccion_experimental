-- module_ui.lua (FINAL FIXED)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

UPF.State = UPF.State or {}
UPF.Connections = UPF.Connections or {}

-- =========================
-- CLEANUP PREVIO
-- =========================

if UPF.Connections.UIStatus then
	pcall(function() UPF.Connections.UIStatus:Disconnect() end)
	UPF.Connections.UIStatus = nil
end

local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local function destroyIfExists(parent, name)
	if parent then
		local existing = parent:FindFirstChild(name)
		if existing then
			existing:Destroy()
		end
	end
end

destroyIfExists(playerGui, "ProtectionUI")
destroyIfExists(CoreGui, "ProtectionUI")

-- =========================
-- UI BASE
-- =========================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProtectionUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = playerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromScale(0.42, 0.30)
Main.Position = UDim2.fromScale(0.29, 0.34)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

local Content = Instance.new("Frame")
Content.Position = UDim2.new(0, 0, 0, 42)
Content.Size = UDim2.new(1, 0, 1, -42)
Content.BackgroundTransparency = 1
Content.Parent = Main

local UIList = Instance.new("UIListLayout")
UIList.Parent = Content
UIList.Padding = UDim.new(0, 8)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- =========================
-- ORDEN FIJO (FIX)
-- =========================

local ORDER = 0
local function nextOrder()
	ORDER += 1
	return ORDER
end

-- =========================
-- ELEMENTOS
-- =========================

local function makeButton(text, bg)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.72, 0, 0, 34)
	btn.BackgroundColor3 = bg
	btn.Text = text
	btn.LayoutOrder = nextOrder()
	btn.Parent = Content
	Instance.new("UICorner", btn)
	return btn
end

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(0.92, 0, 0, 22)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "FPS: --"
InfoLabel.LayoutOrder = nextOrder()
InfoLabel.Parent = Content

local ProtectionButton = makeButton("Enable Protection", Color3.fromRGB(70,100,240))
local GodButton = makeButton("God Mode", Color3.fromRGB(120,70,70))
local ReturnButton = makeButton("Return Safe", Color3.fromRGB(70,150,120))
local AudioButton = makeButton("Audio Shield", Color3.fromRGB(110,110,150))

-- =========================
-- LOGIC
-- =========================

local function update()
	InfoLabel.Text = "FPS: " .. tostring(UPF.State.FPS or "--")
end

ProtectionButton.MouseButton1Click:Connect(function()
	if UPF.ToggleProtection then
		UPF:ToggleProtection()
	end
end)

GodButton.MouseButton1Click:Connect(function()
	if UPF.ToggleGodMode then
		UPF:ToggleGodMode()
	end
end)

ReturnButton.MouseButton1Click:Connect(function()
	if UPF.ReturnToSafePoint then
		UPF:ReturnToSafePoint()
	end
end)

AudioButton.MouseButton1Click:Connect(function()
	if UPF.ToggleAudioShield then
		UPF:ToggleAudioShield()
	end
end)

-- =========================
-- LOOP
-- =========================

UPF.Connections.UIStatus = RunService.RenderStepped:Connect(function(dt)
	UPF.State.FPS = math.floor(1 / dt)
	update()
end)

print("✅ UI FIXED loaded")