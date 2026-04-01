-- module_smart_protection.lua (SAFE VERSION)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

UPF.State = UPF.State or {}
UPF.State.Smart = UPF.State.Smart or {}

local function checkPlayers()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local vel = hrp.AssemblyLinearVelocity.Magnitude

				if vel > 150 then
					warn("[UPF] ⚠️ Possible flinger:", plr.Name)
				end
			end
		end
	end
end

UPF.Connections = UPF.Connections or {}

if UPF.Connections.Smart then
	pcall(function()
		UPF.Connections.Smart:Disconnect()
	end)
end

UPF.Connections.Smart = RunService.Heartbeat:Connect(function()
	pcall(checkPlayers)
end)

print("✅ Smart Protection (no conflict) loaded")
