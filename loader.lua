-- loader.lua PRO
if _G.UPF_LOADER then
    warn("UPF loader already running.")
    return
end
_G.UPF_LOADER = true

-- init global framework
_G.UPF = _G.UPF or {}
local UPF = _G.UPF
UPF.Modules = UPF.Modules or {}
UPF.Connections = UPF.Connections or {}
UPF.State = UPF.State or {}
UPF.Settings = UPF.Settings or {}

local BASE_URL = "https://raw.githubusercontent.com/marcouriel776-crypto/script_roblox_proteccion_experimental/main/"

local MODULES = {
    "module_settings.lua",
    "module_core.lua",
    "module_utils.lua",
    "module_ui.lua",
    "module_protection.lua",
    "module_smart.lua",
    "module_recovery.lua",
    "module_audio.lua",
    "module_modal_detector.lua",
    "module_resilience.lua",
}

local function LoadModule(name)
    local url = BASE_URL .. name
    local ok, source = pcall(function() return game:HttpGet(url) end)
    if not ok then
        warn("Failed to download:", name, source)
        return false
    end
    local fn, err = loadstring(source)
    if not fn then
        warn("Compile error:", name, err)
        return false
    end
    local succ, runErr = pcall(fn)
    if not succ then
        warn("Runtime error:", name, runErr)
        return false
    end
    print("✅ Module loaded:", name)
    return true
end

for _, m in ipairs(MODULES) do
    if not LoadModule(m) then
        warn("Stopping loader due to failure at", m)
        break
    end
end

print("🚀 UPF loader finished")
print(" ")
print("==========================================")
print("UPF Protection Framework Loaded")
print("Author: markuriel2010")
print("Co-Developer: Sourcerer")
print("Repository: script_roblox_proteccion_experimental")
print("Version: 1.0 Experimental")
print("==========================================")
print(" ")