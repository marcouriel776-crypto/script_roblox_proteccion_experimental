-- loader.lua (FINAL)
local BASE_URL = "https://raw.githubusercontent.com/marcouriel776-crypto/script_roblox_proteccion_experimental/main/"

local MODULES = {
    "module_settings.lua",
    "module_core.lua",
    "module_ui.lua",
    "module_utils.lua",
    "module_protection.lua",
    "module_smart.lua",
    "module_recovery.lua",
    "module_audio.lua",
}

for _, name in ipairs(MODULES) do
    local src
    local ok, err = pcall(function()
        src = game:HttpGet(BASE_URL .. name)
    end)
    if not ok then
        warn("❌ Failed to download:", name, err)
        break
    end

    local fn, loadErr = loadstring(src)
    if not fn then
        warn("❌ Failed to load:", name, loadErr)
        break
    end

    print("✅ Loaded:", name)
    local ran, runErr = pcall(fn)
    if not ran then
        warn("❌ Error running:", name, runErr)
        break
    end
end