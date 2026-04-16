-- module_scheduler.lua (ULTRA PRO)

local RunService = game:GetService("RunService")

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

UPF.Scheduler = UPF.Scheduler or {}

local tasks = {}

-- =========================
-- REGISTER
-- =========================

function UPF.Scheduler:AddTask(name, interval, fn)
    tasks[name] = {
        interval = interval,
        fn = fn,
        lastRun = 0
    }
end

function UPF.Scheduler:RemoveTask(name)
    tasks[name] = nil
end

-- =========================
-- LOOP CENTRAL
-- =========================

RunService.Heartbeat:Connect(function()
    local now = tick()

    for name, task in pairs(tasks) do
        if now - task.lastRun >= task.interval then
            task.lastRun = now

            local ok, err = pcall(task.fn)
            if not ok then
                warn("❌ Scheduler error:", name, err)
            end
        end
    end
end)

print("✅ Scheduler loaded")
