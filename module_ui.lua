local UPF = _G.UPF
local Assets = UPF.Assets
local Visual = UPF.Visual

local UIS = game:GetService("UserInputService")

-- =========================
-- UI BASE
-- =========================

local screen = Instance.new("ScreenGui")
screen.Name = "UPF_UI"
screen.Parent = game.CoreGui

local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(0, 300, 0, 180)
frame.Position = UDim2.new(0, 20, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "🔥 UPF Asset Browser"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local info = Instance.new("TextLabel", frame)
info.Position = UDim2.new(0,0,0,40)
info.Size = UDim2.new(1,0,0,100)
info.Text = "Cargando..."
info.TextColor3 = Color3.new(1,1,1)
info.BackgroundTransparency = 1
info.TextWrapped = true

local hint = Instance.new("TextLabel", frame)
hint.Position = UDim2.new(0,0,1,-40)
hint.Size = UDim2.new(1,0,0,40)
hint.Text = "← → cambiar | M modo | P play"
hint.TextColor3 = Color3.fromRGB(180,180,180)
hint.BackgroundTransparency = 1
hint.TextScaled = true

-- =========================
-- ESTADO
-- =========================

local index = 1
local mode = "Particles"
local visible = true

-- =========================
-- FUNCIONES
-- =========================

local function getList()
    if mode == "Particles" then
        return Assets.Particles
    elseif mode == "Sounds" then
        return Assets.Sounds
    else
        return Assets.Decals
    end
end

local function updateUI()
    local list = getList()
    local total = #list

    info.Text = 
        "Modo: "..mode.."\n"..
        "Index: "..index.." / "..total
end

local function apply()
    local list = getList()
    local asset = list[index]

    if not asset then return end

    if mode == "Particles" then
        Visual:ApplyParticle(asset)

    elseif mode == "Sounds" then
        Visual:PlaySound(asset)

    elseif mode == "Decals" then
        Visual:Clear()
    end
end

-- =========================
-- CONTROLES
-- =========================

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    local list = getList()

    if input.KeyCode == Enum.KeyCode.Right then
        index = math.min(index + 1, #list)
        updateUI()

    elseif input.KeyCode == Enum.KeyCode.Left then
        index = math.max(1, index - 1)
        updateUI()

    elseif input.KeyCode == Enum.KeyCode.M then
        if mode == "Particles" then
            mode = "Sounds"
        elseif mode == "Sounds" then
            mode = "Decals"
        else
            mode = "Particles"
        end
        index = 1
        updateUI()

    elseif input.KeyCode == Enum.KeyCode.P then
        apply()

    elseif input.KeyCode == Enum.KeyCode.K then
        visible = not visible
        frame.Visible = visible
    end
end)

-- =========================
-- INIT
-- =========================

task.delay(2, function()
    updateUI()
end)

print("🔥 UI PRO REAL loaded")
