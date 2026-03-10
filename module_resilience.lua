-- module_resilience.lua (safe, no varargs)
-- UPF Resilience - versión sin varargs para evitar errores de compilación.
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

-- Asegurar API global
_G.UPF = _G.UPF or {}
local UPF = _G.UPF

UPF.State = UPF.State or {}
UPF.State.Resilience = UPF.State.Resilience or {}

-- Config por defecto (segura)
local RES = UPF.State.Resilience
if RES.allow_reconnect == nil then RES.allow_reconnect = false end
if RES.auto_reconnect_enabled == nil then RES.auto_reconnect_enabled = false end
RES.reconnectAttempts = RES.reconnectAttempts or 0
RES.lastReconnect = RES.lastReconnect or 0

local MAX_RECONNECT_ATTEMPTS = 3
local RECONNECT_COOLDOWN = 6 -- segundos
local STUCK_TIME = 5 -- tiempo sin movimiento para considerar "stuck"

UPF.Resilience = UPF.Resilience or {}
local Res = UPF.Resilience

-- Estado interno
local lastMoveTick = tick()
local lastPos = nil
local stuckDetectedAt = nil
local heartbeatConn = nil

local function safePrintSingle(msg)
    -- imprime de forma segura un solo string (evita varargs)
    local ok, _ = pcall(function()
        if msg == nil then
            print("[UPF] (nil)")
        else
            print(tostring(msg))
        end
    end)
    return ok
end

-- Intentar reconectar (solo si allow_reconnect = true)
function UPF.Resilience.AttemptReconnect()
    UPF.State.Resilience = UPF.State.Resilience or {}
    local allow = UPF.State.Resilience.allow_reconnect or UPF.State.Resilience.auto_reconnect_enabled
    if not allow then
        warn("[resilience] AttemptReconnect blocked (allow_reconnect=false).")
        return false, "blocked_by_flag"
    end

    if tick() - (UPF.State.Resilience.lastReconnect or 0) < RECONNECT_COOLDOWN then
        return false, "cooldown"
    end
    if (UPF.State.Resilience.reconnectAttempts or 0) >= MAX_RECONNECT_ATTEMPTS then
        return false, "max_attempts"
    end

    UPF.State.Resilience.reconnectAttempts = (UPF.State.Resilience.reconnectAttempts or 0) + 1
    UPF.State.Resilience.lastReconnect = tick()

    safePrintSingle("[resilience] Attempting reconnect (attempt " .. tostring(UPF.State.Resilience.reconnectAttempts) .. ")")

    -- Teleport SOLO si la bandera lo permite
    local ok, err = pcall(function()
        if not UPF.State.Resilience.allow_reconnect then
            error("not_allowed")
        end
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)

    if not ok then
        warn("[resilience] Reconnect failed:", err)
        return false, err
    end
    return true
end

-- Intentar recuperar al jugador (no hace teleport)
function UPF.Resilience.AttemptRecovery()
    safePrintSingle("[resilience] AttemptRecovery: trying local recover functions")
    if type(UPF.RecoverPlayer) == "function" then
        pcall(function() UPF:RecoverPlayer() end)
    end
    if type(UPF.ReturnToSafePoint) == "function" then
        pcall(function() UPF:ReturnToSafePoint() end)
    end
end

-- Chequeo de "stuck" (sin varargs)
local function checkStuckSingle()
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
        if dist > 0.5 then
            lastMoveTick = tick()
            stuckDetectedAt = nil
        else
            if tick() - lastMoveTick >= STUCK_TIME then
                if not stuckDetectedAt then
                    stuckDetectedAt = tick()
                    warn("[resilience] Player appears stuck - attempting recovery")
                    pcall(function() UPF.Resilience.AttemptRecovery() end)
                else
                    if tick() - stuckDetectedAt > (STUCK_TIME * 1.5) then
                        warn("[resilience] Stuck persists - considering reconnect (respecting allow_reconnect flag)")
                        pcall(function()
                            UPF.Resilience.AttemptReconnect()
                        end)
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

local function startHeartbeat()
    if heartbeatConn then
        pcall(function() heartbeatConn:Disconnect() end)
        heartbeatConn = nil
    end
    heartbeatConn = RunService.Heartbeat:Connect(function()
        local ok, err = pcall(checkStuckSingle)
        if not ok then
            warn("[resilience] checkStuck error:", err)
        end
    end)
end

-- Inicializar
startHeartbeat()
safePrintSingle("✅ module_resilience (safe) loaded - auto-reconnect disabled by default")
