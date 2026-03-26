-- module_ui.lua
-- UPF classic UI: simple, clean, draggable, minimize/close, floating restore.
-- No autorejoin. No teleport logic.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

UPF.State = UPF.State or {}
UPF.Settings = UPF.Settings or {}
UPF.Connections = UPF.Connections or {}

UPF.State.ProtectionEnabled = UPF.State.ProtectionEnabled or false
UPF.State.GodMode = UPF.State.GodMode or false
UPF.State.AutoReturnEnabled = (UPF.State.AutoReturnEnabled == nil) and true or UPF.State.AutoReturnEnabled
UPF.State.AudioShieldEnabled = UPF.State.AudioShieldEnabled or false

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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProtectionUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = playerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromScale(0.42, 0.30)
Main.Position = UDim2.fromScale(0.29, 0.34)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1
MainStroke.Color = Color3.fromRGB(100, 80, 220)
MainStroke.Transparency = 0.55
MainStroke.Parent = Main

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -130, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.Text = "Universal Protection"
Title.Parent = Header

local function makeHeaderButton(text, xOffset, bg)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(30, 26)
	btn.Position = UDim2.new(1, xOffset, 0, 8)
	btn.BackgroundColor3 = bg
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Parent = Header
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	return btn
end

local CloseButton = makeHeaderButton("✕", -38, Color3.fromRGB(190, 60, 60))
CloseButton.Name = "CloseButton"

local MinimizeButton = makeHeaderButton("—", -72, Color3.fromRGB(70, 70, 86))
MinimizeButton.Name = "MinimizeButton"

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Position = UDim2.new(0, 0, 0, 42)
Content.Size = UDim2.new(1, 0, 1, -42)
Content.BackgroundTransparency = 1
Content.Parent = Main

local UIList = Instance.new("UIListLayout")
UIList.Parent = Content
UIList.Padding = UDim.new(0, 8)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.SortOrder = Enum.SortOrder.LayoutOrder

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Name = "InfoLabel"
InfoLabel.Size = UDim2.new(0.92, 0, 0, 22)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 14
InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 210)
InfoLabel.Text = "FPS: -- | Status: OFF"
InfoLabel.LayoutOrder = 1
InfoLabel.Parent = Content

local function makeMainButton(name, text, bg)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0.72, 0, 0, 34)
	btn.BackgroundColor3 = bg
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 15
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.LayoutOrder = (#Content:GetChildren() + 1)
	btn.Parent = Content
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
	return btn
end

local ProtectionButton = makeMainButton("ProtectionButton", "Enable Protection", Color3.fromRGB(70, 100, 240))
local GodButton = makeMainButton("GodButton", "God Mode: OFF", Color3.fromRGB(120, 70, 70))
local ReturnButton = makeMainButton("ReturnButton", "Return to Safe Point", Color3.fromRGB(70, 150, 120))
local AudioButton = makeMainButton("AudioButton", "Audio Shield: OFF", Color3.fromRGB(110, 110, 150))

local FloatingButton = Instance.new("TextButton")
FloatingButton.Name = "FloatingButton"
FloatingButton.Size = UDim2.fromOffset(54, 54)
FloatingButton.Position = UDim2.fromScale(0.90, 0.80)
FloatingButton.AnchorPoint = Vector2.new(0.5, 0.5)
FloatingButton.BackgroundColor3 = Color3.fromRGB(120, 80, 255)
FloatingButton.Text = "UP"
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.TextSize = 16
FloatingButton.TextColor3 = Color3.new(1, 1, 1)
FloatingButton.Visible = false
FloatingButton.Parent = ScreenGui
Instance.new("UICorner", FloatingButton).CornerRadius = UDim.new(1, 0)

local function updateProtection()
	if UPF.State.ProtectionEnabled then
		ProtectionButton.Text = "Disable Protection"
		ProtectionButton.BackgroundColor3 = Color3.fromRGB(190, 70, 80)
	else
		ProtectionButton.Text = "Enable Protection"
		ProtectionButton.BackgroundColor3 = Color3.fromRGB(70, 100, 240)
	end
end

local function updateGod()
	GodButton.Text = UPF.State.GodMode and "God Mode: ON" or "God Mode: OFF"
	GodButton.BackgroundColor3 = UPF.State.GodMode and Color3.fromRGB(60, 160, 90) or Color3.fromRGB(120, 70, 70)
end

local function updateAudio()
	AudioButton.Text = UPF.State.AudioShieldEnabled and "Audio Shield: ON" or "Audio Shield: OFF"
	AudioButton.BackgroundColor3 = UPF.State.AudioShieldEnabled and Color3.fromRGB(60, 160, 90) or Color3.fromRGB(110, 110, 150)
end

local function updateStatus()
	local fps = UPF.State.FPS or "--"
	local status = UPF.State.ProtectionEnabled and "ACTIVE" or "OFF"
	InfoLabel.Text = "FPS: " .. tostring(fps) .. " | Status: " .. status
end

updateProtection()
updateGod()
updateAudio()
updateStatus()

ProtectionButton.MouseButton1Click:Connect(function()
	UPF.State.ProtectionEnabled = not UPF.State.ProtectionEnabled
	updateProtection()

	if type(UPF.ToggleProtection) == "function" then
		pcall(function() UPF:ToggleProtection(UPF.State.ProtectionEnabled) end)
	end

	if type(UPF.SaveSettings) == "function" then
		pcall(function() UPF:SaveSettings() end)
	end
end)

GodButton.MouseButton1Click:Connect(function()
	if type(UPF.ToggleGodMode) == "function" then
		pcall(function() UPF:ToggleGodMode() end)
		UPF.State.GodMode = not not UPF.State.GodMode
	else
		UPF.State.GodMode = not UPF.State.GodMode
	end
	updateGod()

	if type(UPF.SaveSettings) == "function" then
		pcall(function() UPF:SaveSettings() end)
	end
end)

ReturnButton.MouseButton1Click:Connect(function()
	if type(UPF.ReturnToSafePoint) == "function" then
		pcall(function() UPF:ReturnToSafePoint() end)
	end
end)

AudioButton.MouseButton1Click:Connect(function()
	UPF.State.AudioShieldEnabled = not UPF.State.AudioShieldEnabled
	updateAudio()

	if type(UPF.ToggleAudioShield) == "function" then
		pcall(function() UPF:ToggleAudioShield(UPF.State.AudioShieldEnabled) end)
	end

	if type(UPF.SaveSettings) == "function" then
		pcall(function() UPF:SaveSettings() end)
	end
end)

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

do
	local dragging = false
	local dragStart = Vector2.new()
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
end

UPF.UI = UPF.UI or {}
UPF.UI.ScreenGui = ScreenGui
UPF.UI.Main = Main
UPF.UI.Header = Header
UPF.UI.Content = Content
UPF.UI.InfoLabel = InfoLabel
UPF.UI.Update = function()
	updateProtection()
	updateGod()
	updateAudio()
	updateStatus()
end

UPF.Connections.UIStatus = RunService.RenderStepped:Connect(function(dt)
	UPF.State.FPS = math.floor(1 / math.max(dt, 1 / 240))
	updateStatus()
end)

print("✅ module_ui loaded")