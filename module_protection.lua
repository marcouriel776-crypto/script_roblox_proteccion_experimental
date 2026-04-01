local UPF = _G.UPF
if not UPF then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

UPF.Connections = UPF.Connections or {}
UPF.State = UPF.State or {}

UPF.State.LastSafePosition = UPF.State.LastSafePosition or nil

local lastPosition = nil
local lastRollback = 0
local rollbackCooldown = 1.5 -- 🔥 evita spam

-- =========================
-- NOCLIP (OPTIMIZADO)
-- =========================

local function ApplyNoclip()
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
-- LOOP PRINCIPAL
-- =========================

local function Loop()
    if not UPF.State.ProtectionEnabled then return end

    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    -- noclip seguro
    pcall(ApplyNoclip)

    local vel = hrp.AssemblyLinearVelocity.Magnitude

    -- guardar punto seguro
    if hum.FloorMaterial ~= Enum.Material.Air and vel < 10 then
        UPF.State.LastSafePosition = hrp.CFrame
    end

    if not lastPosition then
        lastPosition = hrp.Position
        return
    end

    local dist = (hrp.Position - lastPosition).Magnitude

    -- 🚨 DETECCIÓN
    if dist > 80 or vel > 140 then

        -- 🔥 CONTROL DE COOLDOWN (CLAVE)
        if tick() - lastRollback > rollbackCooldown then
            lastRollback = tick()

            if UPF.State.LastSafePosition then
                hrp.CFrame = UPF.State.LastSafePosition
                hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                warn("[UPF] Safe rollback")
            end
        end
    end

    lastPosition = hrp.Position
end

-- =========================
-- CONNECTION
-- =========================

if UPF.Connections.Protection then
    pcall(function()
        UPF.Connections.Protection:Disconnect()
    end)
end

UPF.Connections.Protection = RunService.Heartbeat:Connect(function()
    pcall(Loop) -- 🔥 PROTECCIÓN GLOBAL
end)

print("✅ Protection FIX loaded")
