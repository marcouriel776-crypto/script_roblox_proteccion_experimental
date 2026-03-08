-- loader.lua (fixed order + api stub)
local BASE_URL = "https://raw.githubusercontent.com/marcouriel776-crypto/script_roblox_proteccion_experimental/main/"

local MODULES = {
    -- CORE / SETTINGS
    "module_settings.lua",
    "module_core.lua",
    "module_utils.lua",

    -- UPF API STUB (asegura que la UI no falle si algún módulo tarda)
    "module_upf_api.lua",

    -- SYSTEMS / LOGICA
    "module_protection.lua",
    "module_smart.lua",
    "module_recovery.lua",
    "module_audio.lua",
    "module_antifreeze.lua",

    -- UI (carga después de que las APIs básicas estén disponibles)
    "module_ui_theme.lua",
    "module_ui.lua",
    "module_ui_logs.lua",
    "module_modal_detector.lua",
    "module_resilience.lua",
}

for i, moduleName in ipairs(MODULES) do
    local url = BASE_URL .. moduleName
    local source
    local ok, err = pcall(function() source = game:HttpGet(url) end)
    if not ok then
        warn("Failed to download:", moduleName, err)
        break
    end

    local fn, loadErr = loadstring(source)
    if not fn then
        warn("❌ Error loading module:", moduleName, loadErr)
        break
    end

    print("✅ Loaded:", moduleName)
    local success, runErr = pcall(fn)
    if not success then
        warn("❌ Error running module:", moduleName, runErr)
        break
    end
end

print("🛡 UPF Loader finished")