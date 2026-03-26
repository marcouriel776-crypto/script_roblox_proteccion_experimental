-- module_resilience.lua
-- Local recovery only. No reconnect. No teleport. No autorejoin.

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

UPF.Resilience = UPF.Resilience or {}

local function getCharacter()
	return LocalPlayer and LocalPlayer.Character
end

local function getRoot()
	local character = getCharacter()
	if not character then
		return nil
	end
	return character:FindFirstChild("HumanoidRootPart")
end

local function localRecover()
	local root = getRoot()
	if not root then
		return
	end

	if tick() - RES.lastRecovery < 2 then
		return
	end
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
end

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

local function checkStuck()
	if RES.paused then
		return
	end

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
			RES.lastMoveTick = tick()
		elseif tick() - RES.lastMoveTick >= RES.stuckTime then
			print("[resilience] Player appears stuck")
			localRecover()
			RES.lastMoveTick = tick()
		end
	else
		RES.lastMoveTick = tick()
	end

	RES.lastPos = pos
end

if UPF.Connections == nil then
	UPF.Connections = {}
end

if UPF.Connections.Resilience then
	pcall(function()
		UPF.Connections.Resilience:Disconnect()
	end)
	UPF.Connections.Resilience = nil
end

UPF.Connections.Resilience = RunService.Heartbeat:Connect(function()
	pcall(checkStuck)
end)

print("✅ module_resilience loaded (no reconnect)")