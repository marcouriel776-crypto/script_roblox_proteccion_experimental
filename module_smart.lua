local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local UPF = _G.UPF
UPF.State.DangerousPlayers = {}

UPF.Scheduler:AddTask("Smart", 0.3, function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp and hrp.AssemblyLinearVelocity.Magnitude > 100 then
                UPF.State.DangerousPlayers[plr] = true
            end
        end
    end
end)

print("✅ Smart Loader")
