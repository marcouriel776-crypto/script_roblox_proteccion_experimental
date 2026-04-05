-- module_settings.lua (UPF SETTINGS PRO)

local HttpService = game:GetService("HttpService")

local SETTINGS_FILENAME = "upf_config.json"

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

UPF.State = UPF.State or {}

-- =========================
-- DEFAULT SETTINGS
-- =========================

local Settings = {
    protection_enabled = true,
    godmode_enabled = false,
    smart_mode = "SAFE",
    noclip_players = false
}

-- =========================
-- FILE HELPERS
-- =========================

local function try_readfile(path)
    if type(readfile) ~= "function" then return nil end
    local ok, content = pcall(readfile, path)
    return ok and content or nil
end

local function try_writefile(path, content)
    if type(writefile) ~= "function" then return false end
    return pcall(writefile, path, content)
end

-- =========================
-- LOAD
-- =========================

function UPF:LoadSettings()

    local src = try_readfile(SETTINGS_FILENAME) or _G.UPF_LOCAL_SETTINGS
    if not src then return false end

    local ok, parsed = pcall(function()
        return HttpService:JSONDecode(src)
    end)

    if not ok or type(parsed) ~= "table" then return false end

    for k,v in pairs(parsed) do
        Settings[k] = v
    end

    -- 🔥 APLICAR A UPF.STATE (CLAVE)
    UPF.State.ProtectionEnabled = Settings.protection_enabled
    UPF.State.GodMode = Settings.godmode_enabled
    UPF.State.SmartMode = Settings.smart_mode
    UPF.State.NoClipPlayers = Settings.noclip_players

    print("✅ Settings loaded into UPF.State")

    return true
end

-- =========================
-- SAVE
-- =========================

function UPF:SaveSettings()

    -- 🔥 LEER DESDE UPF.STATE
    Settings.protection_enabled = UPF.State.ProtectionEnabled
    Settings.godmode_enabled = UPF.State.GodMode
    Settings.smart_mode = UPF.State.SmartMode
    Settings.noclip_players = UPF.State.NoClipPlayers

    local encoded = HttpService:JSONEncode(Settings)

    local ok = try_writefile(SETTINGS_FILENAME, encoded)
    if not ok then
        _G.UPF_LOCAL_SETTINGS = encoded
    end

    print("💾 Settings saved")

    return ok
end

-- =========================
-- AUTO LOAD (SEGURO)
-- =========================

task.spawn(function()
    repeat task.wait() until UPF and UPF.State
    UPF:LoadSettings()
end)

print("✅ Settings PRO loaded")