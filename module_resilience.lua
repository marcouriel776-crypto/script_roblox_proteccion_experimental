-- module_resilience.lua
-- UPF Resilience (safe version)
-- Evita teleports automáticos salvo permiso explícito.
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
RES.allow_reconnect = (RES.allow_reconnect == nil) and false or RES.allow_reconnect
RES.auto_reconnect_enabled = (RES.auto_reconnect_enabled == nil) and false or RES.auto_reconnect_enabled
RES.reconnectAttempts = RES.reconnectAttempts or 0
RES.lastReconnect = RES.lastReconnect or 0

local MAX_RECONNECT_ATTEMPTS = 3
local RECONNECT_COOLDOWN = 6 -- segundos
local STUCK_TIME = 5 -- tiempo sin movimiento para considerar "stuck"
local STUCK_CHECK_INTERVAL = 1 -- frecuencia de chequeo

UPF.Resilience = UPF.Resilience or {}
local Res = UPF.Resilience

-- Estado interno
local lastMoveTick = tick()
local lastPos = nil
local stuckDetectedAt = nil
local heartbeatConn = nil

local function safePrint(...)
    local ok, _ = pcall(function() print(...) end)
    return ok
end

-- Función que intenta reconectar (solo si allow_reconnect = true)
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

    safePrint("[resilience] Attempting reconnect (attempt " .. tostring(UPF.State.Resilience.reconnectAttempts) .. ")")

    -- Intenta Teleport SOLO si el flag es true; envolvemos en pcall por seguridad.
    local ok, err = pcall(function()
        if not UPF.State.Resilience.allow_reconnect then
            error("not_allowed")
        end
        -- TeleportService puede haber sido parcheado por kill-switch; igualmente usamos pcall.
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
    safePrint("[resilience] AttemptRecovery: trying local recover functions")
    -- preferir la API existente (UPF:RecoverPlayer / UPF:ReturnToSafePoint) si existe
    if type(UPF.RecoverPlayer) == "function" then
        pcall(function() UPF:RecoverPlayer() end)
    end
    if type(UPF.ReturnToSafePoint) == "function" then
        pcall(function() UPF:ReturnToSafePoint() end)
    end
end

-- Detectar si el jugador está "stuck" por falta de movimiento
local function checkStuck()
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
            -- se movió
            lastMoveTick = tick()
            stuckDetectedAt = nil
        else
            -- no se movió
            if tick() - lastMoveTick >= STUCK_TIME then
                if not stuckDetectedAt then
                    stuckDetectedAt = tick()
                    warn("[resilience] Player appears stuck - attempting recovery")
                    -- primer intento: solo recovery local
                    pcall(UPF.Resilience.AttemptRecovery)
                else
                    -- si ya pasó un tiempo razonable, intentar reconnect si está permitido
                    if tick() - stuckDetectedAt > (STUCK_TIME * 1.5) then
                        warn("[resilience] Stuck persists - considering reconnect (respecting allow_reconnect flag)")
                        pcall(function()
                            -- Solo intentamos reconnect si la bandera lo permite; AttemptReconnect retornará false si no.
                            UPF.Resilience.AttemptReconnect()
                        end)
                        -- evitar reintentos constantes
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

-- Monitor principal con protección pcall (no provoca crash global)
local function startHeartbeat()
    if heartbeatConn then
        pcall(function() heartbeatConn:Disconnect() end)
        heartbeatConn = nil
    end
    heartbeatConn = RunService.Heartbeat:Connect(function(dt)
        local ok, err = pcall(checkStuck)
        if not ok then
            warn("[resilience] checkStuck error:", err)
        end
    end)
end

-- Inicializar
startHeartbeat()
safePrint("✅ module_resilience (safe) loaded - auto-reconnect disabled by default")
