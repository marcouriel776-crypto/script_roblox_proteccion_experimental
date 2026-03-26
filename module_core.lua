-- module_core.lua (UPF Core)
if _G.UPF and _G.UPF.CoreLoaded then
    warn("UPF Core already loaded.")
    return
end

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

UPF.CoreLoaded = true
UPF.Connections = UPF.Connections or {}
UPF.State = UPF.State or {}
UPF.Settings = UPF.Settings or {}

-- default state
UPF.State.ScriptRunning = true
UPF.State.ProtectionEnabled = UPF.Settings.protection_enabled or false
UPF.State.ProtectionManualOverride = UPF.Settings.protection_manual_override
UPF.State.GodModeEnabled = UPF.Settings.godmode_enabled or false
UPF.State.SmartMode = UPF.Settings.smart_mode or "SAFE"
UPF.State.AutoReturnEnabled = UPF.Settings.auto_return_enabled or true
UPF.State.ReturnCooldown = UPF.Settings.return_cooldown or 5
UPF.State.LastAutoReturn = UPF.State.LastAutoReturn or 0
UPF.State.FlingEvents = UPF.State.FlingEvents or 0

UPF.Character = nil
UPF.Humanoid = nil
UPF.RootPart = nil

local LocalPlayer = Players.LocalPlayer

local function UpdateCharacter(char)
    UPF.Character = char
    UPF.Humanoid = char:FindFirstChild("Humanoid") or char:WaitForChild("Humanoid",5)
    UPF.RootPart = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart",5)
end

if LocalPlayer.Character then UpdateCharacter(LocalPlayer.Character) end
UPF.Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(UpdateCharacter)

-- public API
function UPF:ToggleProtection(on)
    if on == nil then
        self.State.ProtectionEnabled = not self.State.ProtectionEnabled
    else
        self.State.ProtectionEnabled = on
    end
    print("UPF:Protection ->", tostring(self.State.ProtectionEnabled))
    if self.SaveSettings then pcall(function() self:SaveSettings() end) end
end

function UPF:Shutdown()
    print("UPF:Shutting down...")
    self.State.ScriptRunning = false
    self.State.ProtectionEnabled = false
    -- disconnect connections
    for k, conn in pairs(self.Connections) do
        pcall(function()
            if type(conn) == "userdata" and conn.Disconnect then conn:Disconnect() end
            self.Connections[k] = nil
        end)
    end
    -- remove UI if exists (PlayerGui or CoreGui)
    pcall(function()
        local plr = LocalPlayer
        if plr and plr:FindFirstChild("PlayerGui") then
            local g = plr.PlayerGui:FindFirstChild("ProtectionUI")
            if g then g:Destroy() end
        end
        local cg = CoreGui:FindFirstChild("ProtectionUI")
        if cg then cg:Destroy() end
    end)
end

print("✅ Core initialized")

print(" ")
print("==========================================")
print("UPF Protection Framework Loaded")
print("Author: Uriel Reich")
print("Co-Developer: ChatGPT")
print("Repository: script_roblox_proteccion_experimental")
print("Version: 1.0 Experimental")
print("==========================================")
print("⠀⠀⠀⠀⠀⢠⣒⣤⠤⣀⣀⠀
⠀⠀⠠⣒⢤⠋⠂⠈⡷⠒⠒⣗⠢⡀⠀⠀⠀⠀
⠀⢠⠋⠀⡇⠀⠀⣰⠁⠀⢀⡼⠠⣱⠀⠀⠀⠀
⠀⢈⠀⠀⣧⣀⣠⣏⢀⠴⠋⠉⠙⡟⡄⠀⠀⠀
⠀⠘⣄⢠⠟⠉⠉⢻⡎⠀⠀⠀⣸⠇⢸⠀⠀⠀
⠀⢀⠜⡏⠁⠀⠀⠀⣧⣀⣠⠾⠋⠀⡜⠀⠀⠀
⠀⡜⠀⠁⠀⠀⠀⠀⠘⣷⠀⠀⡠⠊⠀⠀⠀⠀
⠀⠹⣁⡤⢾⡀⠀⠀⢠⠏⠀⡐⠁⠀⠀⠀⠀⠀
⠀⠀⠃⢴⠀⠉⠒⠚⠃⠀⢠⠁⠀⠀⠀⠀⠀⠀
⠀⢸⠀⠈⠁⠀⠀⠀⠀⠀⠀⡎⠀⠀⠀⠀⠀⠀⠀
⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⢠⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠸⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠤⠤⠤⠤⠤⠤⠤⠤⠤⠀⠀⠀⠀⠀⠀⠀ ")