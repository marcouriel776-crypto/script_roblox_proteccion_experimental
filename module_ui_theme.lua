-- module_ui_theme.lua
-- Theme & Settings overlay (Sirius-like cards, animations)
-- Extiende la UI existente creada por module_core.lua / module_ui.lua
-- Load AFTER CoreReady and module_ui.lua

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- wait for core and basic UI
repeat task.wait() until CoreReady
local ok, ScreenGui = pcall(function() return CoreGui:FindFirstChild("ProtectionUI") end)
if not ok or not ScreenGui then warn("module_ui_theme: ProtectionUI not found") return end

local Main = ScreenGui:FindFirstChild("Main")
local Content = Main and Main:FindFirstChild("Content")
local Header = Main and Main:FindFirstChild("Header")

if not Main or not Content or not Header then
    warn("module_ui_theme: expected Main/Content/Header structure not found")
    return
end

-- Small helpers
local function tween(obj, props, time, style, dir)
    time = time or 0.22
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    local info = TweenService:Create(obj, TweenInfo.new(time, style, dir), props)
    info:Play()
    return info
end

local function makeGradient(frame, color1, color2, rotation)
    local grad = Instance.new("UIGradient")
    grad.Parent = frame
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    }
    grad.Rotation = rotation or 90
    return grad
end

-- Add Settings button to header (if not exists)
local SettingsBtn = Header:FindFirstChild("SettingsButton")
if not SettingsBtn then
    SettingsBtn = Instance.new("TextButton")
    SettingsBtn.Name = "SettingsButton"
    SettingsBtn.Parent = Header
    SettingsBtn.Size = UDim2.fromScale(0.14, 0.7)
    SettingsBtn.Position = UDim2.fromScale(0.82, 0.15)
    SettingsBtn.AnchorPoint = Vector2.new(0, 0)
    SettingsBtn.Text = "⚙ Settings"
    SettingsBtn.Font = Enum.Font.GothamSemibold
    SettingsBtn.TextScaled = true
    SettingsBtn.TextColor3 = Color3.fromRGB(245,245,245)
    SettingsBtn.BackgroundTransparency = 0
    SettingsBtn.BackgroundColor3 = Color3.fromRGB(24,26,35)
    Instance.new("UICorner", SettingsBtn).CornerRadius = UDim.new(0,12)
    local stroke = Instance.new("UIStroke", SettingsBtn)
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    stroke.Color = Color3.fromRGB(255,255,255)
    -- subtle gradient
    makeGradient(SettingsBtn, Color3.fromRGB(36,46,80), Color3.fromRGB(24,26,35), 90)
end

-- Create overlay container (right panel)
local Overlay = Instance.new("Frame")
Overlay.Name = "SettingsOverlay"
Overlay.Parent = ScreenGui
Overlay.Size = UDim2.fromScale(0.44, 0.72) -- width, height relative to screen
Overlay.Position = UDim2.fromScale(1.0, 0.14) -- start off-screen (to the right)
Overlay.AnchorPoint = Vector2.new(1, 0)
Overlay.BackgroundTransparency = 0
Overlay.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
Overlay.ZIndex = Main.ZIndex + 5
Instance.new("UICorner", Overlay).CornerRadius = UDim.new(0, 18)
Overlay.Visible = false

-- overlay header
local OverlayHeader = Instance.new("Frame")
OverlayHeader.Name = "OverlayHeader"
OverlayHeader.Parent = Overlay
OverlayHeader.Size = UDim2.fromScale(1, 0.18)
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

local CloseOverlayBtn = Instance.new("TextButton")
CloseOverlayBtn.Parent = OverlayHeader
CloseOverlayBtn.Size = UDim2.fromScale(0.16, 0.6)
CloseOverlayBtn.AnchorPoint = Vector2.new(1,0.2)
CloseOverlayBtn.Position = UDim2.fromScale(0.94, 0.2)
CloseOverlayBtn.Text = "✕"
CloseOverlayBtn.Font = Enum.Font.GothamBold
CloseOverlayBtn.TextScaled = true
CloseOverlayBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseOverlayBtn.BackgroundTransparency = 0
CloseOverlayBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
Instance.new("UICorner", CloseOverlayBtn).CornerRadius = UDim.new(0,10)

-- grid container for cards
local Grid = Instance.new("Frame")
Grid.Parent = Overlay
Grid.Size = UDim2.fromScale(0.96, 0.78)
Grid.Position = UDim2.fromScale(0.02, 0.20)
Grid.BackgroundTransparency = 1

local GridLayout = Instance.new("UIGridLayout")
GridLayout.Parent = Grid
GridLayout.CellSize = UDim2.new(0.32, 0, 0.38, 0) -- 3 columns wide-ish
GridLayout.CellPadding = UDim2.new(0.03,0,0.03,0)
GridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
GridLayout.FillDirection = Enum.FillDirection.Horizontal
GridLayout.FillDirectionMaxCells = 3

-- card factory
local function createCard(title, col1, col2, id)
    local card = Instance.new("Frame")
    card.Name = "Card_" .. id
    card.Size = UDim2.fromScale(1,1)
    card.BackgroundColor3 = Color3.fromRGB(18,18,20)
    card.BorderSizePixel = 0
    card.Parent = Grid
    Instance.new("UICorner", card).CornerRadius = UDim.new(0,14)
    local grad = makeGradient(card, col1, col2, 90)
    grad.Rotation = 180
    -- inner content
    local label = Instance.new("TextLabel")
    label.Parent = card
    label.Size = UDim2.fromScale(1, 0.35)
    label.Position = UDim2.fromScale(0, 0.5)
    label.BackgroundTransparency = 1
    label.Text = title:upper()
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(240,240,240)
    label.TextStrokeTransparency = 0.9
    label.TextXAlignment = Enum.TextXAlignment.Center
    -- subtle inner glow (UIStroke)
    local stroke = Instance.new("UIStroke", card)
    stroke.Thickness = 1
    stroke.Transparency = 0.8
    stroke.Color = Color3.fromRGB(255,255,255)
    -- clickable behavior
    card.Active = true
    card.Selectable = true
    card.MouseEnter:Connect(function()
        tween(card, {Size = UDim2.fromScale(1.02,1.02)}, 0.14)
    end)
    card.MouseLeave:Connect(function()
        tween(card, {Size = UDim2.fromScale(1,1)}, 0.12)
    end)
    local function onClick()
        -- open tab content area (simple replacement content for now)
        if Overlay:FindFirstChild("TabContent") then Overlay.TabContent:Destroy() end
        local tab = Instance.new("Frame")
        tab.Name = "TabContent"
        tab.Parent = Overlay
        tab.Size = UDim2.fromScale(0.95, 0.34)
        tab.Position = UDim2.fromScale(0.025, 0.55)
        tab.BackgroundTransparency = 0
        tab.BackgroundColor3 = Color3.fromRGB(12,12,14)
        Instance.new("UICorner", tab).CornerRadius = UDim.new(0,12)
        -- title
        local tlabel = Instance.new("TextLabel")
        tlabel.Parent = tab
        tlabel.Size = UDim2.fromScale(0.9, 0.22)
        tlabel.Position = UDim2.fromScale(0.05, 0.05)
        tlabel.BackgroundTransparency = 1
        tlabel.Text = title
        tlabel.Font = Enum.Font.GothamBold
        tlabel.TextScaled = true
        tlabel.TextColor3 = Color3.fromRGB(230,230,230)
        -- placeholder area
        local ph = Instance.new("TextLabel")
        ph.Parent = tab
        ph.Size = UDim2.fromScale(0.9, 0.6)
        ph.Position = UDim2.fromScale(0.05, 0.30)
        ph.BackgroundTransparency = 1
        ph.Text = "Ajustes de " .. title .. " (aquí van sliders, toggles y controles)"
        ph.Font = Enum.Font.Gotham
        ph.TextScaled = true
        ph.TextColor3 = Color3.fromRGB(200,200,210)
        ph.TextWrapped = true
        -- animate tab in
        tab.Position = UDim2.fromScale(1.05, 0.55)
        tween(tab, {Position = UDim2.fromScale(0.025, 0.55)}, 0.28)
    end
    card.MouseButton1Click:Connect(onClick)
    return card
end

-- create the cards (colors chosen visually)
createCard("General", Color3.fromRGB(16,54,110), Color3.fromRGB(34,89,145), "general")
createCard("Keybinds", Color3.fromRGB(14,68,56), Color3.fromRGB(28,110,98), "keybinds")
createCard("Performance", Color3.fromRGB(110,50,20), Color3.fromRGB(170,80,30), "performance")
createCard("Detections", Color3.fromRGB(120,20,20), Color3.fromRGB(180,40,40), "detections")
createCard("Logging", Color3.fromRGB(120,100,20), Color3.fromRGB(200,160,30), "logging")

-- open/close behavior
local overlayOpen = false
local function openOverlay()
    if overlayOpen then return end
    overlayOpen = true
    Overlay.Visible = true
    Overlay.Position = UDim2.fromScale(1.05, 0.14)
    tween(Overlay, {Position = UDim2.fromScale(0.94, 0.14)}, 0.32)
    -- slightly dim main
    tween(Main, {BackgroundTransparency = 0.12}, 0.32)
end
local function closeOverlay()
    if not overlayOpen then return end
    overlayOpen = false
    tween(Overlay, {Position = UDim2.fromScale(1.05, 0.14)}, 0.28)
    task.delay(0.28, function() Overlay.Visible = false end)
    tween(Main, {BackgroundTransparency = 0}, 0.28)
    if Overlay:FindFirstChild("TabContent") then Overlay.TabContent:Destroy() end
end

SettingsBtn.MouseButton1Click:Connect(function()
    if not overlayOpen then openOverlay() else closeOverlay() end
end)
CloseOverlayBtn.MouseButton1Click:Connect(closeOverlay)

-- keyboard close (Esc)
local uis = game:GetService("UserInputService")
uis.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Escape and overlayOpen then
        closeOverlay()
    end
end)

print("✅ module_ui_theme loaded — enhanced theme and settings panel ready")