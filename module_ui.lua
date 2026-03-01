-- module_ui.lua
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

repeat task.wait() until CoreReady
local ok, ScreenGui = pcall(function() return CoreGui:FindFirstChild("ProtectionUI") end)
if not ok or not ScreenGui then
    warn("module_ui: ProtectionUI not found, aborting UI helpers")
    return
end

local Main = ScreenGui:FindFirstChild("Main") or ScreenGui:FindFirstChildOfClass("Frame")
local Content
if Main then
    Content = Main:FindFirstChild("Content") or Main:FindFirstChildWhichIsA("ScrollingFrame")
end
if not Content then
    Content = ScreenGui:FindFirstChildWhichIsA("ScrollingFrame") or ScreenGui:FindFirstChild("Content")
end

if not Main or not Content then
    warn("module_ui: Main or Content not detected (structure mismatch).")
    pcall(function()
        print("module_ui: ScreenGui children:")
        for i, c in ipairs(ScreenGui:GetChildren()) do
            print(" -", i, c.Name, c.ClassName)
            for j, cc in ipairs(c:GetChildren()) do
                print("    ->", j, cc.Name, cc.ClassName)
            end
        end
    end)
    return
end

local function safeTween(obj, props, time, style, dir)
    local suc, err = pcall(function()
        local info = TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
        local tween = TweenService:Create(obj, info, props)
        tween:Play()
    end)
    if not suc then warn("safeTween failed:", err) end
end

local function StyleButton(btn, kind)
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

local function CreateSection(title)
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

local Floating = ScreenGui:FindFirstChild("FloatingButton") or ScreenGui:FindFirstChildOfClass("TextButton")

local function FadeOutMain()
    Main.Visible = false
end
local function FadeInMain()
    Main.Visible = true
end

if Floating then
    pcall(function()
        Floating:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() end)
    end)
    pcall(function()
        Floating.MouseEnter:Connect(function() safeTween(Floating, {Size = UDim2.fromScale(0.135,0.135)}, 0.12) end)
        Floating.MouseLeave:Connect(function() safeTween(Floating, {Size = UDim2.fromScale(0.12,0.12)}, 0.12) end)
    end)
    if not Floating:FindFirstChild("Shadow") then
        local sh = Instance.new("Frame")
        sh.Name = "Shadow"
        sh.Size = UDim2.fromScale(1.04,1.04)
        sh.Position = UDim2.fromScale(-0.02,-0.02)
        sh.BackgroundTransparency = 0.6
        sh.BackgroundColor3 = Color3.fromRGB(0,0,0)
        sh.ZIndex = math.max(0, (Floating.ZIndex or 0) - 1)
        sh.Parent = Floating
        Instance.new("UICorner", sh).CornerRadius = UDim.new(1,0)
    end

    function FadeOutMain()
        pcall(function()
            safeTween(Main, {Position = Main.Position + UDim2.fromScale(0,0.02), BackgroundTransparency = 1}, 0.18)
            task.delay(0.18, function() Main.Visible = false end)
        end)
    end
    function FadeInMain()
        pcall(function()
            Main.Visible = true
            safeTween(Main, {Position = Main.Position - UDim2.fromScale(0,0.02), BackgroundTransparency = 0}, 0.18)
        end)
    end
end

pcall(function()
    local prot = Content:FindFirstChild("ProtectionToggle") or Content:FindFirstChildOfClass("TextButton")
    if prot then StyleButton(prot, "primary") end
    local close = Main:FindFirstChild("CloseButton") or Main:FindFirstChildWhichIsA("TextButton")
    if close then StyleButton(close, "danger") end
    local minb = Main:FindFirstChild("MinimizeButton")
    if minb then StyleButton(minb, "neutral") end
end)

_G.UI_CreateSection = CreateSection
_G.UI_StyleButton = StyleButton
_G.UI_FadeInMain = FadeInMain
_G.UI_FadeOutMain = FadeOutMain

print("✅ module_ui loaded — UI helpers ready")