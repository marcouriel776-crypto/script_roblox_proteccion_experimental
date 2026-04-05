-- module_resilience.lua (STABLE NO-CONFLICT)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

UPF.State = UPF.State or {}
UPF.State.Resilience = UPF.State.Resilience or {}

local RES = UPF.State.Resilience

RES.paused = RES.paused or false
RES.stuckTime = RES.stuckTime or 6
RES.lastRecovery = RES.lastRecovery or 0
RES.lastMoveTick = RES.lastMoveTick or tick()
RES.lastPos = RES.lastPos or nil
RES.lastStuckTrigger = RES.lastStuckTrigger or 0
RES.stuckCooldown = RES.stuckCooldown or 8

UPF.Resilience = UPF.Resilience or {}

-- =========================

local function getRoot()
	local char = LocalPlayer and LocalPlayer.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function localRecover()
	local root = getRoot()
	if not root then return end

	if tick() - RES.lastRecovery < 2 then return end
	RES.lastRecovery = tick()

	-- 🔥 SOLO limpiar fuerzas (NO mover posición)
	pcall(function()
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end)

	if type(UPF.RecoverPlayer) == "function" then
		pcall(function() UPF:RecoverPlayer() end)
	end

	print("[resilience] soft recovery executed")
end

-- =========================

function UPF.Resilience.Pause()
	RES.paused = true
end

function UPF.Resilience.Resume()
	RES.paused = false
end

function UPF.Resilience.AttemptRecovery()
	localRecover()
end

-- =========================

local function checkStuck()
	if RES.paused then return end

	local root = getRoot()
	if not root then
		RES.lastPos = nil
		RES.lastMoveTick = tick()
		return
	end

	local pos = root.Position
	local vel = root.AssemblyLinearVelocity.Magnitude

	if RES.lastPos then
		local dist = (pos - RES.lastPos).Magnitude

		if dist > 0.5 or vel > 1 then
			RES.lastMoveTick = tick()
		else
			local now = tick()

			if now - RES.lastMoveTick >= RES.stuckTime then
				if now - RES.lastStuckTrigger >= RES.stuckCooldown then
					RES.lastStuckTrigger = now
					print("[resilience] stuck → soft recover")
					localRecover()
				end

				RES.lastMoveTick = now
			end
		end
	else
		RES.lastMoveTick = tick()
	end

	RES.lastPos = pos
end

-- =========================

UPF.Connections = UPF.Connections or {}

if UPF.Connections.Resilience then
	pcall(function()
		UPF.Connections.Resilience:Disconnect()
	end)
end

UPF.Connections.Resilience = RunService.Heartbeat:Connect(function()
	pcall(checkStuck)
end)

print("✅ Resilience STABLE loaded")
