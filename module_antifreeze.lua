-- module_resilience.lua (FIXED SAFE)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local UPF = getgenv().UPF
UPF.Resilience = UPF.Resilience or {}

local lastCheck = 0

local function safeRecover()
    local char = LocalPlayer.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- SOLO limpiar velocidad (NO teleport)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    print("[resilience] safe recovery")
end

RunService.Heartbeat:Connect(function()
    if tick() - lastCheck < 5 then return end
    lastCheck = tick()

    local char = LocalPlayer.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local vel = root.AssemblyLinearVelocity.Magnitude

    -- solo si está completamente roto
    if vel > 300 then
        safeRecover()
    end
end)

print("✅ Resilience SAFE loaded")
