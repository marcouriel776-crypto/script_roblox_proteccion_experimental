-- module_recovery.lua
-- UPF Recovery System + God Mode

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

UPF.State = UPF.State or {}
UPF.State.GodMode = UPF.State.GodMode or false

UPF.Recovery = UPF.Recovery or {}
local Recovery = UPF.Recovery

Recovery.Connections = {}

---------------------------------------------------
-- GOD MODE CORE
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
-- CHARACTER MONITOR
---------------------------------------------------

local function monitorCharacter(character)

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        protectHumanoid(humanoid)
    end

end

---------------------------------------------------
-- RESPAWN SUPPORT
---------------------------------------------------

player.CharacterAdded:Connect(function(character)

    task.wait(1)

    monitorCharacter(character)

end)

if player.Character then
    monitorCharacter(player.Character)
end

---------------------------------------------------
-- PUBLIC API
---------------------------------------------------

function UPF:ToggleGodMode(on)

    if on == nil then
        UPF.State.GodMode = not UPF.State.GodMode
    else
        UPF.State.GodMode = on
    end

    print("🛡 GodMode:", UPF.State.GodMode)

    if player.Character then
        monitorCharacter(player.Character)
    end

    if UPF.SaveSettings then
        UPF:SaveSettings()
    end

end

---------------------------------------------------
-- RECOVERY FUNCTIONS
---------------------------------------------------

function UPF:RecoverPlayer()

    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.Health = humanoid.MaxHealth
        print("💚 Player recovered")
    end

end

function UPF:ReturnToSafePoint()

    local character = player.Character
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")

    if root then
        root.Velocity = Vector3.new(0,0,0)
        print("📍 Safe position restored")
    end

end

print("✅ module_recovery loaded")