-- module_ui_theme.lua
-- Tema + Panel de Settings (con controles) para UPF
-- Colocar AFTER module_ui.lua (loader ya lo hace)
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local UPF = _G.UPF
if not UPF or not UPF.UI or not UPF.UI.Main then
    warn("module_ui_theme: UPF.UI no está listo todavía.")
    return
end

local ScreenGui = UPF.UI.ScreenGui
local Main = UPF.UI.Main
local Header = Main:FindFirstChild("Header")
local Content = UPF.UI.Content
local InfoLabel = UPF.UI.InfoLabel

-- Helpers
local function tween(obj, props, t, style, dir)
    t = t or 0.22
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    local tw = TweenService:Create(obj, TweenInfo.new(t, style, dir), props)
    tw:Play()
    return tw
end

local function safeCall(fn, ...)
    local ok, res = pcall(fn, ...)
    if not ok then warn("module_ui_theme safeCall error:", res) end
    return ok, res
end

-- Evita duplicados
if Header:FindFirstChild("UPF_SettingsBtn") then
    -- ya existe: conecta visibilidad si hace falta
else
    local SettingsBtn = Instance.new("TextButton")
    SettingsBtn.Name = "UPF_SettingsBtn"
    SettingsBtn.Parent = Header
    SettingsBtn.Size = UDim2.fromScale(0.16, 0.72)
    SettingsBtn.Position = UDim2.fromScale(0.80, 0.14)
    SettingsBtn.AnchorPoint = Vector2.new(0,0)
    SettingsBtn.Text = "⚙ Settings"
    SettingsBtn.Font = Enum.Font.GothamBold
    SettingsBtn.TextScaled = true
    SettingsBtn.TextColor3 = Color3.fromRGB(240,240,245)
    SettingsBtn.BackgroundColor3 = Color3.fromRGB(28,30,40)
    SettingsBtn.BorderSizePixel = 0
    local s = Instance.new("UICorner", SettingsBtn); s.CornerRadius = UDim.new(0,12)
    local stroke = Instance.new("UIStroke", SettingsBtn); stroke.Transparency = 0.85; stroke.Thickness = 1

    -- hover pequeño
    SettingsBtn.MouseEnter:Connect(function() tween(SettingsBtn, {BackgroundTransparency = 0.15}, 0.14) end)
    SettingsBtn.MouseLeave:Connect(function() tween(SettingsBtn, {BackgroundTransparency = 0}, 0.12) end)
end

local SettingsBtn = Header:FindFirstChild("UPF_SettingsBtn")

-- Overlay (derecha)
local existing = ScreenGui:FindFirstChild("UPF_SettingsOverlay")
if existing then existing:Destroy() end

local Overlay = Instance.new("Frame")
Overlay.Name = "UPF_SettingsOverlay"
Overlay.Parent = ScreenGui
Overlay.AnchorPoint = Vector2.new(1,0)
Overlay.Size = UDim2.fromScale(0.44, 0.72)
Overlay.Position = UDim2.fromScale(1.05, 0.14) -- offscreen
Overlay.BackgroundColor3 = Color3.fromRGB(16,18,24)
Overlay.ZIndex = Main.ZIndex + 5
Overlay.Visible = false
Instance.new("UICorner", Overlay).CornerRadius = UDim.new(0, 18)
local overlayStroke = Instance.new("UIStroke", Overlay); overlayStroke.Color = Color3.fromRGB(80,60,200); overlayStroke.Transparency = 0.8

-- Header overlay
local OverlayHeader = Instance.new("Frame")
OverlayHeader.Name = "OverlayHeader"
OverlayHeader.Parent = Overlay
OverlayHeader.Size = UDim2.fromScale(1, 0.16)
OverlayHeader.Position = UDim2.fromScale(0,0)
OverlayHeader.BackgroundTransparency = 1

local OHLabel = Instance.new("TextLabel")
OHLabel.Parent = OverlayHeader
OHLabel.Size = UDim2.fromScale(0.7, 1)
OHLabel.Position = UDim2.fromScale(0.04, 0)
OHLabel.BackgroundTransparency = 1
OHLabel.Text = "Settings"
OHLabel.Font = Enum.Font.GothamBold
OHLabel.TextScaled = true
OHLabel.TextColor3 = Color3.fromRGB(235,235,235)
OHLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = OverlayHeader
CloseBtn.Size = UDim2.fromScale(0.14, 0.68)
CloseBtn.Position = UDim2.fromScale(0.86, 0.12)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextScaled = true
CloseBtn.BackgroundTransparency = 0
CloseBtn.BackgroundColor3 = Color3.fromRGB(44,44,50)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,10)

-- Panic quick action
local PanicBtn = Instance.new("TextButton")
PanicBtn.Name = "PanicBtn"
PanicBtn.Parent = OverlayHeader
PanicBtn.Size = UDim2.fromScale(0.16, 0.7)
PanicBtn.Position = UDim2.fromScale(0.68, 0.12)
PanicBtn.Text = "🚨 PANIC"
PanicBtn.Font = Enum.Font.GothamBold
PanicBtn.TextScaled = true
PanicBtn.BackgroundColor3 = Color3.fromRGB(180,60,60)
Instance.new("UICorner", PanicBtn).CornerRadius = UDim.new(0,10)

-- Cards grid
local Grid = Instance.new("Frame")
Grid.Parent = Overlay
Grid.Size = UDim2.fromScale(0.96, 0.78)
Grid.Position = UDim2.fromScale(0.02, 0.20)
Grid.BackgroundTransparency = 1

local GridLayout = Instance.new("UIGridLayout")
GridLayout.Parent = Grid
GridLayout.CellSize = UDim2.new(0.32,0,0.36,0)
GridLayout.CellPadding = UDim2.new(0.03,0,0.03,0)
GridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
GridLayout.FillDirectionMaxCells = 3

-- Card factory (TextButton for click)
local function createCard(title, c1, c2, id)
    local card = Instance.new("TextButton")
    card.Name = "Card_"..id
    card.Size = UDim2.fromScale(1,1)
    card.BackgroundColor3 = Color3.fromRGB(18,18,20)
    card.Parent = Grid
    card.AutoButtonColor = true
    card.Text = ""
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0,14)
    local grad = Instance.new("UIGradient", card)
    grad.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2) }
    grad.Rotation = 180

    local label = Instance.new("TextLabel", card)
    label.Size = UDim2.fromScale(1, 0.35)
    label.Position = UDim2.fromScale(0, 0.55)
    label.BackgroundTransparency = 1
    label.Text = title:upper()
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(240,240,240)
    label.TextXAlignment = Enum.TextXAlignment.Center

    -- hover
    card.MouseEnter:Connect(function() pcall(function() tween(card, {Size = UDim2.fromScale(1.02,1.02)}, 0.12) end) end)
    card.MouseLeave:Connect(function() pcall(function() tween(card, {Size = UDim2.fromScale(1,1)}, 0.12) end) end)

    return card
end

-- create cards
local cardGeneral = createCard("General", Color3.fromRGB(16,54,110), Color3.fromRGB(34,89,145), "general")
local cardKeybinds = createCard("Keybinds", Color3.fromRGB(14,68,56), Color3.fromRGB(28,110,98), "keybinds")
local cardPerf = createCard("Performance", Color3.fromRGB(110,50,20), Color3.fromRGB(170,80,30), "performance")
local cardDetect = createCard("Detections", Color3.fromRGB(120,20,20), Color3.fromRGB(180,40,40), "detections")
local cardLog = createCard("Logging", Color3.fromRGB(120,100,20), Color3.fromRGB(200,160,30), "logging")

-- Tab content container (reused)
local function clearTab()
    local existing = Overlay:FindFirstChild("TabContent")
    if existing then existing:Destroy() end
end

local function openGeneralTab()
    clearTab()
    local tab = Instance.new("Frame")
    tab.Name = "TabContent"
    tab.Parent = Overlay
    tab.Size = UDim2.fromScale(0.95, 0.34)
    tab.Position = UDim2.fromScale(0.025, 0.55)
    tab.BackgroundColor3 = Color3.fromRGB(12,12,14)
    Instance.new("UICorner", tab).CornerRadius = UDim.new(0,12)

    local title = Instance.new("TextLabel", tab)
    title.Size = UDim2.fromScale(0.9, 0.18)
    title.Position = UDim2.fromScale(0.05, 0.04)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextColor3 = Color3.fromRGB(230,230,230)
    title.Text = "General"

    -- God mode toggle
    local godBtn = Instance.new("TextButton", tab)
    godBtn.Size = UDim2.fromScale(0.6, 0.18)
    godBtn.Position = UDim2.fromScale(0.2, 0.26)
    godBtn.Font = Enum.Font.GothamBold
    godBtn.TextScaled = true
    godBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", godBtn).CornerRadius = UDim.new(0,12)
    local function updateGodBtn()
        godBtn.Text = UPF.State.GodMode and "God Mode: ON" or "God Mode: OFF"
        godBtn.BackgroundColor3 = UPF.State.GodMode and Color3.fromRGB(60,160,90) or Color3.fromRGB(120,60,60)
    end
    updateGodBtn()
    godBtn.MouseButton1Click:Connect(function()
        UPF:ToggleGodMode(not UPF.State.GodMode)
        updateGodBtn()
        pcall(function() if UPF.SaveSettings then UPF:SaveSettings() end end)
    end)

    -- Auto Return toggle
    local arBtn = Instance.new("TextButton", tab)
    arBtn.Size = UDim2.fromScale(0.6, 0.18)
    arBtn.Position = UDim2.fromScale(0.2, 0.46)
    arBtn.Font = Enum.Font.GothamBold
    arBtn.TextScaled = true
    arBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", arBtn).CornerRadius = UDim.new(0,12)
    local function updateARBtn()
        arBtn.Text = UPF.State.AutoReturnEnabled and "Auto Return: ON" or "Auto Return: OFF"
        arBtn.BackgroundColor3 = UPF.State.AutoReturnEnabled and Color3.fromRGB(60,160,90) or Color3.fromRGB(120,120,120)
    end
    updateARBtn()
    arBtn.MouseButton1Click:Connect(function()
        UPF.State.AutoReturnEnabled = not UPF.State.AutoReturnEnabled
        updateARBtn()
        pcall(function() if UPF.SaveSettings then UPF:SaveSettings() end end)
    end)

    -- Return now
    local returnBtn = Instance.new("TextButton", tab)
    returnBtn.Size = UDim2.fromScale(0.6, 0.18)
    returnBtn.Position = UDim2.fromScale(0.2, 0.66)
    returnBtn.Font = Enum.Font.GothamBold
    returnBtn.TextScaled = true
    returnBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", returnBtn).CornerRadius = UDim.new(0,12)
    returnBtn.BackgroundColor3 = Color3.fromRGB(70,160,120)
    returnBtn.Text = "Return to Safe Point"
    returnBtn.MouseButton1Click:Connect(function()
        pcall(function() UPF:ReturnToSafePoint() end)
    end)

    -- Audio Shield controls
    local audioTitle = Instance.new("TextLabel", tab)
    audioTitle.Size = UDim2.fromScale(0.9, 0.12)
    audioTitle.Position = UDim2.fromScale(0.05, 0.85)
    audioTitle.BackgroundTransparency = 1
    audioTitle.Font = Enum.Font.GothamBold
    audioTitle.TextScaled = true
    audioTitle.TextColor3 = Color3.fromRGB(200,200,200)
    audioTitle.Text = "Audio Shield"

    -- Audio controls (toggles + small sliders simulated)
    local audToggle = Instance.new("TextButton", tab)
    audToggle.Size = UDim2.fromScale(0.28, 0.12)
    audToggle.Position = UDim2.fromScale(0.05, 0.72)
    audToggle.Font = Enum.Font.Gotham
    audToggle.TextScaled = true
    Instance.new("UICorner", audToggle).CornerRadius = UDim.new(0,8)
    local function updateAudioToggle()
        audToggle.Text = UPF.State.Audio and (UPF.State.Audio.Enabled and "Audio: ON" or "Audio: OFF") or "Audio: OFF"
        audToggle.BackgroundColor3 = (UPF.State.Audio and UPF.State.Audio.Enabled) and Color3.fromRGB(60,160,90) or Color3.fromRGB(110,110,110)
    end
    updateAudioToggle()
    audToggle.MouseButton1Click:Connect(function()
        pcall(function() UPF:ToggleAudioShield() end)
        updateAudioToggle()
        pcall(function() if UPF.SaveSettings then UPF:SaveSettings() end end)
    end)

    -- Radius quick buttons (- / +)
    local radLabel = Instance.new("TextLabel", tab)
    radLabel.Size = UDim2.fromScale(0.28, 0.10)
    radLabel.Position = UDim2.fromScale(0.36, 0.72)
    radLabel.BackgroundTransparency = 1
    radLabel.Font = Enum.Font.Gotham
    radLabel.TextScaled = true
    radLabel.TextColor3 = Color3.fromRGB(220,220,220)
    radLabel.Text = "Radius: " .. tostring((UPF.State.Audio and UPF.State.Audio.Radius) or 20)

    local radMinus = Instance.new("TextButton", tab)
    radMinus.Size = UDim2.fromScale(0.13, 0.12)
    radMinus.Position = UDim2.fromScale(0.66, 0.72)
    radMinus.Text = "-"
    Instance.new("UICorner", radMinus).CornerRadius = UDim.new(0,8)
    radMinus.MouseButton1Click:Connect(function()
        local v = (UPF.State.Audio and UPF.State.Audio.Radius) or 20
        v = math.max(1, v - 5)
        pcall(function() UPF:SetAudioShieldRadius(v) end)
        radLabel.Text = "Radius: "..tostring(v)
        pcall(function() if UPF.SaveSettings then UPF:SaveSettings() end end)
    end)

    local radPlus = Instance.new("TextButton", tab)
    radPlus.Size = UDim2.fromScale(0.13, 0.12)
    radPlus.Position = UDim2.fromScale(0.80, 0.72)
    radPlus.Text = "+"
    Instance.new("UICorner", radPlus).CornerRadius = UDim.new(0,8)
    radPlus.MouseButton1Click:Connect(function()
        local v = (UPF.State.Audio and UPF.State.Audio.Radius) or 20
        v = v + 5
        pcall(function() UPF:SetAudioShieldRadius(v) end)
        radLabel.Text = "Radius: "..tostring(v)
        pcall(function() if UPF.SaveSettings then UPF:SaveSettings() end end)
    end)
end

-- card click handlers
cardGeneral.MouseButton1Click:Connect(openGeneralTab)

-- Panic button behavior
PanicBtn.MouseButton1Click:Connect(function()
    -- quick safety: enable protection, set smart to SAFE, teleport to safe point
    pcall(function()
        UPF:ToggleProtection(true)
        UPF.State.SmartMode = "SAFE"
        if UPF.ReturnToSafePoint then UPF:ReturnToSafePoint() end
    end)
    -- feedback: brief color change
    PanicBtn.BackgroundColor3 = Color3.fromRGB(120,120,120)
    task.delay(2.5, function() PanicBtn.BackgroundColor3 = Color3.fromRGB(180,60,60) end)
end)

-- Overlay open/close
local overlayOpen = false
local function openOverlay()
    if overlayOpen then return end
    overlayOpen = true
    Overlay.Visible = true
    Overlay.Position = UDim2.fromScale(1.05, 0.14)
    tween(Overlay, {Position = UDim2.fromScale(0.94, 0.14)}, 0.36, Enum.EasingStyle.Cubic)
    -- dim main slightly
    tween(Main, {BackgroundTransparency = 0.08}, 0.28)
end
local function closeOverlay()
    if not overlayOpen then return end
    overlayOpen = false
    tween(Overlay, {Position = UDim2.fromScale(1.05, 0.14)}, 0.32)
    task.delay(0.32, function() Overlay.Visible = false end)
    tween(Main, {BackgroundTransparency = 0}, 0.24)
    clearTab()
end

SettingsBtn.MouseButton1Click:Connect(function()
    if not overlayOpen then
        openOverlay()
    else
        closeOverlay()
    end
end)
CloseBtn.MouseButton1Click:Connect(closeOverlay)

-- Floating minimize button
local toggleFloat = Instance.new("ImageButton")
toggleFloat.Name = "UPF_OverlayToggle"
toggleFloat.Parent = ScreenGui
toggleFloat.Size = UDim2.fromOffset(56,56)
toggleFloat.Position = UDim2.fromScale(0.92, 0.82)
toggleFloat.AnchorPoint = Vector2.new(0.5,0.5)
toggleFloat.BackgroundColor3 = Color3.fromRGB(20,18,30)
toggleFloat.Visible = false
toggleFloat.Image = ""
local tcorner = Instance.new("UICorner", toggleFloat); tcorner.CornerRadius = UDim.new(1,0)

toggleFloat.MouseButton1Click:Connect(function()
    if overlayOpen then
        closeOverlay()
    else
        openOverlay()
    end
end)

-- Keyboard support (Esc closes)
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(inp, processed)
    if processed then return end
    if inp.KeyCode == Enum.KeyCode.Escape and overlayOpen then
        closeOverlay()
    end
end)

print("✅ module_ui_theme loaded — settings overlay & controls ready")