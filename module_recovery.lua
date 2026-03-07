-- module_recovery.lua
local UPF = _G.UPF
if not UPF then warn("UPF missing"); return end

local RunService = game:GetService("RunService")
UPF.State.GodMode = UPF.State.GodMode or UPF.State.GodModeEnabled or false
UPF.State.SafePoint = UPF.State.SafePoint or nil
UPF.State.LastAutoReturn = UPF.State.LastAutoReturn or 0

-- God mode heartbeat
UPF.Connections.GodHeartbeat = RunService.Heartbeat:Connect(function()
    if not UPF.State.ScriptRunning or not UPF.State.GodMode then return end
    if not UPF.Humanoid then return end
    pcall(function()
        if UPF.Humanoid.MaxHealth < 100 then UPF.Humanoid.MaxHealth = 100 end
        if UPF.Humanoid.Health < UPF.Humanoid.MaxHealth then UPF.Humanoid.Health = UPF.Humanoid.MaxHealth end
    end)
end)

-- Safe point tracker
UPF.Connections.SafePointTracker = RunService.Heartbeat:Connect(function()
    if not UPF.RootPart or not UPF.Humanoid then return end
    local vel = 0
    pcall(function() vel = UPF.RootPart.AssemblyLinearVelocity.Magnitude end)
    if UPF.Humanoid.FloorMaterial ~= Enum.Material.Air and vel < 10 then
        UPF.State.SafePoint = UPF.RootPart.CFrame
    end

    -- Auto return if out of bounds
    if UPF.State.AutoReturnEnabled and UPF.State.SafePoint then
        local ok, y = pcall(function() return UPF.RootPart.Position.Y end)
        if ok and (y > 2000 or y < -500) and (tick() - UPF.State.LastAutoReturn > UPF.State.ReturnCooldown) then
            UPF.State.LastAutoReturn = tick()
            pcall(function() UPF.RootPart.CFrame = UPF.State.SafePoint end)
        end
    end
end)

function UPF:ReturnToSafePoint()
    if UPF.State.SafePoint and UPF.RootPart then
        pcall(function() UPF.RootPart.CFrame = UPF.State.SafePoint end)
    end
end

function UPF:ToggleGodMode(on)
    if on == nil then UPF.State.GodMode = not UPF.State.GodMode else UPF.State.GodMode = on end
    if UPF.SaveSettings then UPF:SaveSettings() end
end

-- Unfreeze helper
function UPF:RecoverPlayer()
    if not UPF.RootPart or not UPF.Humanoid then return end
    pcall(function()
        UPF.RootPart.AssemblyLinearVelocity = Vector3.zero
        UPF.RootPart.AssemblyAngularVelocity = Vector3.zero
        for _, v in ipairs(UPF.RootPart:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("LinearVelocity") or v:IsA("BodyAngularVelocity") then
                v:Destroy()
            end
        end
        UPF.RootPart.Anchored = true
        task.wait(0.15)
        UPF.RootPart.Anchored = false
    end)
end

print("✅ Recovery module v2 loaded")