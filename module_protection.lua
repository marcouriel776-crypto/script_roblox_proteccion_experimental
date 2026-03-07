-- module_protection.lua
local UPF = _G.UPF
if not UPF then warn("UPF missing"); return end

local RunService = game:GetService("RunService")
local Utils = UPF.Utils

UPF.State.Protection = UPF.State.Protection or {}
UPF.State.Protection.BlockedEvents = UPF.State.Protection.BlockedEvents or 0
UPF.State.LastSafePosition = UPF.State.LastSafePosition or nil

local MAX_DISTANCE_PER_FRAME = 35
local MAX_LINEAR_VELOCITY = 120

local lastPosition = nil

UPF.Connections.ProtectionHeartbeat = RunService.Heartbeat:Connect(function()
    if not UPF.State.ScriptRunning then return end
    if not UPF.State.ProtectionEnabled then return end
    if not UPF.RootPart or not UPF.Humanoid then return end

    if not lastPosition then lastPosition = UPF.RootPart.Position return end

    local dist = (UPF.RootPart.Position - lastPosition).Magnitude
    if dist > MAX_DISTANCE_PER_FRAME then
        pcall(function() UPF.Utils.SafeRollback(UPF.RootPart, CFrame.new(lastPosition)) end)
        UPF.Utils.ClearForces(UPF.RootPart)
        UPF.State.Protection.BlockedEvents = UPF.State.Protection.BlockedEvents + 1
    end

    local vel = 0
    pcall(function() vel = UPF.RootPart.AssemblyLinearVelocity.Magnitude end)
    if vel > MAX_LINEAR_VELOCITY then
        UPF.Utils.ClearForces(UPF.RootPart)
        UPF.State.Protection.BlockedEvents = UPF.State.Protection.BlockedEvents + 1
    end

    if UPF.Humanoid and UPF.Humanoid.FloorMaterial ~= Enum.Material.Air and vel < 10 then
        UPF.State.LastSafePosition = UPF.RootPart.CFrame
    end

    lastPosition = UPF.RootPart.Position
end)

print("✅ Protection module loaded (UPF-connected)")