-- module_smart_protection.lua
-- UPF Smart Protection (corregido)
-- Detecta remotes sospechosos, anti-fling, rollback local y métricas.
-- No realiza teleports ni reconnects.
-- Metadata opcional para loader_v4:
UPF_MODULE = { name = "smart_protection", requires = { "protection", "recovery" } }

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
_G.UPF = _G.UPF or {}
local UPF = _G.UPF

-- Estado y configuración
UPF.State = UPF.State or {}
UPF.State.Smart = UPF.State.Smart or {}
local State = UPF.State.Smart

State.mode = State.mode or (UPF.Settings and UPF.Settings.smart_mode) or "SAFE"
State.fling_threshold_safe = State.fling_threshold_safe or 80
State.fling_threshold_pvp  = State.fling_threshold_pvp or 120
State.max_distance_per_frame = State.max_distance_per_frame or 35
State.max_linear_velocity = State.max_linear_velocity or 120
State.player_velocity_threshold = State.player_velocity_threshold or 140 -- aumentado para menos falsos positivos
State.rollback_cooldown = State.rollback_cooldown or 0.6

-- Internals
local DangerousPlayers = {}   -- [player] = timestamp
local SuspiciousRemotes = {}  -- name -> timestamp
local Whitelist = {}
local Blacklist = {}
local LastRollback = 0

-- minimal logging rate-limit per name
local _SMART_LOG_LAST = {} -- name -> lastLogTime
local SMART_LOG_MIN_INTERVAL = 1 -- segundos (1 advertencia por remote por segundo)

local function smart_log(key, msg)
    local nowt = tick()
    local last = _SMART_LOG_LAST[key] or 0
    if nowt - last >= SMART_LOG_MIN_INTERVAL then
        _SMART_LOG_LAST[key] = nowt
        warn("[UPF.Smart] "..tostring(msg)..": "..tostring(key))
    end
end

local function now() return tick() end
local function inWhitelist(k) return k and (Whitelist[k] ~= nil) end
local function inBlacklist(k) return k and (Blacklist[k] ~= nil) end

-- API
UPF.SmartProtection = UPF.SmartProtection or {}
local API = UPF.SmartProtection
function API.AddWhitelist(key) if key then Whitelist[key] = now() end end
function API.RemoveWhitelist(key) if key then Whitelist[key] = nil end end
function API.AddBlacklist(key) if key then Blacklist[key] = now() end end
function API.RemoveBlacklist(key) if key then Blacklist[key] = nil end end
function API.GetStats()
    return {
        flingEvents = UPF.State.FlingEvents or 0,
        blockedEvents = UPF.State.BlockedEvents or 0,
        suspiciousRemotes = SuspiciousRemotes,
        whitelist = Whitelist,
        blacklist = Blacklist
    }
end

-- Heurística keywords
local SUSPICIOUS_REMOTE_KEYWORDS = {
    "kick","teleport","tp","ban","shutdown","destroy","kill","remove",
    "sethealth","setmaxhealth","giveitem","exploit","force","velocity"
}
local function remoteLooksSuspicious(name)
    if not name or name == "" then return false end
    local lower = string.lower(name)
    if inWhitelist(name) or inWhitelist(lower) then return false end
    if inBlacklist(name) or inBlacklist(lower) then return true end
    for _, kw in ipairs(SUSPICIOUS_REMOTE_KEYWORDS) do
        if string.find(lower, kw, 1, true) then
            return true
        end
    end
    return false
end

-- Monitor remotes en root (best-effort)
local function monitorRemotes(root)
    if not root then return end
    pcall(function()
        for _, obj in ipairs(root:GetDescendants()) do
            local cls = tostring(obj.ClassName)
            if cls == "RemoteEvent" or cls == "RemoteFunction" then
                local name = obj.Name
                if remoteLooksSuspicious(name) then
                    SuspiciousRemotes[name] = now()
                    UPF.State.BlockedEvents = (UPF.State.BlockedEvents or 0) + 1
                    smart_log(name, "suspicious remote found")
                end
            end
        end
        root.DescendantAdded:Connect(function(obj)
            local cls = tostring(obj.ClassName)
            if cls == "RemoteEvent" or cls == "RemoteFunction" then
                local name = obj.Name
                if remoteLooksSuspicious(name) then
                    SuspiciousRemotes[name] = now()
                    UPF.State.BlockedEvents = (UPF.State.BlockedEvents or 0) + 1
                    smart_log(name, "new suspicious remote added")
                end
            end
        end)
    end)
end

-- Anti-fling: detecta jugadores con velocidades extremas
local function checkOtherPlayers()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel = 0
                pcall(function() vel = hrp.AssemblyLinearVelocity.Magnitude end)
                local threshold = (State.mode == "SAFE") and State.fling_threshold_safe or State.fling_threshold_pvp
                if vel > (State.player_velocity_threshold or threshold) then
                    DangerousPlayers[plr] = now()
                    UPF.State.FlingEvents = (UPF.State.FlingEvents or 0) + 1
                    -- minimizar impacto: desactivar colisiones localmente (mejor intento)
                    pcall(function()
                        for _,part in ipairs(plr.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end)
                    smart_log(plr.Name, "player high velocity flagged")
                end
                -- detectar BodyVelocity/LinearVelocity en HRP
                for _, v in ipairs(hrp:GetChildren()) do
                    if v:IsA("BodyVelocity") or v:IsA("LinearVelocity") then
                        DangerousPlayers[plr] = now()
                        UPF.State.FlingEvents = (UPF.State.FlingEvents or 0) + 1
                        pcall(function() v:Destroy() end)
                        smart_log(plr.Name, "force object removed")
                    end
                end
            end
        end
    end
end

-- Limpia fuerzas en nuestro personaje
local function clearForcesOnCharacter(char)
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
    for _,v in ipairs(hrp:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("LinearVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyGyro") then
            pcall(function() v:Destroy() end)
        end
    end
end

-- Rollback local (teleport NO, solo mover localmente si es necesario)
local SafeAutoPoint = nil
local LastPos = nil
local LastMoveTick = now()
local function trackMovement()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local vel = 0
    pcall(function() vel = hrp.AssemblyLinearVelocity.Magnitude end)

    if hum.FloorMaterial ~= Enum.Material.Air and vel < 10 then
        SafeAutoPoint = hrp.CFrame
    end

    if LastPos then
        local dist = (hrp.Position - LastPos).Magnitude
        if dist > (State.max_distance_per_frame or 35) then
            if SafeAutoPoint then
                pcall(function() hrp.CFrame = SafeAutoPoint end)
                clearForcesOnCharacter(LocalPlayer.Character)
                UPF.State.BlockedEvents = (UPF.State.BlockedEvents or 0) + 1
                smart_log("rollback", "safe rollback performed")
            else
                clearForcesOnCharacter(LocalPlayer.Character)
            end
        end
    end

    LastPos = hrp.Position
end

-- Remote activity monitor (light heuristics)
local RemoteActivity = {} -- remote -> {last, count}
local function monitorRemoteActivity(remote)
    if not remote or not remote:IsA("RemoteEvent") then return end
    local name = remote.Name
    pcall(function()
        remote.OnClientEvent:Connect(function(...)
            local entry = RemoteActivity[remote] or { last = 0, count = 0 }
            local nowt = now()
            if nowt - entry.last < 1 then
                entry.count = entry.count + 1
            else
                entry.count = 1
            end
            entry.last = nowt
            RemoteActivity[remote] = entry
            if entry.count > 10 then
                SuspiciousRemotes[name] = now()
                UPF.State.BlockedEvents = (UPF.State.BlockedEvents or 0) + 1
                smart_log(name, "high remote activity (round count "..tostring(entry.count)..")")
            end
            if select("#", ...) > 25 then
                SuspiciousRemotes[name] = now()
                UPF.State.BlockedEvents = (UPF.State.BlockedEvents or 0) + 1
                smart_log(name, "large remote payload")
            end
        end)
    end)
end

local function scanAndAttachMonitors()
    local roots = { Workspace, game:GetService("ReplicatedStorage"), game:GetService("StarterGui") }
    for _, root in ipairs(roots) do
        pcall(function()
            for _, obj in ipairs(root:GetDescendants()) do
                if obj.ClassName == "RemoteEvent" or obj.ClassName == "RemoteFunction" then
                    monitorRemoteActivity(obj)
                end
            end
            root.DescendantAdded:Connect(function(obj)
                if obj.ClassName == "RemoteEvent" or obj.ClassName == "RemoteFunction" then
                    monitorRemoteActivity(obj)
                end
            end)
        end)
    end
end

-- Heartbeat loop (safe)
UPF.Connections = UPF.Connections or {}
if UPF.Connections.SmartProtection then
    pcall(function() UPF.Connections.SmartProtection:Disconnect() end)
    UPF.Connections.SmartProtection = nil
end

UPF.Connections.SmartProtection = RunService.Heartbeat:Connect(function(dt)
    if not UPF.State then return end
    State.mode = UPF.State.SmartMode or State.mode
    pcall(checkOtherPlayers)
    pcall(trackMovement)
    -- ocasional escaneo (baja probabilidad para reducir carga)
    if math.random() < 0.01 then
        pcall(scanAndAttachMonitors)
    end
end)

-- initialize monitors
pcall(function() monitorRemotes(Workspace) end)
pcall(function() monitorRemotes(game:GetService("ReplicatedStorage")) end)
pcall(function() scanAndAttachMonitors() end)

print("✅ Smart Protection loaded (client-side heuristics).")