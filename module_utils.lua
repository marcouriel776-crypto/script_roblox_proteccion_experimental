-- module_utils.lua
-- Utilities: safe force-clean, safe rollback, character waiter
-- client-safe helpers used by protection/recovery modules

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Waits for LocalPlayer.Character with HRP & Humanoid
function WaitForCharacter(timeout)
    timeout = timeout or 10
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local ok1 = char:WaitForChild("Humanoid", timeout)
    local ok2 = char:WaitForChild("HumanoidRootPart", timeout)
    return char, ok1 and ok2
end

-- Clear forces safely on a single part
function ClearForces(part)
    if not part or not part:IsA("BasePart") then return end
    pcall(function()
        part.AssemblyLinearVelocity = Vector3.zero
        part.AssemblyAngularVelocity = Vector3.zero
    end)
    for _, v in ipairs(part:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("LinearVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyGyro") then
            pcall(function() v:Destroy() end)
        end
    end
end

-- Destroy force instances across workspace (local copy)
function DestroyLocalForces()
    for _, obj in ipairs(workspace:GetDescendants()) do
        local ok, t = pcall(function() return obj.ClassName end)
        if not ok then continue end
        if obj:IsA("BodyVelocity") or obj:IsA("LinearVelocity") or obj:IsA("BodyAngularVelocity") then
            pcall(function() obj:Destroy() end)
        end
    end
end

-- Safe rollback of a HumanoidRootPart to previous CFrame
function SafeRollback(rootPart, prevCFrame)
    if not rootPart or not prevCFrame then return end
    pcall(function() rootPart.CFrame = prevCFrame end)
    ClearForces(rootPart)
end

-- Expose safe APIs globally for easy use
_G.UPF_WaitForCharacter = WaitForCharacter
_G.UPF_ClearForces = ClearForces
_G.UPF_DestroyLocalForces = DestroyLocalForces
_G.UPF_SafeRollback = SafeRollback

print("✅ module_utils loaded")