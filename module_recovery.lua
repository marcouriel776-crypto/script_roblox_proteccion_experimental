-- module_recovery.lua (CLEAN STABLE)

local Players = game:GetService("Players")

local player = Players.LocalPlayer

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

UPF.State = UPF.State or {}
UPF.State.GodMode = UPF.State.GodMode or false

UPF.Recovery = UPF.Recovery or {}
local Recovery = UPF.Recovery

Recovery.Connections = {}

---------------------------------------------------
-- GOD MODE
---------------------------------------------------

local function protectHumanoid(humanoid)
    if not humanoid then return end

    if Recovery.Connections.Health then
        Recovery.Connections.Health:Disconnect()
    end

    Recovery.Connections.Health = humanoid.HealthChanged:Connect(function()
        if not UPF.State.GodMode then return end

        if humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
end

---------------------------------------------------
-- CHARACTER
---------------------------------------------------

local function monitorCharacter(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        protectHumanoid(humanoid)
    end
end

player.CharacterAdded:Connect(function(character)
    task.wait(1)
    monitorCharacter(character)
end)

if player.Character then
    monitorCharacter(player.Character)
end

---------------------------------------------------
-- API
---------------------------------------------------

function UPF:ToggleGodMode(on)
    UPF.State.GodMode = (on == nil) and not UPF.State.GodMode or on

    print("🛡 GodMode:", UPF.State.GodMode)

    if player.Character then
        monitorCharacter(player.Character)
    end

    if UPF.SaveSettings then
        UPF:SaveSettings()
    end
end

---------------------------------------------------
-- RECOVERY
---------------------------------------------------

function UPF:RecoverPlayer()
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Health = humanoid.MaxHealth
    end
end

function UPF:ReturnToSafePoint()
    local character = player.Character
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
    end
end

print("✅ Recovery CLEAN loaded")
