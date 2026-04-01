-- module_protection.lua (PRO + NOCLIP GLOBAL)

local UPF = _G.UPF
if not UPF then warn("UPF missing"); return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

UPF.Connections = UPF.Connections or {}
UPF.State = UPF.State or {}

UPF.State.Protection = UPF.State.Protection or {}
UPF.State.LastSafePosition = UPF.State.LastSafePosition or nil

local MAX_DISTANCE = 60
local MAX_VELOCITY = 120

local lastPosition = nil

-- =========================
-- 🔥 NOCLIP SOLO VS PLAYERS
-- =========================

local function ApplyPlayerNoclip()
    local myChar = LocalPlayer.Character
    if not myChar then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            for _, part in ipairs(plr.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end

-- =========================
-- 🧠 PROTECTION CORE
-- =========================

local function ProtectionLoop()
    if not UPF.State.ScriptRunning then return end
    if not UPF.State.ProtectionEnabled then return end

    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    if not hrp or not hum then return end

    -- aplicar noclip SIEMPRE
    pcall(ApplyPlayerNoclip)

    -- guardar posición segura
    local vel = hrp.AssemblyLinearVelocity.Magnitude
    if hum.FloorMaterial ~= Enum.Material.Air and vel < 10 then
        UPF.State.LastSafePosition = hrp.CFrame
    end

    -- inicializar
    if not lastPosition then
        lastPosition = hrp.Position
        return
    end

    local dist = (hrp.Position - lastPosition).Magnitude

    -- 🚨 TELEPORT / FLING DETECTADO
    if dist > MAX_DISTANCE or vel > MAX_VELOCITY then
        if UPF.State.LastSafePosition then
            hrp.CFrame = UPF.State.LastSafePosition
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
            warn("[UPF] Rollback + velocity reset")
        end
    end

    lastPosition = hrp.Position
end

-- =========================
-- 🔌 CONNECTION SEGURA
-- =========================

if UPF.Connections.Protection then
    pcall(function()
        UPF.Connections.Protection:Disconnect()
    end)
end

UPF.Connections.Protection = RunService.Heartbeat:Connect(function()
    pcall(ProtectionLoop)
end)

print("✅ Protection PRO + Noclip loaded")
