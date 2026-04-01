-- module_protection.lua (FIXED PRO)

local UPF = _G.UPF
if not UPF then warn("UPF missing"); return end

local RunService = game:GetService("RunService")

UPF.State.Protection = UPF.State.Protection or {}
UPF.State.Protection.BlockedEvents = UPF.State.Protection.BlockedEvents or 0
UPF.State.LastSafePosition = UPF.State.LastSafePosition or nil

local MAX_DISTANCE_PER_FRAME = 60
local MAX_LINEAR_VELOCITY = 120

local lastPosition = nil

UPF.Connections.ProtectionHeartbeat = RunService.Heartbeat:Connect(function()

    if not UPF.State.ScriptRunning then return end
    if not UPF.State.ProtectionEnabled then return end
    if not UPF.RootPart or not UPF.Humanoid then return end

    local currentPos = UPF.RootPart.Position

    if not lastPosition then
        lastPosition = currentPos
        return
    end

    local dist = (currentPos - lastPosition).Magnitude
    local vel = 0
    pcall(function()
        vel = UPF.RootPart.AssemblyLinearVelocity.Magnitude
    end)

    -- 🔴 IGNORAR FLING (alta velocidad)
    if vel > 120 then
        lastPosition = currentPos
        return
    end

    -- 🔴 IGNORAR CAÍDA AL VACÍO
    if currentPos.Y < -20 then
        return
    end

    -- 🛡️ DETECCIÓN TELEPORT
    if dist > MAX_DISTANCE_PER_FRAME then
        if UPF.State.LastSafePosition then
            pcall(function()
                UPF.Utils.SafeRollback(UPF.RootPart, UPF.State.LastSafePosition)
            end)
        end

        UPF.Utils.ClearForces(UPF.RootPart)
        UPF.State.Protection.BlockedEvents += 1
    end

    -- 🛡️ ANTI-FLING (extra)
    if vel > MAX_LINEAR_VELOCITY then
        UPF.Utils.ClearForces(UPF.RootPart)
        UPF.State.Protection.BlockedEvents += 1
    end

    -- ✅ GUARDAR POSICIÓN SEGURA REAL
    if UPF.Humanoid.FloorMaterial ~= Enum.Material.Air and vel < 10 then
        UPF.State.LastSafePosition = UPF.RootPart.CFrame
    end

    lastPosition = currentPos

end)

print("✅ Protection PRO loaded")
