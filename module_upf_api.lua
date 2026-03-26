-- module_upf_api.lua
-- UPF API bootstrap (clean version)
-- Proporciona funciones seguras (stubs) para que la UI no falle
-- NO incluye reconnect ni teleport

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

-- Tablas base
UPF.State = UPF.State or {}
UPF.Settings = UPF.Settings or {}
UPF.Connections = UPF.Connections or {}

-- =========================
-- Helpers
-- =========================

local function makeToggleStub(stateKey, niceName)
    return function(self, on)
        if on == nil then
            UPF.State[stateKey] = not (UPF.State[stateKey])
        else
            UPF.State[stateKey] = (on and true) or false
        end

        print(("UPF (stub): %s -> %s"):format(
            niceName or stateKey,
            tostring(UPF.State[stateKey])
        ))

        return UPF.State[stateKey]
    end
end

-- =========================
-- STUBS SEGUROS
-- =========================

if not UPF.ToggleProtection then
    UPF.ToggleProtection = makeToggleStub("ProtectionEnabled", "Protection")
end

if not UPF.ToggleGodMode then
    UPF.ToggleGodMode = makeToggleStub("GodMode", "GodMode")
end

if not UPF.ReturnToSafePoint then
    UPF.ReturnToSafePoint = function()
        print("UPF (stub): ReturnToSafePoint (no impl yet)")
    end
end

if not UPF.RecoverPlayer then
    UPF.RecoverPlayer = function()
        print("UPF (stub): RecoverPlayer (no impl yet)")
    end
end

-- Audio Shield
if not UPF.ToggleAudioShield then
    UPF.ToggleAudioShield = function()
        UPF.State.Audio = UPF.State.Audio or {}
        UPF.State.Audio.Enabled = not (UPF.State.Audio.Enabled)

        print("UPF (stub): AudioShield ->", UPF.State.Audio.Enabled)
    end
end

if not UPF.SetAudioShieldRadius then
    UPF.SetAudioShieldRadius = function(r)
        UPF.State.Audio = UPF.State.Audio or {}
        UPF.State.Audio.Radius = tonumber(r) or 20

        print("UPF (stub): Audio Radius ->", UPF.State.Audio.Radius)
    end
end

if not UPF.SetAudioShieldLevel then
    UPF.SetAudioShieldLevel = function(l)
        UPF.State.Audio = UPF.State.Audio or {}
        UPF.State.Audio.Level = tonumber(l) or 0.25

        print("UPF (stub): Audio Level ->", UPF.State.Audio.Level)
    end
end

-- Guardado
if not UPF.SaveSettings then
    UPF.SaveSettings = function()
        print("UPF (stub): SaveSettings (no filesystem)")
    end
end

-- =========================
-- FLAGS IMPORTANTES
-- =========================

-- SOLO RECOVERY LOCAL
UPF.State.Resilience = UPF.State.Resilience or {}

-- Esto ahora SOLO controla el sistema de anti-stuck
UPF.State.Resilience.enabled = (UPF.State.Resilience.enabled ~= false)

-- NO reconnect, NO teleport
UPF.State.Resilience.allow_reconnect = false

print("✅ module_upf_api loaded (clean, no reconnect)")