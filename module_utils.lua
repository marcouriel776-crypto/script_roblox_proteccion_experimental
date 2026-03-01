-- module_utils.lua
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function WaitForCharacter(timeout)
    timeout = timeout or 10
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local ok1 = char:WaitForChild("Humanoid", timeout)
    local ok2 = char:WaitForChild("HumanoidRootPart", timeout)
    return char, ok1 and ok2
end

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

function DestroyLocalForces()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BodyVelocity") or obj:IsA("LinearVelocity") or obj:IsA("BodyAngularVelocity") then
            pcall(function() obj:Destroy() end)
        end
    end
end

function SafeRollback(rootPart, prevCFrame)
    if not rootPart or not prevCFrame then return end
    pcall(function() rootPart.CFrame = prevCFrame end)
    ClearForces(rootPart)
end

_G.UPF_WaitForCharacter = WaitForCharacter
_G.UPF_ClearForces = ClearForces
_G.UPF_DestroyLocalForces = DestroyLocalForces
_G.UPF_SafeRollback = SafeRollback

print("✅ module_utils loaded")