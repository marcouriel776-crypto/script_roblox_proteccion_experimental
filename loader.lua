-- loader.lua (updated)
local HttpService = game:GetService("HttpService")
local BASE_URL = "https://raw.githubusercontent.com/marcouriel776-crypto/script_roblox_proteccion_experimental/main/"

local MODULES = {
    "module_settings.lua",
    "module_core.lua",
    "module_ui.lua",
    "module_protection.lua",
    "module_smart.lua",
    "module_recovery.lua",
    "module_utils.lua",
    "module_audio.lua"
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
        warn("Error running module:", moduleName, runErr)
        break
    end
end