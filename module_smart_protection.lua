-- module_smart_protection.lua
-- UPF Smart Protection
-- Detecta remotos sospechosos, anti-fling, rollback seguro, autocuración y métricas.
-- Expone API en _G.UPF.SmartProtection
-- Recomendado: cargarlo como parte de SYSTEMS (antes que UI)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
_G.UPF = _G.UPF or {}
local UPF = _G.UPF

-- module metadata (opcional, usado por loader_v4)
UPF_MODULE = UPF_MODULE or {}
UPF_MODULE.name = "smart_protection"
UPF_MODULE.requires = {"protection", "recovery"} -- sólo indicativo

-- Estado / configuración
UPF.State = UPF.State or {}
UPF.State.FlingEvents = UPF.State.FlingEvents or 0
UPF.State.BlockedEvents = UPF.State.BlockedEvents or 0
UPF.State.Smart = UPF.State.Smart or {
    mode = UPF.Settings and UPF.Settings.smart_mode or "SAFE",
    fling_threshold_safe = 80,
    fling_threshold_pvp  = 120,
    max_distance_per_frame = 35,
    max_linear_velocity = 120,
    player_velocity_threshold = 100,
    rollback_cooldown = 0.6
}

local State = UPF.State.Smart

-- internals
local DangerousPlayers = {}   -- [player] = timestamp last flagged
local SuspiciousRemotes = {}  -- name -> timestamp
local Whitelist = {}          -- allowed remote names or players
local Blacklist = {}          -- explicitly blocked remote names or players
local LastRollback = 0

-- Helpers
local function safe_pcall(fn, ...)
    local ok, res = pcall(fn, ...)
    if not ok then
        warn("[UPF.Smart] pcall failed:", res)
        return nil, res
    end
    return res
end

local function now() return tick() end

local function isPlayer(plr)
    return plr and plr:IsA and plr:IsA("Player")
end

local function inWhitelist(key) return Whitelist[key] ~= nil end
local function inBlacklist(key) return Blacklist[key] ~= nil end

-- expose simple management API
UPF.SmartProtection = UPF.SmartProtection or {}
local API = UPF.SmartProtection

function API.AddWhitelist(key) Whitelist[key] = now() end
function API.RemoveWhitelist(key) Whitelist[key] = nil end
function API.AddBlacklist(key) Blacklist[key] = now() end
function API.RemoveBlacklist(key) Blacklist[key] = nil end
function API.GetStats()
    return {
        flingEvents = UPF.State.FlingEvents,
        blockedEvents = UPF.State.BlockedEvents,
        suspiciousRemotes = SuspiciousRemotes,
        whitelist = Whitelist,
        blacklist = Blacklist
    }
end

-- Detectar remotos sospechosos por nombre (heurística)
local SUSPICIOUS_REMOTE_KEYWORDS = {
    "kick", "teleport", "tp", "ban", "shutdown", "destroy", "kill", "remove",
    "sethealth", "setmaxhealth", "giveitem", "exploit", "force", "velocity"
}

local function remoteLooksSuspicious(name)
    if not name or name == "" then return false end
    local lower = string.lower(name)
    if inWhitelist(name) or inWhitelist(lower) then return false end
    if inBlacklist(name) or inBlacklist(lower) then return true end
    for _,kw in ipairs(SUSPICIOUS_REMOTE_KEYWORDS) do
        if string.find(lower, kw, 1, true) then
            return true
        end
    end
    return false
end

-- Monitor objetos RemoteEvent / RemoteFunction añadidos a lugares comunes
local function monitorRemotes(root)
    if not root then return end
    -- scan existing
    for _,c in ipairs(root:GetDescendants()) do
        if c.ClassName == "RemoteEvent" or c.ClassName == "RemoteFunction" then
            local name = c.Name
            if remoteLooksSuspicious(name) then
                SuspiciousRemotes[name] = now()
                UPF.State.BlockedEvents = (UPF.State.BlockedEvents or 0)
                UPF.State.BlockedEvents = UPF.State.BlockedEvents + 1
                warn("[UPF.Smart] suspicious remote found:", name, "path:", pcall(function() return c:GetFullName() end) and c:GetFullName() or "n/a")
            end
        end
    end
    -- connect new ones
    root.DescendantAdded:Connect(function(obj)
        if obj.ClassName == "RemoteEvent" or obj.ClassName == "RemoteFunction" then
            local name = obj.Name
            if remoteLooksSuspicious(name) then
                SuspiciousRemotes[name] = now()
                UPF.State.BlockedEvents = (UPF.State.BlockedEvents or 0) + 1
                warn("[UPF.Smart] new suspicious remote added:", name)
            end
        end
    end)
end

-- Anti-fling: vigila velocidades de otros jugadores y marca/aisla
local function checkOtherPlayers()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local vel = 0
            pcall(function() vel = hrp.AssemblyLinearVelocity.Magnitude end)
            local threshold = (State.mode == "SAFE") and State.fling_threshold_safe or State.fling_threshold_pvp
            if vel > (State.player_velocity_threshold or threshold) then
                DangerousPlayers[plr] = now()
                UPF.State.FlingEvents = (UPF.State.FlingEvents or 0) + 1
                -- try to minimize impact: disable collisions for that player's character locally
                pcall(function()
                    for _,part in ipairs(plr.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end)
            end
            -- if player's HRP has attached BodyVelocity/LinearVelocity, also flag
            for _,v in ipairs(hrp:GetChildren()) do
                if v:IsA("BodyVelocity") or v:IsA("LinearVelocity") then
                    DangerousPlayers[plr] = now()
                    UPF.State.FlingEvents = (UPF.State.FlingEvents or 0) + 1
                    pcall(function() v:Destroy() end)
                end
            end
        end
    end
end

-- Clear forces applied to our character
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

-- Rollback seguro (teleportarnos al último safe point si existe)
local function SafeRollback(rootpart, targetCFrame)
    if not rootpart or not targetCFrame then return end
    if now() - LastRollback < State.rollback_cooldown then return end
    LastRollback = now()
    pcall(function() rootpart.CFrame = targetCFrame end)
    clearForcesOnCharacter(LocalPlayer.Character)
    UPF.State.BlockedEvents = (UPF.State.BlockedEvents or 0) + 1
end

-- Track safe points and movement
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

    -- record safe point when on ground & slow
    if hum.FloorMaterial ~= Enum.Material.Air and vel < 10 then
        SafeAutoPoint = hrp.CFrame
    end

    -- detect big teleport distance
    if LastPos then
        local dist = (hrp.Position - LastPos).Magnitude
        if dist > State.max_distance_per_frame then
            -- rollback to last safe
            if SafeAutoPoint then
                SafeRollback(hrp, SafeAutoPoint)
            else
                clearForcesOnCharacter(LocalPlayer.Character)
            end
        end
    end

    LastPos = hrp.Position
    if (hrp.Position - (LastPos or hrp.Position)).Magnitude > 0.2 then
        LastMoveTick = now()
    end
end

-- Self-heal: aplicaciones sobre humanoide local
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

-- Monitor suspicious remote fires (best-effort): hooks for RemoteEvent: to detect suspicious payload sizes/frequency
local RemoteActivity = {} -- remote -> {lastTick, count}
local function monitorRemoteActivity(remote)
    if not remote then return end
    if not remote:IsA("RemoteEvent") then return end
    local name = remote.Name
    -- attempt to connect OnClientEvent safely
    local ok, conn = pcall(function()
        return remote.OnClientEvent:Connect(function(...)
            -- light heuristics: very large payloads or many events in short time are suspicious
            local tcount = select("#", ...)
            local entry = RemoteActivity[remote] or {last = 0, count = 0}
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
            if tcount > 25 then
                SuspiciousRemotes[name] = now()
                UPF.State.BlockedEvents = (UPF.State.BlockedEvents or 0) + 1
                warn("[UPF.Smart] large remote payload:", name, "args:", tcount)
            end
        end)
    end)
    if ok and conn then
        -- store connection (weak table not needed here)
    end
end

-- scan and monitor common remote containers
local function scanAndAttachMonitors()
    for _,root in ipairs({Workspace, game:GetService("ReplicatedStorage"), game:GetService("StarterGui")}) do
        for _,obj in ipairs(root:GetDescendants()) do
            if obj.ClassName == "RemoteEvent" or obj.ClassName == "RemoteFunction" then
                monitorRemoteActivity(obj)
            end
        end
        -- watch for new remote objects
        root.DescendantAdded:Connect(function(obj)
            if obj.ClassName == "RemoteEvent" or obj.ClassName == "RemoteFunction" then
                monitorRemoteActivity(obj)
            end
        end)
    end
end

-- Heartbeat main loop
if UPF.Connections == nil then UPF.Connections = {} end
if UPF.Connections.SmartProtection then
    pcall(function() UPF.Connections.SmartProtection:Disconnect() end)
    UPF.Connections.SmartProtection = nil
end

UPF.Connections.SmartProtection = RunService.Heartbeat:Connect(function(dt)
    if not UPF.State then return end
    -- update mode from settings if present
    State.mode = UPF.State.SmartMode or State.mode

    -- checks
    pcall(checkOtherPlayers)
    pcall(trackMovement)
    pcall(maintainHealth)

    -- occasional remote scanning (low frequency)
    if math.random() < 0.025 then
        pcall(scanAndAttachMonitors)
    end
end)

-- Initialize monitors for remotes right away
pcall(function() monitorRemotes(Workspace) end)
pcall(function() monitorRemotes(game:GetService("ReplicatedStorage")) end)
pcall(function() scanAndAttachMonitors() end)

print("✅ Smart Protection loaded (client-side heuristics).")