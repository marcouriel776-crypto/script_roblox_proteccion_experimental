-- module_settings.lua
local HttpService = game:GetService("HttpService")

local FILE = "upf_config.json"

Settings = Settings or {
    protection = false,
    override = nil,
    god = false,
    smart = "SAFE",
    autoReturn = true,
    audio = false,
    audioRadius = 20,
    audioLevel = 0.25
}

local function read()
    if type(readfile) ~= "function" then return nil end
    local ok, data = pcall(readfile, FILE)
    return ok and data or nil
end

local function write(data)
    if type(writefile) ~= "function" then return end
    pcall(writefile, FILE, data)
end

function LoadUPFSettings()
    local raw = read()
    if not raw then return end
    local ok, parsed = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok then return end
    for k,v in pairs(parsed) do Settings[k] = v end
end

function SaveUPFSettings()
    local ok, data = pcall(HttpService.JSONEncode, HttpService, Settings)
    if ok then write(data) end
end

LoadUPFSettings()
print("✅ Settings loaded")