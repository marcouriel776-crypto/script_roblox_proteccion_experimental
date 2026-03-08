-- module_smart_protection.lua
-- UPF Smart Protection (corregido, versión robusta)
-- Detecta remotos sospechosos, anti-fling, rollback seguro, autocuración y métricas.
-- Cargar en SYSTEMS (antes que UI).

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
_G.UPF = _G.UPF or {}
local UPF = _G.UPF

-- metadata opcional (para loader_v4)
UPF_MODULE = UPF_MODULE or {}
UPF_MODULE.name = "smart_protection"
UPF_MODULE.requires = { "protection", "recovery" }

-- Estado y configuración por defecto
UPF.State = UPF.State or {}
UPF.State.FlingEvents = UPF.State.FlingEvents or 0
UPF.State.BlockedEvents = UPF.State.BlockedEvents or 0
UPF.State.Smart = UPF.State.Smart or {}
local State = UPF.State.Smart

State.mode = State.mode or (UPF.Settings and UPF.Settings.smart_mode) or "SAFE"
State.fling_threshold_safe = State.fling_threshold_safe or 80
State.fling_threshold_pvp  = State.fling_threshold_pvp or 120
State.max_distance_per_frame = State.max_distance_per_frame or 35
State.max_linear_velocity = State.max_linear_velocity or 120
State.player_velocity_threshold = State.player_velocity_threshold or 100
State.rollback_cooldown = State.rollback_cooldown or 0.6

-- Internals
local DangerousPlayers = {}   -- [player] = timestamp
local SuspiciousRemotes = {}  -- name -> timestamp
local Whitelist = {}          -- keys allowed
local Blacklist = {}          -- keys blocked
local LastRollback = 0

local function now() return tick() end

local function inWhitelist(key) return key and (Whitelist[key] ~= nil) end
local function inBlacklist(key) return key and (Blacklist[key] ~= nil) end

-- API expuesta
UPF.SmartProtection = UPF.SmartProtection or {}
local API = UPF.SmartProtection
function API.AddWhitelist(key) if key then Whitelist[key] = now() end end
function API.RemoveWhitelist(key) if key then Whitelist[key] = nil end end
function API.AddBlacklist(key) if key then Blacklist[key] = now() end end
function API.RemoveBlacklist(key) if key then Blacklist[key] = nil end end
function API.GetStats()
    return {
        flingEvents = UPF.State.FlingEvents,
        blockedEvents = UPF.State.BlockedEvents,
        suspiciousRemotes = SuspiciousRemotes,
        whitelist = Whitelist,
        blacklist = Blacklist
    }
end

-- Heurística para nombres de remotos sospechosos
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

-- Monitor simple para remotes en un contenedor
local function monitorRemotes(root)
    if not root then return end
    for _, obj in ipairs(root:GetDescendants()) do
        local cls = tostring(obj.ClassName)
        if cls == "RemoteEvent" or cls == "RemoteFunction" then
            local name = obj.Name
            if remoteLooksSuspicious(name) then
                SuspiciousRemotes[name] = now()
                UPF.State.BlockedEvents = (UPF.State.BlockedEvents or 0) + 1
                warn("[UPF.Smart] suspicious remote found:", name, pcall(function() return obj:GetFullName() end) and obj:GetFullName() or "n/a")
            end
        end
    end
    -- nuevas desc
    pcall(function()
        root.DescendantAdded:Connect(function(obj)
            local cls = tostring(obj.ClassName)
            if cls == "RemoteEvent" or cls == "RemoteFunction" then
                local name = obj.Name
                if remoteLooksSuspicious(name) then
                    SuspiciousRemotes[name] = now()
                    UPF.State.BlockedEvents = (UPF.State.BlockedEvents or 0) + 1
                    warn("[UPF.Smart] new suspicious remote added:", name)
                end
            end
        end)
    end)
end

-- Anti-fling básico: detectar velocidades altas en otros jugadores
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
                    -- minimizar impacto: desactivar colisiones localmente
                    pcall(function()
                        if plr.Character then
                            for _, part in ipairs(plr.Character:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end)
                end
                -- detectar BodyVelocity/LinearVelocity en hrp
                for _, v in ipairs(hrp:GetChildren()) do
                    if v:IsA("BodyVelocity") or v:IsA("LinearVelocity") then
                        DangerousPlayers[plr] = now()
                        UPF.State.FlingEvents = (UPF.State.FlingEvents or 0) + 1
                        pcall(function() v:Destroy() end)
                    end
                end
            end
        end
    end
end

-- Limpiar fuerzas sobre nuestro personaje
local function clearForcesOnCharacter(char)
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
    for _, v in ipairs(hrp:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("LinearVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyGyro") then
            pcall(function() v:Destroy() end)
        end
    end
end

-- Rollback seguro
local function SafeRollback(rootpart, targetCFrame)
    if not rootpart or not targetCFrame then return end
    if now() - LastRollback < (State.rollback_cooldown or 0.6) then return end
    LastRollback = now()
    pcall(function() rootpart.CFrame = targetCFrame end)
    clearForcesOnCharacter(LocalPlayer.Character)
    UPF.State.BlockedEvents = (UPF.State.BlockedEvents or 0) + 1
end

-- Track safe points y movimiento
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
                SafeRollback(hrp, SafeAutoPoint)
            else
                clearForcesOnCharacter(LocalPlayer.Character)
            end
        end
    end

    -- update movement tick
    if LastPos and (hrp.Position - LastPos).Magnitude > 0.2 or vel > 1 then
        LastMoveTick = now()
    end
    LastPos = hrp.Position
end

-- Self-heal
local function maintainHealth()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    pcall(function()
        if hum.MaxHealth < 100 then hum.MaxHealth = 100 end
        if UPF.State.GodMode then
            if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
        end
    end)
end

-- Monitor actividad remota ligera (payloads y frecuencia)
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
                warn("[UPF.Smart] high remote activity:", name, "count:", entry.count)
            end
            if select("#", ...) > 25 then
                SuspiciousRemotes[name] = now()
                UPF.State.BlockedEvents = (UPF.State.BlockedEvents or 0) + 1
                warn("[UPF.Smart] large remote payload:", name, "args:", select("#", ...))
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

-- Loop principal
UPF.Connections = UPF.Connections or {}
if UPF.Connections.SmartProtection then
    pcall(function() UPF.Connections.SmartProtection:Disconnect() end)
    UPF.Connections.SmartProtection = nil
end

UPF.Connections.SmartProtection = RunService.Heartbeat:Connect(function(dt)
    if not UPF.State then return end
    -- actualizar modo si cambió externamente
    State.mode = UPF.State.SmartMode or State.mode

    pcall(checkOtherPlayers)
    pcall(trackMovement)
    pcall(maintainHealth)

    -- escaneo ligero de remotes ocasional
    if math.random() < 0.03 then
        pcall(scanAndAttachMonitors)
    end
end)

-- inicializar
pcall(function() monitorRemotes(Workspace) end)
pcall(function() monitorRemotes(game:GetService("ReplicatedStorage")) end)
pcall(function() scanAndAttachMonitors() end)

print("✅ Smart Protection loaded (client-side heuristics).")