local UPF = _G.UPF
local Scanner = UPF.Scanner
local Visual = UPF.Visual
local Devil = UPF.Devil

local player = game.Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

-- =========================
-- GUI BASE
-- =========================

local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 450)
frame.Position = UDim2.new(0.05, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)

-- =========================
-- DRAG
-- =========================

local dragging, startPos, startInputPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        startInputPos = input.Position
        startPos = frame.Position
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

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- =========================
-- TOP BAR
-- =========================

local top = Instance.new("Frame", frame)
top.Size = UDim2.new(1,0,0,30)
top.BackgroundColor3 = Color3.fromRGB(25,25,25)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,-70,1,0)
title.Text = "😈 UPF GOD"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

local minimized = false

local minBtn = Instance.new("TextButton", top)
minBtn.Size = UDim2.new(0,35,1,0)
minBtn.Position = UDim2.new(1,-70,0,0)
minBtn.Text = "_"

local closeBtn = Instance.new("TextButton", top)
closeBtn.Size = UDim2.new(0,35,1,0)
closeBtn.Position = UDim2.new(1,-35,0,0)
closeBtn.Text = "X"

-- =========================
-- SEARCH BAR 🔍
-- =========================

local search = Instance.new("TextBox", frame)
search.Size = UDim2.new(1,-10,0,30)
search.Position = UDim2.new(0,5,0,35)
search.PlaceholderText = "Buscar efecto..."
search.BackgroundColor3 = Color3.fromRGB(30,30,30)
search.TextColor3 = Color3.new(1,1,1)

-- =========================
-- SCROLL
-- =========================

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Position = UDim2.new(0,0,0,70)
scroll.Size = UDim2.new(1,0,1,-70)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,4)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)

-- =========================
-- BUTTON SYSTEM
-- =========================

local function clearList()
    for _, v in ipairs(scroll:GetChildren()) do
        if v:IsA("TextButton") then
            v:Destroy()
        end
    end
end

local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,28)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = scroll

    btn.MouseButton1Click:Connect(callback)
end

-- =========================
-- STATES
-- =========================

local effectsEnabled = true

-- =========================
-- MENU PRINCIPAL
-- =========================

local function mainMenu()
    clearList()

    createButton("🔍 Scan Game", function()
        Scanner:Scan()
    end)

    createButton("🟢 Server FX", function()
        showList(Scanner.Results.Server, "SERVER")
    end)

    createButton("👁 Local FX", function()
        showList(Scanner.Results.Local, "LOCAL")
    end)

    createButton("❌ Clear FX", function()
        Visual:Clear()
    end)

    createButton("🌈 RGB", function()
        task.spawn(function()
            while true do
                Lighting.Ambient = Color3.fromHSV(tick()%5/5,1,1)
                task.wait(0.1)
            end
        end)
    end)

    createButton("😈 DEVIL MODE", function()
        if Devil.Enabled then
            Devil:Disable()
        else
            Devil:Enable()
        end
    end)
end

-- =========================
-- LIST VIEW
-- =========================

function showList(data, mode)
    clearList()

    createButton("⬅ Back", mainMenu)

    local list = {}

    for _, p in ipairs(data.Particles) do
        table.insert(list, {type="particle", obj=p})
    end

    for _, s in ipairs(data.Sounds) do
        table.insert(list, {type="sound", obj=s})
    end

    for i, item in ipairs(list) do
        if i > 50 then break end

        local name = item.type .. " " .. i

        createButton(name, function()
            if not effectsEnabled then return end

            -- 👁 PREVIEW (rápido)
            if item.type == "particle" then
                Visual:ApplyParticle(item.obj)
            else
                Visual:PlaySound(item.obj)
            end
        end)
    end
end

-- =========================
-- SEARCH FILTER 🔍
-- =========================

search:GetPropertyChangedSignal("Text"):Connect(function()
    local text = search.Text:lower()

    for _, btn in ipairs(scroll:GetChildren()) do
        if btn:IsA("TextButton") then
            btn.Visible = string.find(btn.Text:lower(), text) ~= nil
        end
    end
end)

-- =========================
-- MIN / CLOSE
-- =========================

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    scroll.Visible = not minimized
    search.Visible = not minimized
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- =========================
-- INIT
-- =========================

mainMenu()

print("😈 UI GOD FINAL LOADED")
