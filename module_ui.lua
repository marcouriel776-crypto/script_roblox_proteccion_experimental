local UPF = _G.UPF
local Assets = UPF.Assets
local Visual = UPF.Visual

local player = game.Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 300)
frame.Position = UDim2.new(0, 20, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)

local UIList = Instance.new("UIListLayout", frame)

local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)

    btn.MouseButton1Click:Connect(callback)

    btn.Parent = frame
end

-- CLEAR
createButton("❌ Clear", function()
    Visual:Clear()
end)

-- PARTICLES
for i, p in ipairs(Assets.Particles) do
    if i > 20 then break end -- limitar lag

    createButton("✨ Particle "..i, function()
        Visual:ApplyParticle(p)
    end)
end

-- SOUNDS
for i, s in ipairs(Assets.Sounds) do
    if i > 10 then break end

    createButton("🔊 Sound "..i, function()
        Visual:PlaySound(s)
    end)
end

print("✅ UI loaded")
