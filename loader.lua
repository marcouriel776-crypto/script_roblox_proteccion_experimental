-- loader.lua
-- Carga los módulos en el orden correcto: core -> protection -> smart -> recovery

local base = "https://raw.githubusercontent.com/marcouriel776-crypto/script_roblox_proteccion_experimental/main/"

local modules = {
  "module_settings.lua",   -- si existe
  "module_core.lua",
  "module_ui.lua",
  "module_protection.lua",
  "module_smart.lua",
  "module_recovery.lua",
  "module_utils.lua",
  "module_audio.lua",
}

for _, m in ipairs(modules) do
    local url = base .. m
    local ok, src = pcall(function() return game:HttpGet(url) end)
    if not ok then
        warn("Failed to download module:", m, src)
        break
    end

    local fn, err = loadstring(src)
    if not fn then
        warn("Failed to load module:", m, err)
        break
    end

    local success, err2 = pcall(fn)
    if not success then
        warn("Error running module:", m, err2)
        break
    end

    print("✅ Loaded:", m)
end
