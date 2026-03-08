-- module_ui_logs.lua
-- UPF Logs Window

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

UPF.Logs = UPF.Logs or {}

local logs = UPF.Logs

local function getLogsWindow()

    local player = game.Players.LocalPlayer
    local gui = player:WaitForChild("PlayerGui")

    local protectionUI = gui:FindFirstChild("ProtectionUI")
    if not protectionUI then return nil end

    local logsWindow = protectionUI:FindFirstChild("UPF_LogsWindow")
    if not logsWindow then return nil end

    return logsWindow

end

------------------------------------------------
-- REFRESH WINDOW
------------------------------------------------

local function refreshLogsWindow()

    local window = getLogsWindow()
    if not window then return end

    local container = window:FindFirstChild("LogsContainer")
    if not container then return end

    for _,child in pairs(container:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    for i,entry in ipairs(logs) do

        local label = Instance.new("TextLabel")

        label.Size = UDim2.new(1,0,0,20)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextSize = 14
        label.Font = Enum.Font.Code
        label.Text = entry

        label.Parent = container

    end

end

------------------------------------------------
-- ADD LOG
------------------------------------------------

function UPF:AddLog(text)

    local timestamp = os.date("%X")

    local entry = "["..timestamp.."] "..tostring(text)

    table.insert(logs, entry)

    if #logs > 200 then
        table.remove(logs,1)
    end

    refreshLogsWindow()

end

------------------------------------------------
-- EXPORT LOGS
------------------------------------------------

function UPF:ExportLogs()

    print("=== UPF Modal History Export ("..#logs.." entries) ===")

    for _,v in ipairs(logs) do
        print(v)
    end

    print("=== End Export ===")

end

print("✅ module_ui_logs loaded")