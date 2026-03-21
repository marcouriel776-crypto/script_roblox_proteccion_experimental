local UPF = getgenv().UPF

local Resilience = {}
UPF.Resilience = Resilience

local lastRecovery = 0

function Resilience:Check(character)
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local velocity = root.Velocity.Magnitude

    if velocity < 1 and tick() - lastRecovery > 5 then
        lastRecovery = tick()

        warn("[Resilience] Recovering player...")

        root.CFrame = root.CFrame + Vector3.new(0,5,0)
    end
end

return Resilience
