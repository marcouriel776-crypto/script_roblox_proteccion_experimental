local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local UPF = _G.UPF

local lastPos
local lastMove = tick()

RunService.Heartbeat:Connect(function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local pos = root.Position

    if lastPos then
        if (pos - lastPos).Magnitude < 0.1 then
            if tick() - lastMove > 5 then
                root.CFrame = root.CFrame + Vector3.new(0,5,0)
                root.AssemblyLinearVelocity = Vector3.zero
                print("🛠 Recovery")
                lastMove = tick()
            end
        else
            lastMove = tick()
        end
    end

    lastPos = pos
end)

print("✅ Resilience loaded")
