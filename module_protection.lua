-- module_protection.lua (ANTI-TP PRO)

local UPF = _G.UPF
if not UPF then return end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local MAX_SPEED = 120
local MAX_DISTANCE = 50
local FORCE_THRESHOLD = 500

local lastPos = nil
local safeCFrame = nil
local lastCorrection = 0
local correctionCooldown = 0.8

local function isFlinging(root)
    local vel = root.AssemblyLinearVelocity.Magnitude
    return vel > FORCE_THRESHOLD
end

local function hasExternalForces(root)
    for _, v in ipairs(root:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("LinearVelocity") then
            return true
        end
    end
    return false
end

local function isSafeToSave(humanoid, velocity)
    return humanoid.FloorMaterial ~= Enum.Material.Air and velocity < 10
end

RunService.Heartbeat:Connect(function()
    if not UPF.State.ProtectionEnabled then return end

    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    local pos = root.Position
    local vel = root.AssemblyLinearVelocity.Magnitude

    -- guardar punto seguro REAL
    if isSafeToSave(hum, vel) then
        safeCFrame = root.CFrame
    end

    if not lastPos then
        lastPos = pos
        return
    end

    local dist = (pos - lastPos).Magnitude

    local teleportDetected = false

    -- DETECCIÓN MULTI
    if dist > MAX_DISTANCE then
        teleportDetected = true
    elseif vel > MAX_SPEED then
        teleportDetected = true
    elseif hasExternalForces(root) then
        teleportDetected = true
    elseif isFlinging(root) then
        teleportDetected = true
    end

    -- CORRECCIÓN INTELIGENTE
    if teleportDetected and safeCFrame then
        if tick() - lastCorrection > correctionCooldown then
            lastCorrection = tick()

            -- limpiar fuerzas primero
            for _, v in ipairs(root:GetChildren()) do
                if v:IsA("BodyVelocity") or v:IsA("LinearVelocity") then
                    v:Destroy()
                end
            end

            root.AssemblyLinearVelocity = Vector3.zero
            root.CFrame = safeCFrame

            warn("[UPF] Teleport blocked + corrected")
        end
    end

    lastPos = pos
end)

print("✅ AntiTeleport PRO loaded")
