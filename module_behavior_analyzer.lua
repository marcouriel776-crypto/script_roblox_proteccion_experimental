-- module_behavior_analyzer.lua (FIXED)

local UPF = getgenv().UPF
local RunService = game:GetService("RunService")

local Analyzer = {}
UPF.Analyzer = Analyzer

local velocityHistory = {}
local lastCheck = 0

function Analyzer:Track(root)
    local v = root.AssemblyLinearVelocity.Magnitude

    table.insert(velocityHistory, v)
    if #velocityHistory > 15 then
        table.remove(velocityHistory, 1)
    end
end

function Analyzer:Evaluate()
    if tick() - lastCheck < 2 then return end
    lastCheck = tick()

    local spikes = 0

    for _, v in ipairs(velocityHistory) do
        if v > 150 then
            spikes += 1
        end
    end

    UPF.Flags = UPF.Flags or {}

    if spikes > 6 then
        UPF.Flags.SuspiciousMovement = true
    else
        UPF.Flags.SuspiciousMovement = false
    end
end

RunService.Heartbeat:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    Analyzer:Track(root)
    Analyzer:Evaluate()
end)

print("✅ Behavior Analyzer fixed")
