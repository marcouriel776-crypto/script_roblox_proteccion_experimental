-- module_smart_protection.lua (PRO OPTIMIZED)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

UPF.State = UPF.State or {}
UPF.State.Smart = UPF.State.Smart or {}
local State = UPF.State.Smart

State.max_distance_per_frame = 35
State.player_velocity_threshold = 140

-- =========================
-- ANTI-FLING
-- =========================

local function checkPlayers()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local vel = hrp.AssemblyLinearVelocity.Magnitude

				if vel > State.player_velocity_threshold then
					warn("[UPF] High velocity player:", plr.Name)
				end
			end
		end
	end
end

-- =========================
-- SAFE MOVEMENT
-- =========================

local LastPos = nil
local SafePoint = nil

local function trackMovement()
local lastRollback = 0
local rollbackCooldown = 1.5

local function trackMovement()
	local char = LocalPlayer.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end

	-- ignorar cuando estás en el aire (MUY IMPORTANTE)
	if hum.FloorMaterial == Enum.Material.Air then
		LastPos = hrp.Position
		return
	end

	local vel = hrp.AssemblyLinearVelocity.Magnitude

	if vel < 10 then
		SafePoint = hrp.CFrame
	end

	if LastPos then
		local dist = (hrp.Position - LastPos).Magnitude

		if dist > State.max_distance_per_frame then
			if SafePoint and tick() - lastRollback > rollbackCooldown then
				lastRollback = tick()
				hrp.CFrame = SafePoint
				warn("[UPF] Safe rollback")
			end
		end
	end

	LastPos = hrp.Position
end
-- =========================
-- CONNECTION
-- =========================

UPF.Connections = UPF.Connections or {}

if UPF.Connections.Smart then
	pcall(function()
		UPF.Connections.Smart:Disconnect()
	end)
end

UPF.Connections.Smart = RunService.Heartbeat:Connect(function()
	pcall(checkPlayers)
	pcall(trackMovement)
end)

print("✅ Smart Protection PRO (optimized) loaded")
