-- module_ui.lua
-- Universal Protection Framework - UI (completo, conectado a UPF)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- UPF debe existir (loader inicializó _G.UPF)
local UPF = _G.UPF
if not UPF then
    warn("module_ui.lua: UPF no inicializado")
    return
end

-- Evitar duplicados en PlayerGui
local existing = PlayerGui:FindFirstChild("ProtectionUI")
if existing then
    existing:Destroy()
end

-- Helper tween
local function quickTween(inst, props, t)
    t = t or 0.22
    local tw = TweenService:Create(inst, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

-- Pantalla principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProtectionUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Main frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromScale(0.48, 0.56)
Main.Position = UDim2.fromScale(0.26, 0.22)
Main.AnchorPoint = Vector2.new(0,0)
Main.BackgroundColor3 = Color3.fromRGB(18,18,28)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
local mainCorner = Instance.new("UICorner", Main); mainCorner.CornerRadius = UDim.new(0,18)
local mainStroke = Instance.new("UIStroke", Main); mainStroke.Color = Color3.fromRGB(90,60,220); mainStroke.Thickness = 2; mainStroke.Transparency = 0.9

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1,0,0,56)
Header.Position = UDim2.new(0,0,0,0)
Header.BackgroundColor3 = Color3.fromRGB(26,26,40)
Header.Parent = Main
local headerCorner = Instance.new("UICorner", Header); headerCorner.CornerRadius = UDim.new(0,18)

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.fromScale(0.7, 1)
Title.Position = UDim2.fromScale(0.02, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Text = "🛡 Universal Protection"
Title.TextColor3 = Color3.fromRGB(235,235,240)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Header controls: Settings, Minimize, Close
local BtnSize = UDim2.new(0,36,0,36)
local function makeHeaderBtn(parent, posX, text, bg)
    local b = Instance.new("TextButton")
    b.Size = BtnSize
    b.Position = UDim2.new(1, posX, 0, 10)
    b.BackgroundColor3 = bg or Color3.fromRGB(70,70,90)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.fromRGB(240,240,240)
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    return b
end

local CloseBtn = makeHeaderBtn(Header, -44, "✕", Color3.fromRGB(190,60,60))
local MinimizeBtn = makeHeaderBtn(Header, -88, "—", Color3.fromRGB(70,70,90))
local SettingsBtn = makeHeaderBtn(Header, -132, "⚙", Color3.fromRGB(60,90,140))

-- Content scrolling
local Content = Instance.new("ScrollingFrame")
Content.Parent = Main
Content.Position = UDim2.fromScale(0,0.11)
Content.Size = UDim2.fromScale(1, 0.78)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0,0,0,0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.ScrollBarThickness = 6
local list = Instance.new("UIListLayout", Content)
list.Padding = UDim.new(0,12)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.SortOrder = Enum.SortOrder.LayoutOrder

-- Utility to create big buttons
local function createBigButton(text, bgColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromScale(0.78, 0.12)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(245,245,245)
    btn.BackgroundColor3 = bgColor or Color3.fromRGB(80,80,160)
    btn.Parent = Content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,14)
    return btn
end

-- Protection Button
local ProtectionBtn = createBigButton("Enable Protection", Color3.fromRGB(70,110,230))
ProtectionBtn.LayoutOrder = 1

-- Mode (SAFE / PVP) small container
local ModeFrame = Instance.new("Frame")
ModeFrame.Size = UDim2.fromScale(0.78, 0.10)
ModeFrame.BackgroundTransparency = 1
ModeFrame.Parent = Content
ModeFrame.LayoutOrder = 2
local ModeLabel = Instance.new("TextLabel", ModeFrame)
ModeLabel.Size = UDim2.new(0.6,0,1,0)
ModeLabel.BackgroundTransparency = 1
ModeLabel.Font = Enum.Font.GothamBold
ModeLabel.TextScaled = true
ModeLabel.TextColor3 = Color3.fromRGB(230,230,240)
ModeLabel.Text = "Mode: SAFE"
ModeLabel.TextXAlignment = Enum.TextXAlignment.Left
ModeLabel.Position = UDim2.fromScale(0,0)

local ModeToggle = Instance.new("TextButton", ModeFrame)
ModeToggle.Size = UDim2.new(0.36,0,1,0)
ModeToggle.Position = UDim2.new(0.64,0,0,0)
ModeToggle.Font = Enum.Font.GothamBold
ModeToggle.TextScaled = true
ModeToggle.TextColor3 = Color3.fromRGB(255,255,255)
ModeToggle.BackgroundColor3 = Color3.fromRGB(120,60,60)
ModeToggle.Text = "PVP"
Instance.new("UICorner", ModeToggle).CornerRadius = UDim.new(0,12)

-- Panic button
local PanicBtn = createBigButton("🚨 PANIC", Color3.fromRGB(180,60,60))
PanicBtn.LayoutOrder = 3

-- God Mode button
local GodBtn = createBigButton("God Mode: OFF", Color3.fromRGB(120,60,60))
GodBtn.LayoutOrder = 4

-- Unfreeze button
local UnfreezeBtn = createBigButton("Unfreeze Player", Color3.fromRGB(70,140,200))
UnfreezeBtn.LayoutOrder = 5

-- Return to safe point
local ReturnBtn = createBigButton("Return to Safe Point", Color3.fromRGB(70,160,120))
ReturnBtn.LayoutOrder = 6

-- Audio Shield block (toggle + radius controls)
local AudioFrame = Instance.new("Frame")
AudioFrame.Size = UDim2.fromScale(0.78, 0.14)
AudioFrame.BackgroundTransparency = 1
AudioFrame.Parent = Content
AudioFrame.LayoutOrder = 7

local AudioToggle = Instance.new("TextButton", AudioFrame)
AudioToggle.Size = UDim2.fromScale(0.46, 0.45)
AudioToggle.Position = UDim2.fromScale(0, 0)
AudioToggle.Font = Enum.Font.GothamBold
AudioToggle.TextScaled = true
AudioToggle.Text = "Audio Shield: OFF"
AudioToggle.BackgroundColor3 = Color3.fromRGB(110,110,110)
Instance.new("UICorner", AudioToggle).CornerRadius = UDim.new(0,12)

local RadiusLabel = Instance.new("TextLabel", AudioFrame)
RadiusLabel.Size = UDim2.fromScale(0.48, 0.25)
RadiusLabel.Position = UDim2.fromScale(0.5, 0)
RadiusLabel.BackgroundTransparency = 1
RadiusLabel.Font = Enum.Font.Gotham
RadiusLabel.TextScaled = true
RadiusLabel.Text = "Radius: 20"

local RadMinus = Instance.new("TextButton", AudioFrame)
RadMinus.Size = UDim2.fromScale(0.22, 0.35)
RadMinus.Position = UDim2.fromScale(0.5, 0.3)
RadMinus.Text = "-"
Instance.new("UICorner", RadMinus).CornerRadius = UDim.new(0,8)

local RadPlus = Instance.new("TextButton", AudioFrame)
RadPlus.Size = UDim2.fromScale(0.22, 0.35)
RadPlus.Position = UDim2.fromScale(0.76, 0.3)
RadPlus.Text = "+"
Instance.new("UICorner", RadPlus).CornerRadius = UDim.new(0,8)

-- Performance / Freeze / Smart labels
local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.fromScale(0.78, 0.08)
StatusFrame.BackgroundTransparency = 1
StatusFrame.Parent = Content
StatusFrame.LayoutOrder = 8

local PerfLabel = Instance.new("TextLabel", StatusFrame)
PerfLabel.Size = UDim2.fromScale(1, 1)
PerfLabel.BackgroundTransparency = 1
PerfLabel.Font = Enum.Font.Gotham
PerfLabel.TextScaled = true
PerfLabel.TextColor3 = Color3.fromRGB(200,200,220)
PerfLabel.Text = "⚙ Performance: NORMAL   |   🧊 Freeze: NORMAL"

-- Credits footer
local Credits = Instance.new("TextLabel")
Credits.Parent = Main
Credits.Size = UDim2.new(1,0,0,22)
Credits.Position = UDim2.new(0,0,1,-22)
Credits.BackgroundTransparency = 1
Credits.Font = Enum.Font.Gotham
Credits.TextScaled = true
Credits.TextColor3 = Color3.fromRGB(170,170,190)
Credits.Text = "UPF Protection Framework | Author: Sourcerer"
Credits.TextXAlignment = Enum.TextXAlignment.Center

-- Floating button (aparece al minimizar)
local Floating = Instance.new("TextButton")
Floating.Parent = ScreenGui
Floating.Name = "FloatingBtn"
Floating.Size = UDim2.fromOffset(64,64)
Floating.Position = UDim2.fromScale(0.9, 0.82)
Floating.AnchorPoint = Vector2.new(0.5,0.5)
Floating.Text = "UP"
Floating.Font = Enum.Font.GothamBold
Floating.TextSize = 20
Floating.BackgroundColor3 = Color3.fromRGB(110,80,255)
Floating.TextColor3 = Color3.fromRGB(255,255,255)
Floating.Visible = false
Instance.new("UICorner", Floating).CornerRadius = UDim.new(1,0)

-- Settings overlay (panel derecho)
local existingOverlay = ScreenGui:FindFirstChild("UPF_SettingsOverlay")
if existingOverlay then existingOverlay:Destroy() end

local Overlay = Instance.new("Frame")
Overlay.Name = "UPF_SettingsOverlay"
Overlay.Parent = ScreenGui
Overlay.AnchorPoint = Vector2.new(1,0)
Overlay.Size = UDim2.fromScale(0.44, 0.72)
Overlay.Position = UDim2.fromScale(1.05, 0.14) -- offscreen by default
Overlay.BackgroundColor3 = Color3.fromRGB(12,12,18)
Overlay.Visible = false
Instance.new("UICorner", Overlay).CornerRadius = UDim.new(0,18)
local overlayStroke = Instance.new("UIStroke", Overlay); overlayStroke.Color = Color3.fromRGB(80,60,200); overlayStroke.Transparency = 0.85

local OverlayHeader = Instance.new("Frame")
OverlayHeader.Size = UDim2.fromScale(1, 0.14)
OverlayHeader.Position = UDim2.fromScale(0, 0)
OverlayHeader.BackgroundTransparency = 1
OverlayHeader.Parent = Overlay

local OHTitle = Instance.new("TextLabel", OverlayHeader)
OHTitle.Size = UDim2.fromScale(0.6,1)
OHTitle.Position = UDim2.fromScale(0.04,0)
OHTitle.BackgroundTransparency = 1
OHTitle.Font = Enum.Font.GothamBold
OHTitle.TextScaled = true
OHTitle.Text = "Settings"
OHTitle.TextColor3 = Color3.fromRGB(235,235,235)
OHTitle.TextXAlignment = Enum.TextXAlignment.Left

local CloseOverlayBtn = Instance.new("TextButton", OverlayHeader)
CloseOverlayBtn.Size = UDim2.fromScale(0.12, 0.7)
CloseOverlayBtn.Position = UDim2.fromScale(0.86, 0.12)
CloseOverlayBtn.Text = "✕"
CloseOverlayBtn.Font = Enum.Font.GothamBold
CloseOverlayBtn.TextScaled = true
CloseOverlayBtn.BackgroundColor3 = Color3.fromRGB(40,40,46)
Instance.new("UICorner", CloseOverlayBtn).CornerRadius = UDim.new(0,10)

-- Tab area placeholder (we'll add General here)
local TabContainer = Instance.new("Frame")
TabContainer.Parent = Overlay
TabContainer.Position = UDim2.fromScale(0.03, 0.16)
TabContainer.Size = UDim2.fromScale(0.94, 0.8)
TabContainer.BackgroundTransparency = 1

-- Guardado y lectura de settings local para mostrar valores iniciales
UPF.Settings = UPF.Settings or {}
UPF.State = UPF.State or {}

-- Inicializar valores si faltan
UPF.State.Audio = UPF.State.Audio or { Enabled = UPF.Settings.audio_shield_enabled or false, Radius = UPF.Settings.audio_shield_radius or 20, Level = UPF.Settings.audio_shield_level or 0.25 }
UPF.State.GodMode = (UPF.State.GodMode == nil) and (UPF.Settings.godmode_enabled or false) or UPF.State.GodMode
UPF.State.ProtectionEnabled = UPF.State.ProtectionEnabled or (UPF.Settings.protection_enabled or false)
UPF.State.AutoReturnEnabled = (UPF.State.AutoReturnEnabled == nil) and (UPF.Settings.auto_return_enabled or true) or UPF.State.AutoReturnEnabled
UPF.State.SmartMode = UPF.State.SmartMode or (UPF.Settings.smart_mode or "SAFE")
UPF.State.PerfState = UPF.State.PerfState or "NORMAL"

-- Helpers to safely call UPF APIs
local function safeUPFCall(fn, ...)
    if type(fn) ~= "function" then return false end
    local ok, res = pcall(fn, ...)
    if not ok then warn("UPF call failed:", res) end
    return ok, res
end

-- Actualiza la apariencia del botón principal de protección
local function updateProtectionUI()
    if UPF.State.ProtectionEnabled then
        ProtectionBtn.Text = "Disable Protection"
        ProtectionBtn.BackgroundColor3 = Color3.fromRGB(200,70,80)
    else
        ProtectionBtn.Text = "Enable Protection"
        ProtectionBtn.BackgroundColor3 = Color3.fromRGB(70,110,230)
    end
end

-- Actualizar God mode UI
local function updateGodUI()
    GodBtn.Text = UPF.State.GodMode and "God Mode: ON" or "God Mode: OFF"
    GodBtn.BackgroundColor3 = UPF.State.GodMode and Color3.fromRGB(60,160,90) or Color3.fromRGB(120,60,60)
end

-- Audio UI
local function updateAudioUI()
    AudioToggle.Text = (UPF.State.Audio and UPF.State.Audio.Enabled) and "Audio Shield: ON" or "Audio Shield: OFF"
    AudioToggle.BackgroundColor3 = (UPF.State.Audio and UPF.State.Audio.Enabled) and Color3.fromRGB(60,160,90) or Color3.fromRGB(110,110,110)
    RadiusLabel.Text = "Radius: " .. tostring( (UPF.State.Audio and UPF.State.Audio.Radius) or 20 )
end

-- Mode UI
local function updateModeUI()
    ModeLabel.Text = "Mode: " .. tostring(UPF.State.SmartMode or "SAFE")
    ModeToggle.Text = (UPF.State.SmartMode == "SAFE") and "PVP" or "SAFE"
    ModeToggle.BackgroundColor3 = (UPF.State.SmartMode == "SAFE") and Color3.fromRGB(80,140,200) or Color3.fromRGB(160,80,120)
end

-- Performance & freeze dynamic update (updated later)
local function updateStatusLabels()
    PerfLabel.Text = "⚙ Performance: " .. (UPF.State.PerfState or "NORMAL") .. "   |   🧊 Freeze: " .. (UPF.State.FrozenDetected and "FROZEN" or "NORMAL")
end

-- Inicial UI update
updateProtectionUI()
updateGodUI()
updateAudioUI()
updateModeUI()
updateStatusLabels()

-- Button behaviors
ProtectionBtn.MouseButton1Click:Connect(function()
    UPF:ToggleProtection()
    updateProtectionUI()
    if UPF.SaveSettings then pcall(function() UPF:SaveSettings() end) end
end)

ModeToggle.MouseButton1Click:Connect(function()
    local new = (UPF.State.SmartMode == "SAFE") and "PVP" or "SAFE"
    UPF.State.SmartMode = new
    if UPF.SaveSettings then pcall(function() UPF:SaveSettings() end) end
    updateModeUI()
end)

PanicBtn.MouseButton1Click:Connect(function()
    -- Activar protección y teletransportar al safepoint (safe recovery)
    pcall(function()
        if type(UPF.ToggleProtection) == "function" then UPF:ToggleProtection(true) end
        UPF.State.SmartMode = "SAFE"
        if type(UPF.ReturnToSafePoint) == "function" then UPF:ReturnToSafePoint() end
    end)
    -- feedback visual breve
    PanicBtn.BackgroundColor3 = Color3.fromRGB(120,120,120)
    task.delay(2.2, function() PanicBtn.BackgroundColor3 = Color3.fromRGB(180,60,60) end)
end)

GodBtn.MouseButton1Click:Connect(function()
    UPF:ToggleGodMode()
    updateGodUI()
    if UPF.SaveSettings then pcall(function() UPF:SaveSettings() end) end
end)

UnfreezeBtn.MouseButton1Click:Connect(function()
    pcall(function() if type(UPF.RecoverPlayer) == "function" then UPF:RecoverPlayer() end end)
end)

ReturnBtn.MouseButton1Click:Connect(function()
    pcall(function() if type(UPF.ReturnToSafePoint) == "function" then UPF:ReturnToSafePoint() end end)
end)

AudioToggle.MouseButton1Click:Connect(function()
    pcall(function() if type(UPF.ToggleAudioShield) == "function" then UPF:ToggleAudioShield() end end)
    -- sync state from UPF.State.Audio (ToggleAudioShield should update it)
    updateAudioUI()
    if UPF.SaveSettings then pcall(function() UPF:SaveSettings() end) end
end)

RadMinus.MouseButton1Click:Connect(function()
    local v = (UPF.State.Audio and UPF.State.Audio.Radius) or 20
    v = math.max(1, v - 5)
    pcall(function() if type(UPF.SetAudioShieldRadius) == "function" then UPF:SetAudioShieldRadius(v) end end)
    UPF.State.Audio.Radius = v
    updateAudioUI()
    if UPF.SaveSettings then pcall(function() UPF:SaveSettings() end) end
end)

RadPlus.MouseButton1Click:Connect(function()
    local v = (UPF.State.Audio and UPF.State.Audio.Radius) or 20
    v = v + 5
    pcall(function() if type(UPF.SetAudioShieldRadius) == "function" then UPF:SetAudioShieldRadius(v) end end)
    UPF.State.Audio.Radius = v
    updateAudioUI()
    if UPF.SaveSettings then pcall(function() UPF:SaveSettings() end) end
end)

-- Settings overlay behavior
local overlayOpen = false
local function openOverlay()
    if overlayOpen then return end
    overlayOpen = true
    Overlay.Visible = true
    quickTween(Overlay, {Position = UDim2.fromScale(0.94, 0.14)}, 0.36, Enum.EasingStyle.Cubic)
end
local function closeOverlay()
    if not overlayOpen then return end
    overlayOpen = false
    quickTween(Overlay, {Position = UDim2.fromScale(1.05, 0.14)}, 0.32)
    task.delay(0.32, function() Overlay.Visible = false end)
end

SettingsBtn.MouseButton1Click:Connect(function()
    if not overlayOpen then openOverlay() else closeOverlay() end
end)
CloseOverlayBtn.MouseButton1Click:Connect(closeOverlay)

-- Close & Minimize
CloseBtn.MouseButton1Click:Connect(function()
    -- shutdown UI only (no shutdown of UPF modules)
    pcall(function() ScreenGui:Destroy() end)
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    Floating.Visible = true
end)
Floating.MouseButton1Click:Connect(function()
    Main.Visible = true
    Floating.Visible = false
end)

-- Dragging for Main (header)
do
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Populate overlay General tab content (simple controls)
local function buildGeneralTab()
    -- clear
    for _,c in pairs(TabContainer:GetChildren()) do
        c:Destroy()
    end

    local t = Instance.new("Frame", TabContainer)
    t.Size = UDim2.fromScale(1, 0.95)
    t.Position = UDim2.fromScale(0,0)
    t.BackgroundTransparency = 1

    local y = 0.02
    local function addLabel(txt)
        local l = Instance.new("TextLabel", t)
        l.Size = UDim2.fromScale(0.96, 0.12)
        l.Position = UDim2.fromScale(0.02, y)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamBold
        l.TextScaled = true
        l.Text = txt
        l.TextColor3 = Color3.fromRGB(220,220,220)
        y = y + 0.13
    end

    local function addToggle(text, callback, initial)
        local btn = Instance.new("TextButton", t)
        btn.Size = UDim2.fromScale(0.5, 0.12)
        btn.Position = UDim2.fromScale(0.03, y)
        btn.Font = Enum.Font.GothamBold
        btn.TextScaled = true
        btn.Text = text .. (initial and " : ON" or " : OFF")
        btn.BackgroundColor3 = initial and Color3.fromRGB(60,160,90) or Color3.fromRGB(120,120,120)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
        y = y + 0.135
        btn.MouseButton1Click:Connect(function()
            local ok = pcall(callback)
            if ok then
                -- refresh labels
                buildGeneralTab()
            end
        end)
    end

    addLabel("General Settings")
    addToggle("Toggle GodMode", function()
        UPF:ToggleGodMode()
        if UPF.SaveSettings then UPF:SaveSettings() end
    end, UPF.State.GodMode)

    addToggle("Toggle AutoReturn", function()
        UPF.State.AutoReturnEnabled = not UPF.State.AutoReturnEnabled
        if UPF.SaveSettings then UPF:SaveSettings() end
    end, UPF.State.AutoReturnEnabled)

    addToggle("Toggle Audio Shield", function()
        UPF:ToggleAudioShield()
        if UPF.SaveSettings then UPF:SaveSettings() end
    end, (UPF.State.Audio and UPF.State.Audio.Enabled) or false)

    local radiusBox = Instance.new("TextLabel", t)
    radiusBox.Size = UDim2.fromScale(0.92, 0.12)
    radiusBox.Position = UDim2.fromScale(0.04, y)
    radiusBox.BackgroundTransparency = 1
    radiusBox.Font = Enum.Font.Gotham
    radiusBox.TextScaled = true
    radiusBox.TextColor3 = Color3.fromRGB(200,200,200)
    radiusBox.Text = "Audio Radius: " .. tostring((UPF.State.Audio and UPF.State.Audio.Radius) or 20)
    y = y + 0.14

    -- Return to safe point button in overlay
    local ret = Instance.new("TextButton", t)
    ret.Size = UDim2.fromScale(0.6, 0.12)
    ret.Position = UDim2.fromScale(0.2, y)
    ret.Font = Enum.Font.GothamBold
    ret.TextScaled = true
    ret.Text = "Return to Safe Point"
    ret.BackgroundColor3 = Color3.fromRGB(70,160,120)
    Instance.new("UICorner", ret).CornerRadius = UDim.new(0,10)
    ret.MouseButton1Click:Connect(function() UPF:ReturnToSafePoint() end)
end

buildGeneralTab()

-- FPS & status update (heartbeat)
do
    local last = tick()
    RunService.Heartbeat:Connect(function(dt)
        if not UPF.State then return end
        local now = tick()
        local fps = math.floor(1 / math.max(dt, 1e-6))
        local status = UPF.State.ProtectionEnabled and "ACTIVE" or "OFF"
        -- update labels
        PerfLabel.Text = "⚙ Performance: " .. (UPF.State.PerfState or "NORMAL") .. "   |   🧊 Freeze: " .. (UPF.State.FrozenDetected and "FROZEN" or "NORMAL")
        -- small periodic UI syncs (to reflect changes in UPF.State made by other modules)
        -- update Protection/God/Audio/Mode occasionally
        updateProtectionUI()
        updateGodUI()
        updateAudioUI()
        updateModeUI()
    end)
end

-- Exponer referencias UI en UPF.UI
UPF.UI = UPF.UI or {}
UPF.UI.ScreenGui = ScreenGui
UPF.UI.Main = Main
UPF.UI.Content = Content
UPF.UI.Overlay = Overlay
UPF.UI.Update = function()
    updateProtectionUI()
    updateGodUI()
    updateAudioUI()
    updateModeUI()
    updateStatusLabels()
end

-- Créditos en consola (solo una vez)
pcall(function()
    print(" ")
    print("==========================================")
    print("UPF Protection Framework UI loaded")
    print("Author: Sourcerer")
    print("Co-Developer: ChatGPT")
    print("Repository: script_roblox_proteccion_experimental")
    print("==========================================")
    print(" ")
end)

print("✅ UI module loaded and connected to UPF")