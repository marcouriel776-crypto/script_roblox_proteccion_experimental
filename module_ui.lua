-- module_ui.lua
-- UI helpers: style, sections, floating button polish, small animations
-- Loads AFTER module_core.lua (expects CoreReady + Content + Main already exist)

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- wait for core
repeat task.wait() until CoreReady
local ok, ScreenGui = pcall(function() return CoreGui:FindFirstChild("ProtectionUI") end)
if not ok or not ScreenGui then
    warn("module_ui: ProtectionUI not found, aborting UI helpers")
    return
end

-- find Main and Content
local Main = ScreenGui:FindFirstChildOfClass("Frame")
local Content = ScreenGui:FindFirstChildWhichIsA("ScrollingFrame") or ScreenGui:FindFirstChild("Content")
if not Main or not Content then
    warn("module_ui: Main or Content not detected (structure mismatch).")
    return
end

-- tiny helpers
local function safeTween(obj, props, time, style, dir)
    local suc, err = pcall(function()
        local info = TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
        local tween = TweenService:Create(obj, info, props)
        tween:Play()
    end)
    if not suc then warn("safeTween failed:", err) end
end

-- StyleButton: consistent look
function StyleButton(btn, kind)
    if not btn or not btn:IsA("GuiObject") then return end
    local colors = {
        primary = Color3.fromRGB(70,120,220),
        danger = Color3.fromRGB(190,60,60),
        success = Color3.fromRGB(60,160,90),
        neutral = Color3.fromRGB(90,90,100)
    }
    local color = colors[kind] or colors.neutral
    pcall(function()
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.fromRGB(245,245,245)
        btn.AutoButtonColor = true
        if not btn:FindFirstChildOfClass("UICorner") then Instance.new("UICorner", btn).CornerRadius = UDim.new(0,14) end
    end)
end

-- CreateSection: nice title + divider
function CreateSection(title)
    local Holder = Instance.new("Frame")
    Holder.Name = "Section_" .. tostring(title)
    Holder.Parent = Content
    Holder.Size = UDim2.fromScale(0.95, 0.08)
    Holder.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel")
    Label.Parent = Holder
    Label.Size = UDim2.fromScale(1, 0.9)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.Font = Enum.Font.GothamBold
    Label.TextScaled = true
    Label.TextColor3 = Color3.fromRGB(200,200,220)
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Line = Instance.new("Frame")
    Line.Parent = Holder
    Line.Size = UDim2.fromScale(1, 0.05)
    Line.Position = UDim2.fromScale(0, 0.95)
    Line.BackgroundColor3 = Color3.fromRGB(65,65,80)
    Line.BorderSizePixel = 0

    return Holder, Label
end

-- Floating button polish: add hover scale + quick fade
local Floating = ScreenGui:FindFirstChildOfClass("TextButton")
if Floating then
    -- hover scale (touch devices ignore hover but it's safe)
    Floating:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() end)
    Floating.MouseEnter:Connect(function() safeTween(Floating, {Size = UDim2.fromScale(0.135,0.135)}, 0.12) end)
    Floating.MouseLeave:Connect(function() safeTween(Floating, {Size = UDim2.fromScale(0.12,0.12)}, 0.12) end)
    -- show tiny shadow by duplicating a frame behind (if not present)
    if not Floating:FindFirstChild("Shadow") then
        local sh = Instance.new("Frame")
        sh.Name = "Shadow"
        sh.Size = UDim2.fromScale(1.04,1.04)
        sh.Position = UDim2.fromScale(-0.02,-0.02)
        sh.BackgroundTransparency = 0.6
        sh.BackgroundColor3 = Color3.fromRGB(0,0,0)
        sh.ZIndex = Floating.ZIndex - 1
        sh.Parent = Floating
        sh.Rotation = 0
        Instance.new("UICorner", sh).CornerRadius = UDim.new(1,0)
    end
    -- quick fade in/out helpers
    function FadeOutMain()
        safeTween(Main, {Position = UDim2.fromScale(Main.Position.X.Scale, Main.Position.Y.Scale + 0.02), BackgroundTransparency = 1}, 0.18)
        Main.Visible = false
    end
    function FadeInMain()
        Main.Visible = true
        safeTween(Main, {Position = UDim2.fromScale(Main.Position.X.Scale, Main.Position.Y.Scale - 0.02), BackgroundTransparency = 0}, 0.18)
    end
end

-- Try to restyle known core buttons if present
pcall(function()
    local prot = Content:FindFirstChild("ProtectionToggle") or Content:FindFirstChildOfClass("TextButton")
    if prot then StyleButton(prot, "primary") end
    local close = Main:FindFirstChild("CloseButton") or Main:FindFirstChildWhichIsA("TextButton")
    if close then StyleButton(close, "danger") end
    local minb = Main:FindFirstChild("MinimizeButton")
    if minb then StyleButton(minb, "neutral") end
end)

-- Expose API to other modules
_G.UI_CreateSection = CreateSection
_G.UI_StyleButton = StyleButton
_G.UI_FadeInMain = FadeInMain
_G.UI_FadeOutMain = FadeOutMain

print("✅ module_ui loaded — UI helpers ready")