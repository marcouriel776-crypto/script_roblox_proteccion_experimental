-- module_utils.lua (FIXED STABLE)

local UPF = _G.UPF
if not UPF then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Utils = {}

-- =========================
-- CHARACTER
-- =========================

function Utils.WaitForCharacter(timeout)
    timeout = timeout or 10

    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    local hum = char:WaitForChild("Humanoid", timeout)
    local hrp = char:WaitForChild("HumanoidRootPart", timeout)

    if hum and hrp then
        return char, true
    end

    return char, false
end

-- =========================
-- FORCE CLEAN
-- =========================

function Utils.ClearForces(part)
    if not part or not part:IsA("BasePart") then return end

    -- reset velocidades primero
    pcall(function()
        part.AssemblyLinearVelocity = Vector3.zero
        part.AssemblyAngularVelocity = Vector3.zero
    end)

    -- 🔥 SOLO destruir fuerzas peligrosas
    for _, v in ipairs(part:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") then
            pcall(function() v:Destroy() end)
        end
    end
end

-- =========================
-- SAFE ROLLBACK
-- =========================

function Utils.SafeRollback(rootPart, prevCFrame)
    if not rootPart or not prevCFrame then return end

    -- 🔥 limpiar antes (más estable)
    Utils.ClearForces(rootPart)

    pcall(function()
        rootPart.CFrame = prevCFrame
    end)
end

-- =========================
-- REGISTER
-- =========================

UPF.Utils = UPF.Utils or {}
for k,v in pairs(Utils) do
    UPF.Utils[k] = v
end

print("✅ Utils FIXED loaded")
