-- module_smart_protection.lua (FINAL CLEAN)

UPF_MODULE = { name = "smart_protection", requires = { "protection", "recovery" } }

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
_G.UPF = _G.UPF or {}
local UPF = _G.UPF

-- =========================
-- STATE
-- =========================

UPF.State = UPF.State or {}
UPF.State.Smart = UPF.State.Smart or {}
local State = UPF.State.Smart

State.mode = State.mode or "SAFE"
State.max_distance_per_frame = 35
State.player_velocity_threshold = 140

-- =========================
-- INTERNALS
-- =========================

local Connections = {}
local RemoteActivity = {}
local SuspiciousRemotes = {}

local function safeConnect(signal, fn)
    local ok, conn = pcall(function()
        return signal:Connect(fn)
    end)
    if ok and conn then
        table.insert(Connections, conn)
    end
end

local function cleanup()
    for _, c in ipairs(Connections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(Connections)
end

-- limpiar conexiones anteriores si recarga
if UPF._SmartCleanup then
    UPF._SmartCleanup()
end
UPF._SmartCleanup = cleanup

-- =========================
-- REMOTE DETECTION (SAFE)
-- =========================

local function monitorRemote(remote)
    if not remote:IsA("RemoteEvent") then return end

    safeConnect(remote.OnClientEvent, function(...)
        local entry = RemoteActivity[remote] or {count = 0, last = 0}
        local now = tick()

        if now - entry.last < 1 then
            entry.count += 1
        else
            entry.count = 1
        end

        entry.last = now
        RemoteActivity[remote] = entry

        if entry.count > 15 then
            SuspiciousRemotes[remote.Name] = now
            warn("[UPF] High remote spam:", remote.Name)
        end
    end)
end

local function scanRemotesOnce()
    local roots = {Workspace, ReplicatedStorage}

    for _, root in ipairs(roots) do
        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                monitorRemote(obj)
            end
        end
    end
end

-- =========================
-- ANTI-FLING (SAFE)
-- =========================

local function checkPlayers()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel = hrp.AssemblyLinearVelocity.Magnitude

                if vel > State.player_velocity_threshold then
                    warn("[UPF] High velocity player:", plr.Name)
                    -- SOLO LOG (no modificar nada externo)
                end
            end
        end
    end
end

-- =========================
-- LOCAL RECOVERY
-- =========================

local LastPos = nil
local SafePoint = nil

local function trackMovement()
    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local vel = hrp.AssemblyLinearVelocity.Magnitude

    if hum.FloorMaterial ~= Enum.Material.Air and vel < 10 then
        SafePoint = hrp.CFrame
    end

    if LastPos then
        local dist = (hrp.Position - LastPos).Magnitude

        if dist > State.max_distance_per_frame then
            if SafePoint then
                hrp.CFrame = SafePoint
                warn("[UPF] Safe rollback")
            end
        end
    end

    LastPos = hrp.Position
end

-- =========================
-- HEARTBEAT
-- =========================

UPF.Connections = UPF.Connections or {}

if UPF.Connections.Smart then
    pcall(function() UPF.Connections.Smart:Disconnect() end)
end

UPF.Connections.Smart = RunService.Heartbeat:Connect(function()
    pcall(checkPlayers)
    pcall(trackMovement)
end)

-- =========================
-- INIT
-- =========================

scanRemotesOnce()

print("✅ Smart Protection CLEAN loaded")