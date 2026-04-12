-- module_settings.lua (PRO CLEAN)

local HttpService = game:GetService("HttpService")

local UPF = _G.UPF
UPF.Settings = UPF.Settings or {}

local FILE = "upf_config.json"

local function safeRead()
    if type(readfile) ~= "function" then return nil end
    local ok, data = pcall(readfile, FILE)
    if ok then return data end
end

local function safeWrite(data)
    if type(writefile) ~= "function" then return false end
    return pcall(writefile, FILE, data)
end

function UPF:LoadSettings()
    local raw = safeRead()
    if not raw then return end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(raw)
    end)

    if ok and type(data) == "table" then
        for k,v in pairs(data) do
            UPF.Settings[k] = v
        end
        print("✅ Settings loaded")
    end
end

function UPF:SaveSettings()
    local encoded = HttpService:JSONEncode(UPF.Settings)

    local ok = safeWrite(encoded)
    if ok then
        print("💾 Settings saved")
    else
        _G.UPF_LOCAL_SETTINGS = encoded
        print("⚠️ Saved locally (fallback)")
    end
end

-- LOAD AUTOMÁTICO
UPF:LoadSettings()

print("✅ Settings loaded")
