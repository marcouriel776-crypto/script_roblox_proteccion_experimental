local BASE_URL = "https://raw.githubusercontent.com/marcouriel776-crypto/script_roblox_proteccion_experimental/main/"

local MODULES = {
    "module_core.lua",
    "module_assets.lua",
    "module_visual.lua",
    "module_ui.lua"
}

for _, file in ipairs(MODULES) do
    local src = game:HttpGet(BASE_URL .. file)
    local fn = loadstring(src)
    pcall(fn)
end

print("🚀 UPF VISUAL SYSTEM LOADED")
