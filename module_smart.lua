-- module_smart.lua (ULTRA CLEAN + REAL USEFUL)

local UPF = _G.UPF
if not UPF then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

UPF.Connections = UPF.Connections or {}

UPF.State.SmartMode = UPF.State.SmartMode or "SAFE"
UPF.State.DangerousPlayers = UPF.State.DangerousPlayers or {}
UPF.State.FlingEvents = UPF.State.FlingEvents or 0

local LocalPlayer = Players.LocalPlayer

local SAFE_THRESHOLD = 80
local AGGRESSIVE_THRESHOLD = 120
local DANGER_DURATION = 3
local MAX_DISTANCE = 50 -- 🔥 NUEVO (solo cercanos)

-- =========================

local function MarkDanger(plr)
    UPF.State.DangerousPlayers[plr] = tick()
    UPF.State.FlingEvents += 1
end

local function CleanupDanger()
    for plr, t in pairs(UPF.State.DangerousPlayers) do
        if tick() - t > DANGER_DURATION then
            UPF.State.DangerousPlayers[plr] = nil
        end
    end
end

local function IsNear(localRoot, otherRoot)
    return (localRoot.Position - otherRoot.Position).Magnitude <= MAX_DISTANCE
end

local function CheckPlayers()

    local localChar = LocalPlayer.Character
    if not localChar then return end

    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp and IsNear(localRoot, hrp) then -- 🔥 FILTRO CLAVE

                    local vel = hrp.AssemblyLinearVelocity.Magnitude

                    local threshold = (UPF.State.SmartMode == "SAFE")
                        and SAFE_THRESHOLD
                        or AGGRESSIVE_THRESHOLD

                    if vel > threshold then
                        MarkDanger(plr)
                    end

                    -- 🔥 SOLO BodyVelocity (igual que protection)
                    for _, obj in ipairs(hrp:GetChildren()) do
                        if obj:IsA("BodyVelocity") then
                            MarkDanger(plr)
                        end
                    end
                end
            end
        end
    end
end

-- =========================

if UPF.Connections.SmartHeartbeat then
    pcall(function()
        UPF.Connections.SmartHeartbeat:Disconnect()
    end)
end

UPF.Connections.SmartHeartbeat = RunService.Heartbeat:Connect(function()
    if not UPF.State.ScriptRunning then return end
    if not UPF.State.ProtectionEnabled then return end
    if not UPF.State.CharacterReady then return end

    pcall(CleanupDanger)
    pcall(CheckPlayers)
end)

print("✅ Smart ULTRA CLEAN loaded")
