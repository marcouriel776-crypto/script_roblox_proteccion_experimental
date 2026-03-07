-- module_settings.lua
local UPF = _G.UPF
if not UPF then warn("UPF not initialized"); return end

local HttpService = game:GetService("HttpService")
local SETTINGS_FILENAME = "upf_config.json"

UPF.Settings = UPF.Settings or {
    protection_enabled = false,
    protection_manual_override = nil,
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

function UPF:LoadSettings()
    local src = try_readfile(SETTINGS_FILENAME) or _G.UPF_LOCAL_SETTINGS
    if not src then return false end
    local ok, parsed = pcall(function() return HttpService:JSONDecode(src) end)
    if not ok or type(parsed) ~= "table" then return false end
    for k,v in pairs(parsed) do UPF.Settings[k] = v end
    return true
end

function UPF:SaveSettings()
    local encoded = HttpService:JSONEncode(UPF.Settings)
    local ok = try_writefile(SETTINGS_FILENAME, encoded)
    if not ok then _G.UPF_LOCAL_SETTINGS = encoded end
    return ok
end

-- try load existing settings
pcall(function() UPF:LoadSettings() end)
print("✅ Settings loaded")