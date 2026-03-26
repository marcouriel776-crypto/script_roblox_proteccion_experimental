local UPF = getgenv().UPF

local Analyzer = {}
UPF.Analyzer = Analyzer

local velocityHistory = {}
local lastCheck = 0

function Analyzer:TrackCharacter(char)
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local v = root.Velocity.Magnitude
    table.insert(velocityHistory, v)

    if #velocityHistory > 20 then
        table.remove(velocityHistory, 1)
    end
end

function Analyzer:Evaluate()
    if tick() - lastCheck < 2 then return end
    lastCheck = tick()

    local spikes = 0

    for _, v in ipairs(velocityHistory) do
        if v > 120 then
            spikes += 1
        end
    end

    if spikes > 5 then
        warn("[UPF.AI] comportamiento anómalo detectado")
        UPF.Flags = UPF.Flags or {}
        UPF.Flags.SuspiciousMovement = true
    else
        UPF.Flags.SuspiciousMovement = false
    end
end

return Analyzer