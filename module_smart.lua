-- module_smart.lua
local UPF = _G.UPF
if not UPF then warn("UPF missing"); return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

UPF.State.SmartMode = UPF.State.SmartMode or "SAFE"
UPF.State.DangerousPlayers = UPF.State.DangerousPlayers or {}
UPF.State.FlingEvents = UPF.State.FlingEvents or 0

local function MarkDanger(plr)
    UPF.State.DangerousPlayers[plr] = tick()
    UPF.State.FlingEvents = (UPF.State.FlingEvents or 0) + 1
end

local function CleanupDanger()
    for plr, t in pairs(UPF.State.DangerousPlayers) do
        if tick() - t > 3 then
            UPF.State.DangerousPlayers[plr] = nil
        end
    end
end

UPF.Connections.SmartHeartbeat = RunService.Heartbeat:Connect(function()
    if not UPF.State.ScriptRunning then return end
    if not UPF.State.ProtectionEnabled then return end

    CleanupDanger()

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local ok, vel = pcall(function() return hrp.AssemblyLinearVelocity.Magnitude end)
            if ok and vel then
                local threshold = (UPF.State.SmartMode == "SAFE") and 80 or 120
                if vel > threshold then MarkDanger(plr) end
            end
            for _, c in ipairs(hrp:GetChildren()) do
                if c:IsA("BodyVelocity") or c:IsA("LinearVelocity") then MarkDanger(plr) end
            end
        end
    end
end)

print("✅ Smart module v2 loaded")