local UPF = _G.UPF
local Assets = UPF.Assets
local Visual = UPF.Visual

local player = game.Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

-- =========================
-- GUI BASE
-- =========================

local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 380)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0

-- DRAG
local dragging, dragInput, startPos, startInputPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        startInputPos = input.Position
        startPos = frame.Position
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - startInputPos
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- =========================
-- TOP BAR
-- =========================

local top = Instance.new("Frame", frame)
top.Size = UDim2.new(1,0,0,30)
top.BackgroundColor3 = Color3.fromRGB(30,30,30)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,-60,1,0)
title.Text = "UPF PRO MAX"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

-- MINIMIZE
local minimized = false

local minBtn = Instance.new("TextButton", top)
minBtn.Size = UDim2.new(0,30,1,0)
minBtn.Position = UDim2.new(1,-60,0,0)
minBtn.Text = "_"

-- CLOSE
local closeBtn = Instance.new("TextButton", top)
closeBtn.Size = UDim2.new(0,30,1,0)
closeBtn.Position = UDim2.new(1,-30,0,0)
closeBtn.Text = "X"

-- =========================
-- SCROLL
-- =========================

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Position = UDim2.new(0,0,0,30)
scroll.Size = UDim2.new(1,0,1,-30)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,5)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)

-- =========================
-- BUTTON
-- =========================

local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,30)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BorderSizePixel = 0

    btn.MouseButton1Click:Connect(callback)
    btn.Parent = scroll
end

-- =========================
-- EFFECT STATE
-- =========================

local effectsEnabled = true
local rgbEnabled = false

createButton("🟢 Toggle Effects", function()
    effectsEnabled = not effectsEnabled

    if not effectsEnabled then
        Visual:Clear()
    end
end)

-- =========================
-- CLEAR
-- =========================

createButton("❌ Clear", function()
    Visual:Clear()
end)

-- =========================
-- PARTICLES
-- =========================

for i, p in ipairs(Assets.Particles) do
    if i > 25 then break end

    createButton("✨ Particle "..i, function()
        if effectsEnabled then
            Visual:ApplyParticle(p)
        end
    end)
end

-- =========================
-- SOUNDS
-- =========================

for i, s in ipairs(Assets.Sounds) do
    if i > 15 then break end

    createButton("🔊 Sound "..i, function()
        if effectsEnabled then
            Visual:PlaySound(s)
        end
    end)
end

-- =========================
-- 🌈 RGB CONTROL
-- =========================

createButton("🌈 Toggle RGB", function()
    rgbEnabled = not rgbEnabled

    if rgbEnabled then
        task.spawn(function()
            while rgbEnabled do
                Lighting.Ambient = Color3.fromHSV(tick()%5/5,1,1)
                task.wait(0.1)
            end
        end)
    else
        Lighting.Ambient = Color3.new(1,1,1)
    end
end)

-- =========================
-- 🌞 LIGHT MODES
-- =========================

createButton("🌞 Bright", function()
    Lighting.Brightness = 3
    Lighting.ClockTime = 14
end)

createButton("🌙 Dark", function()
    Lighting.Brightness = 1
    Lighting.ClockTime = 0
end)

createButton("⚡ Reset Light", function()
    Lighting.Brightness = 2
    Lighting.ClockTime = 12
    Lighting.Ambient = Color3.new(1,1,1)
end)

-- =========================
-- 😈 AURA GOD MODE
-- =========================

createButton("😈 AURA GOD", function()
    if not effectsEnabled then return end

    local root = UPF.Root
    if not root then return end

    Visual:Clear()

    -- PARTICLE
    if Assets.Particles[1] then
        Visual:ApplyParticle(Assets.Particles[1])
    end

    -- SOUND
    if Assets.Sounds[1] then
        Visual:PlaySound(Assets.Sounds[1])
    end

    -- LIGHT
    Lighting.Brightness = 4
    Lighting.Ambient = Color3.fromRGB(0, 255, 150)
end)

-- =========================
-- MIN / CLOSE LOGIC
-- =========================

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    scroll.Visible = not minimized
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

print("🔥 UI PRO MAX + GOD LOADED")
