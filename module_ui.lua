local UPF = getgenv().UPF

local UI = {}
UPF.UI = UI

function UI:Init()
    local player = game.Players.LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "ProtectionUI"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 180)
    frame.Position = UDim2.new(0.5, -150, 0.5, -90)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.Parent = gui
    frame.Active = true
    frame.Draggable = true

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = "Universal Protection"
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1,1,1)
    title.Parent = frame

    local status = Instance.new("TextLabel")
    status.Position = UDim2.new(0,0,0,30)
    status.Size = UDim2.new(1,0,0,25)
    status.Text = "Status: ACTIVE"
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.new(0,1,0)
    status.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 40)
    btn.Position = UDim2.new(0.1, 0, 0.6, 0)
    btn.Text = "Disable Protection"
    btn.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = frame

    btn.MouseButton1Click:Connect(function()
        UPF.Enabled = not UPF.Enabled
        status.Text = UPF.Enabled and "Status: ACTIVE" or "Status: DISABLED"
    end)

    UI.Frame = frame
end

return UI
