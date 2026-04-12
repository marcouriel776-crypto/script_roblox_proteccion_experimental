-- loader_v4.lua (FINAL PRO FIXED)

local BASE_URL = "https://raw.githubusercontent.com/marcouriel776-crypto/script_roblox_proteccion_experimental/main/"

-- =========================
-- INIT UPF
-- =========================

getgenv().UPF = getgenv().UPF or {}
local UPF = getgenv().UPF

UPF.Enabled = true
UPF.Modules = UPF.Modules or {}
UPF.Settings = UPF.Settings or {}
UPF.State = UPF.State or {}
UPF.Connections = UPF.Connections or {}
UPF.Logs = UPF.Logs or {}

-- =========================
-- LOG
-- =========================

function UPF:Log(msg)
    local text = "["..os.date("%H:%M:%S").."] "..msg
    print(text)
    table.insert(self.Logs, 1, text)
end

-- =========================
-- MODULE LIST
-- =========================

local MODULES = {
    "module_core.lua",
    "module_utils.lua",
    "module_settings.lua",
    "module_upf_api.lua",
    "module_recovery.lua",
    "module_protection.lua",
    "module_smart.lua",
    "module_noclip_players.lua",
    "module_resilience.lua",
    "module_audio.lua",
    "module_admin_detector.lua",
    "module_decision_engine.lua",             
    "module_behavior_analyzer.lua",
    "module_ui.lua",
    "module_antikick.lua",
    "module_modal_manager.lua"
}

-- =========================
-- HTTP GET
-- =========================

local function fetch(url)
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)

    if ok and res then
        return res
    else
        return nil
    end
end

-- =========================
-- LOAD MODULES
-- =========================

for _, file in ipairs(MODULES) do

    if UPF.Modules[file] then
        UPF:Log("Skipping "..file)
        continue
    end

    UPF:Log("Loading "..file.."...")

    local url = BASE_URL .. file
    local src = fetch(url)

    if not src then
        UPF:Log("❌ Failed to fetch "..file)
        continue
    end

    local fn, compileErr = loadstring(src)
    if not fn then
        UPF:Log("❌ Compile error "..file.." → "..tostring(compileErr))
        continue
    end

    local ok, runtimeErr = pcall(fn)
    if not ok then
        UPF:Log("❌ Runtime error "..file.." → "..tostring(runtimeErr))
        continue
    end

    UPF.Modules[file] = true
    UPF:Log("✅ Loaded "..file)

end

UPF:Log("🚀 UPF SYSTEM FULLY LOADED")
