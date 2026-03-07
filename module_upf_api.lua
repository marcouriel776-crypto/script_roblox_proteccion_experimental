-- module_upf_api.lua
-- Small safe API bootstrap for UPF.
-- Creates _G.UPF and safe no-op stubs so UI can call methods before modules that define full implementations load.
-- Real modules (module_recovery, module_protection, etc.) can overwrite these methods.

local HttpService = game:GetService("HttpService")

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

-- basic state tables
UPF.State = UPF.State or {}
UPF.Settings = UPF.Settings or {}

-- safe stubs: they won't error if UI calls them early
local function noop(...) return nil end

-- Helper to create toggles that update state and print
local function makeToggleStub(stateKey, niceName)
    return function(self, on)
        if on == nil then
            UPF.State[stateKey] = not (UPF.State[stateKey])
        else
            UPF.State[stateKey] = (on and true) or false
        end
        print(("UPF (stub): %s -> %s"):format(niceName or stateKey, tostring(UPF.State[stateKey])))
        return UPF.State[stateKey]
    end
end

-- Provide safe methods (these will be overwritten by real modules that implement them)
if not UPF.ToggleProtection then UPF.ToggleProtection = makeToggleStub("ProtectionEnabled", "Protection") end
if not UPF.ToggleGodMode then UPF.ToggleGodMode = makeToggleStub("GodMode", "GodMode") end
if not UPF.ReturnToSafePoint then
    UPF.ReturnToSafePoint = function()
        print("UPF (stub): ReturnToSafePoint called - no-op (real impl not loaded yet).")
    end
end
if not UPF.RecoverPlayer then
    UPF.RecoverPlayer = function()
        print("UPF (stub): RecoverPlayer called - no-op (real impl not loaded yet).")
    end
end
if not UPF.ToggleAudioShield then UPF.ToggleAudioShield = function() UPF.State.Audio = UPF.State.Audio or {}; UPF.State.Audio.Enabled = not (UPF.State.Audio.Enabled); print("UPF (stub): ToggleAudioShield ->", UPF.State.Audio.Enabled) end end
if not UPF.SetAudioShieldRadius then UPF.SetAudioShieldRadius = function(r) UPF.State.Audio = UPF.State.Audio or {}; UPF.State.Audio.Radius = tonumber(r) or UPF.State.Audio.Radius or 20; print("UPF (stub): SetAudioShieldRadius ->", UPF.State.Audio.Radius) end end
if not UPF.SetAudioShieldLevel then UPF.SetAudioShieldLevel = function(l) UPF.State.Audio = UPF.State.Audio or {}; UPF.State.Audio.Level = tonumber(l) or UPF.State.Audio.Level or 0.25; print("UPF (stub): SetAudioShieldLevel ->", UPF.State.Audio.Level) end end
if not UPF.SaveSettings then UPF.SaveSettings = function() print("UPF (stub): SaveSettings called (no filesystem available in stub).") end end

-- Expose a container for connection references (modules may use it)
UPF.Connections = UPF.Connections or {}

print("✅ module_upf_api loaded (stubs in place). Real implementations will override these when available.")