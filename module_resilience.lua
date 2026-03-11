-- module_resilience.lua
-- SAFE VERSION (NO REJOIN)
-- Detecta stuck/freeze y realiza *solo* recovery local; NO usa TeleportService.

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

UPF.Resilience = UPF.Resilience or {}

-- Estado de resilience (seguro)
UPF.State = UPF.State or {}
UPF.State.Resilience = UPF.State.Resilience or {}

local RES = UPF.State.Resilience
RES.paused = RES.paused or false
RES.reconnectAttempts = RES.reconnectAttempts or 0
RES.lastReconnect = RES.lastReconnect or 0

local STUCK_TIME = 6 -- segundos (ajustable)
local MIN_MOVE_DIST = 0.5

-- Estado interno
local lastMoveTick = tick()
local lastPos = nil
local stuckDetectedAt = nil
local heartbeatConn = nil

local function safePrint(msg)
    pcall(function()
        if msg == nil then
            print("[resilience] (nil)")
        else
            print("[resilience] "..tostring(msg))
        end
    end)
end

-- Recovery local (no teleport)
function UPF.Resilience.AttemptRecovery()
    safePrint("AttemptRecovery: trying local recover functions")
    -- Preferir funciones públicas si existen en UPF
    if type(UPF.RecoverPlayer) == "function" then
        pcall(function() UPF:RecoverPlayer() end)
    end
    if type(UPF.ReturnToSafePoint) == "function" then
        pcall(function() UPF:ReturnToSafePoint() end)
    end
    -- fallback: try to clear velocities
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function()
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end
    safePrint("Player recovered")
end

-- NO existe AttemptReconnect en esta versión (no hacemos teleports).
-- Proporcionamos funciones Pause/Resume para control manual.
function UPF.Resilience.Pause()
    RES.paused = true
    safePrint("paused")
end
function UPF.Resilience.Resume()
    RES.paused = false
    safePrint("resumed")
end

-- Check "stuck"
local function checkStuck()
    if RES.paused then return end
    local char = LocalPlayer.Character
    if not char then
        lastPos = nil
        lastMoveTick = tick()
        return
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local pos = hrp.Position
    if lastPos then
        local dist = (pos - lastPos).Magnitude
        if dist > MIN_MOVE_DIST then
            lastMoveTick = tick()
            stuckDetectedAt = nil
        else
            if tick() - lastMoveTick >= STUCK_TIME then
                if not stuckDetectedAt then
                    stuckDetectedAt = tick()
                    safePrint("Player appears stuck - attempting recovery")
                    pcall(function() UPF.Resilience.AttemptRecovery() end)
                else
                    -- si persiste, intentar recovery de nuevo y resetear
                    if tick() - stuckDetectedAt > (STUCK_TIME * 1.5) then
                        safePrint("Stuck persists - re-attempting recovery (no reconnect will occur)")
                        pcall(function() UPF.Resilience.AttemptRecovery() end)
                        stuckDetectedAt = nil
                        lastMoveTick = tick()
                    end
                end
            end
        end
    else
        lastMoveTick = tick()
    end
    lastPos = pos
end

-- Heartbeat
if heartbeatConn then
    pcall(function() heartbeatConn:Disconnect() end)
    heartbeatConn = nil
end

heartbeatConn = RunService.Heartbeat:Connect(function()
    local ok, err = pcall(checkStuck)
    if not ok then
        warn("[resilience] checkStuck error:", err)
    end
end)

safePrint("✅ module_resilience (safe, no reconnect) loaded")