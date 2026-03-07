-- module_utils.lua
local UPF = _G.UPF
if not UPF then warn("UPF missing"); return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Utils = {}

function Utils.WaitForCharacter(timeout)
    timeout = timeout or 10
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local ok1 = pcall(function() char:WaitForChild("Humanoid", timeout) end)
    local ok2 = pcall(function() char:WaitForChild("HumanoidRootPart", timeout) end)
    return char, (ok1 and ok2)
end

function Utils.ClearForces(part)
    if not part or not part:IsA("BasePart") then return end
    pcall(function()
        part.AssemblyLinearVelocity = Vector3.zero
        part.AssemblyAngularVelocity = Vector3.zero
    end)
    for _, v in ipairs(part:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("LinearVelocity") or v:IsA("BodyAngularVelocity") then
            pcall(function() v:Destroy() end)
        end
    end
end

function Utils.SafeRollback(rootPart, prevCFrame)
    if not rootPart or not prevCFrame then return end
    pcall(function() rootPart.CFrame = prevCFrame end)
    Utils.ClearForces(rootPart)
end

UPF.Utils = UPF.Utils or {}
for k,v in pairs(Utils) do UPF.Utils[k] = v end
print("✅ Utils registered")