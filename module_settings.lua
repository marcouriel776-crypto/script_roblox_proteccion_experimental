-- module_settings.lua
-- Persistencia de configuración para Universal Protection Framework
-- Intenta usar writefile/readfile del executor; si no existe, usa _G (temporal)

local HttpService = game:GetService("HttpService")

local SETTINGS_FILENAME = "upf_config.json"

-- valores por defecto
Settings = Settings or {
    protection_enabled = false,
    protection_manual_override = nil, -- nil = sin override, true=forzado ON, false=forzado OFF
    godmode_enabled = false,
    smart_mode = "SAFE",
    auto_return_enabled = true,
    return_cooldown = 5,
    audio_shield_enabled = false,
    audio_shield_radius = 20,
    audio_shield_level = 0.25
}

local function try_readfile(path)
    if type(readfile) ~= "function" then return nil end
    local ok, content = pcall(readfile, path)
    if ok then return content end
    return nil
end

local function try_writefile(path, content)
    if type(writefile) ~= "function" then return false end
    local ok = pcall(writefile, path, content)
    return ok
end

function LoadUPFSettings()
    -- intenta leer archivo
    local src = try_readfile(SETTINGS_FILENAME) or _G.UPF_LOCAL_SETTINGS
    if not src then return false end
    local ok, parsed = pcall(function() return HttpService:JSONDecode(src) end)
    if not ok or type(parsed) ~= "table" then return false end
    for k,v in pairs(parsed) do
        Settings[k] = v
    end

    -- aplicar a variables globales si existen (core)
    pcall(function()
        ProtectionEnabled = Settings.protection_enabled
        ProtectionManualOverride = Settings.protection_manual_override
        GodModeEnabled = Settings.godmode_enabled
        SmartMode = Settings.smart_mode
        AutoReturnEnabled = Settings.auto_return_enabled
        ReturnCooldown = Settings.return_cooldown or ReturnCooldown
        -- audio settings
        if Settings.audio_shield_enabled ~= nil then
            -- leave for audio module to handle its own state reading
        end
    end)

    return true
end

function SaveUPFSettings()
    -- sincroniza Settings desde variables globales actuales (si existen)
    pcall(function()
        Settings.protection_enabled = ProtectionEnabled or Settings.protection_enabled
        Settings.protection_manual_override = (ProtectionManualOverride ~= nil) and ProtectionManualOverride or Settings.protection_manual_override
        Settings.godmode_enabled = GodModeEnabled or Settings.godmode_enabled
        Settings.smart_mode = SmartMode or Settings.smart_mode
        Settings.auto_return_enabled = AutoReturnEnabled or Settings.auto_return_enabled
        Settings.return_cooldown = ReturnCooldown or Settings.return_cooldown
        Settings.audio_shield_enabled = Settings.audio_shield_enabled -- audio module updates it
        Settings.audio_shield_radius = Settings.audio_shield_radius
        Settings.audio_shield_level = Settings.audio_shield_level
    end)

    local encoded = HttpService:JSONEncode(Settings)
    local ok = try_writefile(SETTINGS_FILENAME, encoded)
    if not ok then
        -- fallback in-memory
        _G.UPF_LOCAL_SETTINGS = encoded
    end
    return ok
end

-- carga al ejecutar (si se llama directo)
LoadUPFSettings()

print("✅ Settings module loaded (persistence ready)")