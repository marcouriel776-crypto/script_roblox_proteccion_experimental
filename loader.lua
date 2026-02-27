-- Universal Protection Framework Loader
-- Platform: Android / Delta
-- Version: 0.9.x (Dev)

local HttpService = game:GetService("HttpService")

local BASE_URL = "https://raw.githubusercontent.com/marcouriel776-crypto/script_roblox_proteccion_experimental/main/"

local MODULES = {
    "module_core.lua",
    "module_protection.lua",
    "module_smart.lua",
    "module_recovery.lua"
}

for i, moduleName in ipairs(MODULES) do
    local url = BASE_URL .. moduleName
    local source = game:HttpGet(url)
    local fn, err = loadstring(source)
    if not fn then
        warn("❌ Error loading module:", moduleName, err)
        break
    end
    print("✅ Loaded:", moduleName)
    fn()
end