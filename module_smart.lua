-- module_smart.lua
local UPF = _G.UPF
if not UPF then warn("UPF missing"); return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- 🔥 FIX CLAVE
UPF.Connections = UPF.Connections or {}

-- =========================
-- STATE
-- =========================

UPF.State.SmartMode = UPF.State.SmartMode or "SAFE"
UPF.State.DangerousPlayers = UPF.State.DangerousPlayers or {}
UPF.State.FlingEvents = UPF.State.FlingEvents or 0

local LocalPlayer = Players.LocalPlayer

-- =========================
-- CONFIG
-- =========================

local SAFE_THRESHOLD = 80
local AGGRESSIVE_THRESHOLD = 120
local DANGER_DURATION = 3

-- =========================
-- FUNCIONES
-- =========================

local function MarkDanger(plr)
    UPF.State.DangerousPlayers[plr] = tick()
    UPF.State.FlingEvents = (UPF.State.FlingEvents or 0) + 1

    warn("[UPF] Dangerous player detected:", plr.Name)
end

local function CleanupDanger()
    for plr, t in pairs(UPF.State.DangerousPlayers) do
        if tick() - t > DANGER_DURATION then
            UPF.State.DangerousPlayers[plr] = nil
        end
    end
end

local function CheckPlayers()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local ok, vel = pcall(function()
                        return hrp.AssemblyLinearVelocity.Magnitude
                    end)

                    if ok and vel then
                        local threshold = (UPF.State.SmartMode == "SAFE")
                            and SAFE_THRESHOLD
                            or AGGRESSIVE_THRESHOLD

                        if vel > threshold then
                            MarkDanger(plr)
                        end
                    end

                    -- detectar fuerzas tipo fling
                    for _, obj in ipairs(hrp:GetChildren()) do
                        if obj:IsA("BodyVelocity") or obj:IsA("LinearVelocity") then
                            MarkDanger(plr)
                        end
                    end
                end
            end
        end
    end
end

-- =========================
-- CONNECTION SEGURA
-- =========================

-- 🔥 evitar duplicación de conexiones
if UPF.Connections.SmartHeartbeat then
    pcall(function()
        UPF.Connections.SmartHeartbeat:Disconnect()
    end)
end

UPF.Connections.SmartHeartbeat = RunService.Heartbeat:Connect(function()
    if not UPF.State.ScriptRunning then return end
    if not UPF.State.ProtectionEnabled then return end

    pcall(CleanupDanger)
    pcall(CheckPlayers)
end)

-- =========================
-- DEBUG / INFO
-- =========================

print("✅ Smart module PRO loaded")
print("   Mode:", UPF.State.SmartMode)
