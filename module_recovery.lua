local Players = game:GetService("Players")
local player = Players.LocalPlayer

local UPF = _G.UPF
UPF.State.GodMode = UPF.State.GodMode or false

function UPF:ToggleGodMode(state)
    UPF.State.GodMode = state

    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Health = hum.MaxHealth
    end
end

function UPF:RecoverPlayer()
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Health = hum.MaxHealth
    end
end

function UPF:ReturnToSafePoint()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
    end
end

print("✅ Recovery CLEAN loaded")
