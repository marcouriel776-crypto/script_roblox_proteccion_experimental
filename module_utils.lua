local UPF = _G.UPF
local Utils = {}

function Utils.ClearForces(part)
    if not part then return end
    part.AssemblyLinearVelocity = Vector3.zero
    part.AssemblyAngularVelocity = Vector3.zero

    for _, v in ipairs(part:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("LinearVelocity") then
            v:Destroy()
        end
    end
end

UPF.Utils = Utils

print("✅ Utils loaded")
