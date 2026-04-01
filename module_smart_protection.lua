-- =========================
-- SAFE MOVEMENT
-- =========================

local LastPos = nil
local SafePoint = nil
local lastRollback = 0
local rollbackCooldown = 1.5

local function trackMovement()
	local char = LocalPlayer.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end

	-- ignorar cuando estás en el aire
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
