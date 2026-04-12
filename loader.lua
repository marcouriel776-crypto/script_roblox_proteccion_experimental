local BASE_URL = "https://raw.githubusercontent.com/marcouriel776-crypto/script_roblox_proteccion_experimental/main/"

getgenv().UPF = getgenv().UPF or {}
local UPF = getgenv().UPF

UPF.Enabled = true
UPF.Modules = {}
UPF.LoadResults = {}
UPF.State = UPF.State or {}
UPF.Connections = UPF.Connections or {}

local MODULES = {
    "module_core.lua",
    "module_utils.lua",
    "module_settings.lua",
    "module_upf_api.lua",
    "module_recovery.lua",
    "module_protection.lua",
    "module_smart.lua",
    "module_resilience.lua",
    "module_noclip_players.lua",
    "module_ui.lua"
    "module_modal_manager.lua",
    "module_antikick.lua",
}

-- =========================
-- LOADER
-- =========================

local function loadModule(file)
    local url = BASE_URL .. file

    local success, src = pcall(function()
        return game:HttpGet(url)
    end)

    if not success or not src then
        UPF.LoadResults[file] = {success = false, error = "download failed"}
        warn("❌ Download failed:", file)
        return
    end

    local fn, err = loadstring(src)
    if not fn then
        UPF.LoadResults[file] = {success = false, error = err}
        warn("❌ Compile error:", file, err)
        return
    end

    local ok, runtimeErr = pcall(fn)
    if not ok then
        UPF.LoadResults[file] = {success = false, error = runtimeErr}
        warn("❌ Runtime error:", file, runtimeErr)
        return
    end

    UPF.Modules[file] = true
    UPF.LoadResults[file] = {success = true}
    print("✅ Loaded:", file)
end

-- =========================
-- EXECUTION
-- =========================

for _, module in ipairs(MODULES) do
    loadModule(module)
end

print("🚀 UPF CLEAN SYSTEM LOADED")
