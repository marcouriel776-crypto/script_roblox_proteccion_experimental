-- module_ui_logs.lua (corregido: no usa propiedades custom en Instances)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UPF = _G.UPF
local waited = 0
while (not UPF) and waited < 3 do task.wait(0.1); waited = waited + 0.1; UPF = _G.UPF end
if not UPF then
    warn("[module_ui_logs] UPF no encontrado, abortando.")
    return
end

UPF.State = UPF.State or {}
UPF.State.ModalHistory = UPF.State.ModalHistory or {}
UPF.State.Resilience = UPF.State.Resilience or {}
UPF.State.Protection = UPF.State.Protection or {}
UPF.State.Smart = UPF.State.Smart or {}

UPF.Connections = UPF.Connections or {}

local ui = UPF.UI
local POLL_INTERVAL = 1.0
local lastModalTime = 0
local lastReconnectAttempts = (UPF.State.Resilience and UPF.State.Resilience.reconnectAttempts) or 0
local lastBlockedEvents = (UPF.State.Protection and UPF.State.Protection.BlockedEvents) or 0
local lastFlingEvents = UPF.State.FlingEvents or 0

local function nowStr() return os.date("%Y-%m-%d %H:%M:%S", os.time()) end

local function pushHistory(kind, text, extra)
    UPF.State.ModalHistory = UPF.State.ModalHistory or {}
    local entry = { time = nowStr(), kind = kind or "event", text = text or "", extra = extra or {} }
    table.insert(UPF.State.ModalHistory, 1, entry)
    if #UPF.State.ModalHistory > 200 then
        for i = 201, #UPF.State.ModalHistory do UPF.State.ModalHistory[i] = nil end
    end
    return entry
end

if UPF.State.ModalInfo and UPF.State.ModalInfo.time and (UPF.State.ModalInfo.time > (lastModalTime or 0)) then
    pushHistory("modal", UPF.State.ModalInfo.text or "(sin texto)", {path = UPF.State.ModalInfo.path})
    lastModalTime = UPF.State.ModalInfo.time
end

local logsButton = nil
local logsWindow = nil
local logsWindowRefresher = nil -- << guardamos la función refresher aquí

local function createLogsButton()
    if not ui or not ui.Content then return end
    if ui.Content:FindFirstChild("UPF_LogsBtn") then
        logsButton = ui.Content.UPF_LogsBtn
        return
    end
    local btn = Instance.new("TextButton")
    btn.Name = "UPF_LogsBtn"
    btn.Size = UDim2.fromScale(0.78, 0.12)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.Text = "Open Logs"
    btn.BackgroundColor3 = Color3.fromRGB(120,120,140)
    btn.TextColor3 = Color3.fromRGB(245,245,245)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,14)
    btn.Parent = ui.Content
    logsButton = btn

    btn.MouseButton1Click:Connect(function()
        if logsWindow and logsWindow.Parent and logsWindow.Visible then
            logsWindow.Visible = false
        else
            if not logsWindow then buildLogsWindow() end
            if logsWindowRefresher then logsWindowRefresher() end
            logsWindow.Visible = true
        end
    end)
end

function buildLogsWindow()
    if not ui or not ui.ScreenGui then return end
    local sg = ui.ScreenGui
    if sg:FindFirstChild("UPF_LogsWindow") then
        logsWindow = sg.UPF_LogsWindow
        return
    end

    local frame = Instance.new("Frame")
    frame.Name = "UPF_LogsWindow"
    frame.Size = UDim2.fromOffset(520, 380)
    frame.Position = UDim2.fromScale(0.5, 0.12)
    frame.AnchorPoint = Vector2.new(0.5,0)
    frame.BackgroundColor3 = Color3.fromRGB(18,18,22)
    frame.Parent = sg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

    local header = Instance.new("Frame", frame); header.Size = UDim2.new(1,0,0,42); header.Position = UDim2.new(0,0,0,0); header.BackgroundTransparency = 1
    local title = Instance.new("TextLabel", header); title.Size = UDim2.fromScale(0.7,1); title.Position = UDim2.fromScale(0.02,0); title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamBold; title.Text = "UPF Logs"; title.TextColor3 = Color3.fromRGB(230,230,230); title.TextScaled = true; title.TextXAlignment = Enum.TextXAlignment.Left

    local closeBtn = Instance.new("TextButton", header); closeBtn.Size = UDim2.fromOffset(36, 28); closeBtn.Position = UDim2.new(1, -44, 0.12, 0); closeBtn.Text = "✕"; closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextColor3 = Color3.fromRGB(240,240,240); closeBtn.BackgroundColor3 = Color3.fromRGB(60,60,60); Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,8)
    closeBtn.MouseButton1Click:Connect(function() frame.Visible = false end)

    local clearBtn = Instance.new("TextButton", header); clearBtn.Size = UDim2.fromOffset(90, 28); clearBtn.Position = UDim2.new(1, -140, 0.12, 0); clearBtn.Text = "Clear"; clearBtn.Font = Enum.Font.GothamBold; clearBtn.BackgroundColor3 = Color3.fromRGB(140,60,60); clearBtn.TextColor3 = Color3.fromRGB(255,255,255); Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0,8)

    local exportBtn = Instance.new("TextButton", header); exportBtn.Size = UDim2.fromOffset(120,28); exportBtn.Position = UDim2.new(1, -260, 0.12, 0); exportBtn.Text = "Export to Console"; exportBtn.Font = Enum.Font.GothamBold; exportBtn.BackgroundColor3 = Color3.fromRGB(70,120,200); exportBtn.TextColor3 = Color3.fromRGB(255,255,255); Instance.new("UICorner", exportBtn).CornerRadius = UDim.new(0,8)

    local listFrame = Instance.new("ScrollingFrame", frame); listFrame.Size = UDim2.new(1, -20, 1, -80); listFrame.Position = UDim2.new(0,10,0,50); listFrame.BackgroundTransparency = 1; listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y; listFrame.ScrollBarThickness = 8
    local listLayout = Instance.new("UIListLayout", listFrame); listLayout.SortOrder = Enum.SortOrder.LayoutOrder; listLayout.Padding = UDim.new(0, 8)

    local footer = Instance.new("Frame", frame); footer.Size = UDim2.new(1,0,0,36); footer.Position = UDim2.new(0,0,1,-36); footer.BackgroundTransparency = 1
    local statsLabel = Instance.new("TextLabel", footer); statsLabel.Size = UDim2.new(1,0,1,0); statsLabel.BackgroundTransparency = 1; statsLabel.Font = Enum.Font.Gotham; statsLabel.TextScaled = true; statsLabel.TextColor3 = Color3.fromRGB(190,190,220); statsLabel.Text = "Blocked: 0 | Flings: 0 | Reconnects: 0"; statsLabel.TextXAlignment = Enum.TextXAlignment.Left; statsLabel.TextYAlignment = Enum.TextYAlignment.Center

    local function createListRow(entry, idx)
        local row = Instance.new("Frame"); row.Size = UDim2.new(1, -20, 0, 72); row.BackgroundColor3 = Color3.fromRGB(14,14,16); row.LayoutOrder = idx; Instance.new("UICorner", row).CornerRadius = UDim.new(0,8); row.Parent = listFrame
        local title = Instance.new("TextLabel", row); title.Size = UDim2.new(0.7, -12, 0.55, 0); title.Position = UDim2.new(0.02, 0, 0.06, 0); title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamBold; title.TextScaled = true; title.TextColor3 = Color3.fromRGB(230,230,230); title.Text = "[" .. (entry.kind or "event") .. "] " .. (entry.time or "")
        local body = Instance.new("TextLabel", row); body.Size = UDim2.new(0.9, -12, 0.32, 0); body.Position = UDim2.new(0.02, 0, 0.52, 0); body.BackgroundTransparency = 1; body.Font = Enum.Font.Gotham; body.TextWrapped = true; body.TextColor3 = Color3.fromRGB(200,200,200); body.Text = entry.text or ""
        local action1 = Instance.new("TextButton", row); action1.Size = UDim2.new(0.2, -8, 0.32, 0); action1.Position = UDim2.new(0.72, 6, 0.12, 0); action1.Text = "Recover"; action1.Font = Enum.Font.GothamBold; action1.BackgroundColor3 = Color3.fromRGB(60,160,90); Instance.new("UICorner", action1).CornerRadius = UDim.new(0,8)
        local action2 = Instance.new("TextButton", row); action2.Size = UDim2.new(0.2, -8, 0.32, 0); action2.Position = UDim2.new(0.72, 6, 0.52, 0); action2.Text = "Reconnect"; action2.Font = Enum.Font.GothamBold; action2.BackgroundColor3 = Color3.fromRGB(70,120,220); Instance.new("UICorner", action2).CornerRadius = UDim.new(0,8)
        action1.MouseButton1Click:Connect(function() pcall(function() if UPF.Resilience and UPF.Resilience.AttemptRecovery then UPF.Resilience.AttemptRecovery() end end) end)
        action2.MouseButton1Click:Connect(function() pcall(function() if UPF.Resilience and UPF.Resilience.AttemptReconnect then UPF.Resilience.AttemptReconnect() end end) end)
    end

    clearBtn.MouseButton1Click:Connect(function()
        UPF.State.ModalHistory = {}
        for _, child in pairs(listFrame:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
        statsLabel.Text = "Blocked: 0 | Flings: 0 | Reconnects: 0"
    end)

    exportBtn.MouseButton1Click:Connect(function()
        print("=== UPF ModalHistory Export (".. # (UPF.State.ModalHistory or {}) .." entries) ===")
        for i = 1, #UPF.State.ModalHistory do
            local e = UPF.State.ModalHistory[i]
            print(i, e.time, e.kind, e.text)
            if e.extra and (next(e.extra) ~= nil) then
                for k,v in pairs(e.extra) do print("  -", k, v) end
            end
        end
        print("=== End Export ===")
    end)

    local function refresh()
        for _, child in pairs(listFrame:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
        local hist = UPF.State.ModalHistory or {}
        for i = 1, #hist do createListRow(hist[i], i) end
        local blocked = (UPF.State.Protection and UPF.State.Protection.BlockedEvents) or 0
        local flings = UPF.State.FlingEvents or 0
        local reconnects = (UPF.State.Resilience and UPF.State.Resilience.reconnectAttempts) or 0
        statsLabel.Text = ("Blocked: %d | Flings: %d | Reconnects: %d"):format(blocked, flings, reconnects)
        listFrame.CanvasSize = UDim2.new(0,0,0, (listFrame.UIListLayout.AbsoluteContentSize.Y + 12))
    end

    frame.GetRefresher = nil -- no usamos propiedad en instancia
    logsWindowRefresher = refresh -- << guardamos la referencia aquí
    logsWindow = frame
    logsWindow.Visible = false
end

local function refreshLogsWindow()
    if logsWindowRefresher then logsWindowRefresher() end
end

local autoReconnectBtn = nil
local function createAutoReconnectControl()
    if not ui or not ui.Content then return end
    if ui.Content:FindFirstChild("UPF_AutoReconnectBtn") then autoReconnectBtn = ui.Content.UPF_AutoReconnectBtn; return end
    local btn = Instance.new("TextButton"); btn.Name = "UPF_AutoReconnectBtn"; btn.Size = UDim2.fromScale(0.78, 0.12); btn.Font = Enum.Font.GothamBold; btn.TextScaled = true; Instance.new("UICorner", btn).CornerRadius = UDim.new(0,14); btn.Parent = ui.Content
    autoReconnectBtn = btn
    local function update()
        local enabled = (UPF.State.Resilience and UPF.State.Resilience.auto_reconnect_enabled) or (UPF.Settings and UPF.Settings.auto_reconnect_enabled) or false
        autoReconnectBtn.Text = "Auto-Reconnect: " .. (enabled and "ON" or "OFF")
        autoReconnectBtn.BackgroundColor3 = enabled and Color3.fromRGB(60,160,90) or Color3.fromRGB(120,120,120)
    end
    btn.MouseButton1Click:Connect(function()
        UPF.State.Resilience.auto_reconnect_enabled = not (UPF.State.Resilience.auto_reconnect_enabled or UPF.Settings.auto_reconnect_enabled)
        UPF.Settings.auto_reconnect_enabled = UPF.State.Resilience.auto_reconnect_enabled
        if UPF.SaveSettings then pcall(function() UPF:SaveSettings() end) end
        update()
    end)
    update()
end

if ui and ui.ScreenGui then
    createLogsButton()
    buildLogsWindow()
    createAutoReconnectControl()
end

if UPF.Connections and UPF.Connections.UILogsMonitor and typeof(UPF.Connections.UILogsMonitor) == "RBXScriptConnection" then
    pcall(function() UPF.Connections.UILogsMonitor:Disconnect() end)
    UPF.Connections.UILogsMonitor = nil
end

UPF.Connections.UILogsMonitor = RunService.Heartbeat:Connect(function(dt)
    local m = UPF.State.ModalInfo
    if m and m.time and m.time > (lastModalTime or 0) then
        lastModalTime = m.time
        pushHistory("modal", m.text or "(sin texto)", {path = m.path, reason = m.reason})
        refreshLogsWindow()
    end

    local rAttempts = (UPF.State.Resilience and UPF.State.Resilience.reconnectAttempts) or 0
    if rAttempts and rAttempts > lastReconnectAttempts then
        pushHistory("reconnect", ("Attempt %d"):format(rAttempts), {attempts = rAttempts})
        lastReconnectAttempts = rAttempts
        refreshLogsWindow()
    end

    local blocked = (UPF.State.Protection and UPF.State.Protection.BlockedEvents) or 0
    if blocked and blocked > lastBlockedEvents then
        pushHistory("blocked", ("BlockedEvents => %d"):format(blocked), {})
        lastBlockedEvents = blocked
        refreshLogsWindow()
    end

    local fl = UPF.State.FlingEvents or 0
    if fl and fl > lastFlingEvents then
        pushHistory("fling", ("FlingEvents => %d"):format(fl), {})
        lastFlingEvents = fl
        refreshLogsWindow()
    end

    if autoReconnectBtn then
        local enabled = (UPF.State.Resilience and UPF.State.Resilience.auto_reconnect_enabled) or (UPF.Settings and UPF.Settings.auto_reconnect_enabled) or false
        autoReconnectBtn.Text = "Auto-Reconnect: " .. (enabled and "ON" or "OFF")
        autoReconnectBtn.BackgroundColor3 = enabled and Color3.fromRGB(60,160,90) or Color3.fromRGB(120,120,120)
    end
end)

print("✅ module_ui_logs loaded — Logs panel & Auto-Reconnect control added (if UPF.UI was available)")