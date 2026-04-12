-- module_upf_api.lua (CORE API)

local UPF = _G.UPF
if not UPF then return end

-- =========================
-- SAFE CALL
-- =========================

function UPF:SafeCall(fn, ...)
    if type(fn) ~= "function" then return end
    local ok, err = pcall(fn, ...)
    if not ok then
        warn("[UPF Error]:", err)
    end
end

-- =========================
-- STATE HELPERS
-- =========================

function UPF:IsReady()
    return UPF.State and UPF.State.CharacterReady
end

function UPF:IsProtectionEnabled()
    return UPF.State and UPF.State.ProtectionEnabled
end

-- =========================
-- MODULE CONTROL
-- =========================

function UPF:IsModuleLoaded(name)
    return UPF.Modules and UPF.Modules[name]
end

-- =========================
-- DEBUG
-- =========================

function UPF:PrintModules()
    for mod, data in pairs(UPF.LoadResults or {}) do
        print(mod, data.success and "✅" or "❌")
    end
end

-- =========================
-- LOOP CONTROL (PRO 🔥)
-- =========================

UPF.Loops = UPF.Loops or {}

function UPF:BindLoop(name, fn)
    if UPF.Loops[name] then
        UPF.Loops[name]:Disconnect()
    end

    local RunService = game:GetService("RunService")

    UPF.Loops[name] = RunService.Heartbeat:Connect(function()
        self:SafeCall(fn)
    end)
end

function UPF:UnbindLoop(name)
    if UPF.Loops[name] then
        UPF.Loops[name]:Disconnect()
        UPF.Loops[name] = nil
    end
end

print("✅ UPF API loaded")
