-- module_ui.lua (FINAL CLEAN - MOBILE SAFE)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- =========================
-- GUI ROOT
-- =========================

local gui = Instance.new("ScreenGui")
gui.Name = "UPF_UI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- =========================
-- MAIN FRAME
-- =========================

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 300)
frame.Position = UDim2.new(0.5, -130, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- =========================
-- TITLE BAR (DRAG)
-- =========================

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "UPF PANEL"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Parent = frame

-- =========================
-- DRAG SYSTEM (PC + MOBILE)
-- =========================

local dragging, dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	frame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		
		dragging = true
		dragStart = input.Position
		startPos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

title.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- =========================
-- BUTTON CONTAINER
-- =========================

local container = Instance.new("Frame")
container.Size = UDim2.new(1, 0, 1, -50)
container.Position = UDim2.new(0, 0, 0, 45)
container.BackgroundTransparency = 1
container.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Parent = container
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- =========================
-- TOGGLE BUTTON CREATOR
-- =========================

local function createToggle(name, callback)
	local state = false

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.8, 0, 0, 45)
	btn.Text = name .. " [OFF]"
	btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Parent = container

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

	btn.MouseButton1Click:Connect(function()
		state = not state

		if state then
			btn.Text = name .. " [ON]"
			btn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
		else
			btn.Text = name .. " [OFF]"
			btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		end

		if callback then
			callback(state)
		end
	end)

	return btn
end

-- =========================
-- BUTTONS
-- =========================

createToggle("Protection", function(v)
	if _G.UPF and _G.UPF.API then
		_G.UPF.API:ToggleProtection(v)
	end
end)

createToggle("God Mode", function(v)
	if _G.UPF and _G.UPF.API then
		_G.UPF.API:ToggleGodMode(v)
	end
end)

local returnBtn = Instance.new("TextButton")
returnBtn.Size = UDim2.new(0.8, 0, 0, 45)
returnBtn.Text = "Return Safe"
returnBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
returnBtn.TextColor3 = Color3.new(1,1,1)
returnBtn.Parent = container
Instance.new("UICorner", returnBtn)

returnBtn.MouseButton1Click:Connect(function()
	if _G.UPF and _G.UPF.API then
		_G.UPF.API:ReturnToSafePoint()
	end
end)

createToggle("Audio Shield", function(v)
	if _G.UPF and _G.UPF.API then
		_G.UPF.API:ToggleAudioShield(v)
	end
end)

-- =========================
-- CLOSE BUTTON (KILL SCRIPT)
-- =========================

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
close.TextColor3 = Color3.new(1,1,1)
close.Parent = frame

close.MouseButton1Click:Connect(function()
	if _G.UPF then
		_G.UPF.Enabled = false
	end

	gui:Destroy()
end)

-- =========================
-- FLOATING BUTTON (OPEN/CLOSE UI)
-- =========================

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
toggleBtn.Text = "UPF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Parent = gui

Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

local uiVisible = true

toggleBtn.MouseButton1Click:Connect(function()
	uiVisible = not uiVisible
	frame.Visible = uiVisible
end)

-- =========================
-- DRAG FLOAT BUTTON
-- =========================

local draggingBtn, dragInputBtn, dragStartBtn, startPosBtn

local function updateBtn(input)
	local delta = input.Position - dragStartBtn
	toggleBtn.Position = UDim2.new(
		startPosBtn.X.Scale,
		startPosBtn.X.Offset + delta.X,
		startPosBtn.Y.Scale,
		startPosBtn.Y.Offset + delta.Y
	)
end

toggleBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
	or input.UserInputType == Enum.UserInputType.MouseButton1 then
		
		draggingBtn = true
		dragStartBtn = input.Position
		startPosBtn = toggleBtn.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				draggingBtn = false
			end
		end)
	end
end)

toggleBtn.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
	or input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInputBtn = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInputBtn and draggingBtn then
		updateBtn(input)
	end
end)

-- =========================
-- FPS COUNTER
-- =========================

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, 0, 0, 20)
fpsLabel.Position = UDim2.new(0, 0, 1, -20)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.new(1,1,1)
fpsLabel.Parent = frame

local last = tick()
local frames = 0

RunService.RenderStepped:Connect(function()
	frames += 1
	if tick() - last >= 1 then
		fpsLabel.Text = "FPS: " .. frames
		frames = 0
		last = tick()
	end
end)

print("✅ UPF UI loaded (mobile safe, draggable, toggleable)")