-- module_resilience.lua (FINAL PRO STABLE)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

UPF.State = UPF.State or {}
UPF.State.Resilience = UPF.State.Resilience or {}

local RES = UPF.State.Resilience

-- =========================
-- STATE
-- =========================

RES.paused = RES.paused or false
RES.stuckTime = RES.stuckTime or 6
RES.lastRecovery = RES.lastRecovery or 0
RES.lastMoveTick = RES.lastMoveTick or tick()
RES.lastPos = RES.lastPos or nil
RES.lastStuckTrigger = RES.lastStuckTrigger or 0

-- anti-loop cooldown
RES.stuckCooldown = RES.stuckCooldown or 8

UPF.Resilience = UPF.Resilience or {}

-- =========================
-- HELPERS
-- =========================

local function getRoot()
	local char = LocalPlayer and LocalPlayer.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function localRecover()
	local root = getRoot()
	if not root then return end

	-- cooldown anti spam
	if tick() - RES.lastRecovery < 2 then return end
	RES.lastRecovery = tick()

	pcall(function()
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end)

	if type(UPF.RecoverPlayer) == "function" then
		pcall(function() UPF:RecoverPlayer() end)
	end

	if type(UPF.ReturnToSafePoint) == "function" then
		pcall(function() UPF:ReturnToSafePoint() end)
	end

	print("[resilience] local recovery executed")
end

-- =========================
-- API
-- =========================

function UPF.Resilience.Pause()
	RES.paused = true
	print("[resilience] paused")
end

function UPF.Resilience.Resume()
	RES.paused = false
	print("[resilience] resumed")
end

function UPF.Resilience.AttemptRecovery()
	localRecover()
end

-- compatibilidad externa (opcional)
function UPF.Resilience:Check(character)
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local velocity = root.Velocity.Magnitude

	if velocity < 1 and tick() - RES.lastRecovery > 5 then
		RES.lastRecovery = tick()
		root.CFrame = root.CFrame + Vector3.new(0, 5, 0)
	end
end

-- =========================
-- CORE LOGIC
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
	local vel = 0

	pcall(function()
		vel = root.AssemblyLinearVelocity.Magnitude
	end)

	if RES.lastPos then
		local dist = (pos - RES.lastPos).Magnitude

		if dist > 0.5 or vel > 1 then
			-- jugador se movió
			RES.lastMoveTick = tick()
		else
			local now = tick()

			if now - RES.lastMoveTick >= RES.stuckTime then
				-- evitar spam infinito
				if now - RES.lastStuckTrigger >= RES.stuckCooldown then
					RES.lastStuckTrigger = now
					print("[resilience] Player appears stuck → recovering")
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
-- CONNECTION CLEAN
-- =========================

UPF.Connections = UPF.Connections or {}

if UPF.Connections.Resilience then
	pcall(function()
		UPF.Connections.Resilience:Disconnect()
	end)
	UPF.Connections.Resilience = nil
end

UPF.Connections.Resilience = RunService.Heartbeat:Connect(function()
	pcall(checkStuck)
end)

print("✅ module_resilience FINAL PRO loaded")