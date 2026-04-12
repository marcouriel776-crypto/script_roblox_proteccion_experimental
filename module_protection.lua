local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local UPF = _G.UPF

local lastPos = nil
local safeCFrame = nil

RunService.Heartbeat:Connect(function()
    if not UPF.State.ProtectionEnabled then return end

    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local pos = root.Position
    local vel = root.AssemblyLinearVelocity.Magnitude

    if vel < 10 then
        safeCFrame = root.CFrame
    end

    if lastPos then
        local dist = (pos - lastPos).Magnitude

        if dist > 50 and safeCFrame then
            root.CFrame = safeCFrame
            root.AssemblyLinearVelocity = Vector3.zero
            warn("🚫 Teleport blocked")
        end
    end

    lastPos = pos
end)

print("✅ AntiTeleport loaded")
