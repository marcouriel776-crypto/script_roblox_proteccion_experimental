-- loader_v4.lua (FINAL LIMPIO - EXECUTOR)

local BASE_URL = "https://raw.githubusercontent.com/marcouriel776-crypto/script_roblox_proteccion_experimental/main/"

local MODULES = {
    "module_settings.lua",
    "module_utils.lua",
    "module_upf_api.lua",
    "module_core.lua",
    "module_protection.lua",
    "module_smart.lua",
    "module_smart_protection.lua",
    "module_recovery.lua",
    "module_resilience.lua",
    "module_antifreeze.lua",
    "module_audio.lua",
    "module_behavior_analyzer.lua",
    "module_admin_detector.lua",
    "module_decision_engine.lua",
    "module_ui.lua",
    "module_ui_theme.lua",
    "module_ui_logs.lua",
    "module_antikick.lua",
    "installer.lua",
}

-- =========================
-- BASE GLOBAL
-- =========================

getgenv().UPF = getgenv().UPF or {}
local UPF = getgenv().UPF

UPF.Enabled = true
UPF.Modules = UPF.Modules or {}
UPF.Settings = UPF.Settings or {}
UPF.State = UPF.State or {}
UPF.Connections = UPF.Connections or {}

-- =========================
-- CONFIG
-- =========================

local MAX_DOWNLOAD_RETRIES = 4
local INITIAL_BACKOFF = 0.25
local BACKOFF_MULT = 2

-- =========================
-- LOGS
-- =========================

local function info(...)
    print("[UPF Loader]", ...)
end

local function warn_(...)
    warn("[UPF Loader]", ...)
end

-- =========================
-- HTTP RETRY
-- =========================

local function http_get_with_retry(url)
    local backoff = INITIAL_BACKOFF

    for attempt = 1, MAX_DOWNLOAD_RETRIES do
        local ok, res = pcall(function()
            return game:HttpGet(url, true)
        end)

        if ok and res and #res > 0 then
            return true, res
        end

        warn_("Download failed:", attempt, url)
        task.wait(backoff)
        backoff *= BACKOFF_MULT
    end

    return false, nil
end

-- =========================
-- PARSE HEADER
-- =========================

local function parse_header(src)
    if not src then return nil end

    local block = src:match("UPF_MODULE%s*=%s*{(.-)}")
    if not block then return nil end

    local name = block:match('name%s*=%s*"(.-)"') or block:match("name%s*=%s*'(.-)'")
    local requires = {}

    local reqBlock = block:match("requires%s*=%s*{(.-)}")
    if reqBlock then
        for r in reqBlock:gmatch('"(.-)"') do table.insert(requires, r) end
        for r in reqBlock:gmatch("'(.-)'") do table.insert(requires, r) end
    end

    return name and { name = name, requires = requires } or nil
end

-- =========================
-- FETCH MODULES
-- =========================

local modules_data = {}
local name_to_file = {}

for _, file in ipairs(MODULES) do
    local url = BASE_URL .. file
    info("Fetching", file)

    local ok, src = http_get_with_retry(url)
    if not ok then
        error("Failed to fetch: " .. file)
    end

    local header = parse_header(src)

    modules_data[file] = {
        source = src,
        header = header
    }

    if header then
        name_to_file[header.name] = file
    end
end

-- =========================
-- BUILD GRAPH
-- =========================

local graph = {}

for file, data in pairs(modules_data) do
    local name = data.header and data.header.name or file
    graph[name] = graph[name] or { file = file, deps = {} }
end

for file, data in pairs(modules_data) do
    if data.header and data.header.requires then
        local name = data.header.name

        for _, dep in ipairs(data.header.requires) do
            table.insert(graph[name].deps, dep)
        end
    end
end

-- =========================
-- TOPO SORT
-- =========================

local visited, temp = {}, {}
local order = {}

local function visit(n)
    if temp[n] then
        error("Cycle detected: " .. n)
    end

    if not visited[n] then
        temp[n] = true

        for _, d in ipairs(graph[n].deps) do
            if graph[d] then
                visit(d)
            end
        end

        temp[n] = nil
        visited[n] = true
        table.insert(order, n)
    end
end

for name in pairs(graph) do
    visit(name)
end

-- =========================
-- RESOLVE FILE ORDER
-- =========================

local final_order = {}
local added = {}

for _, name in ipairs(order) do
    local file = graph[name].file or name_to_file[name]
    if file and not added[file] then
        table.insert(final_order, file)
        added[file] = true
    end
end

for _, file in ipairs(MODULES) do
    if not added[file] then
        table.insert(final_order, file)
    end
end

-- =========================
-- LOAD MODULES
-- =========================

info("Load order:")

for i, f in ipairs(final_order) do
    info(i, f)
end

for _, file in ipairs(final_order) do
    if UPF.Modules[file] then
        info("Skipping:", file)
        continue
    end

    local data = modules_data[file]

    local fn, err = loadstring(data.source)
    if not fn then
        error("Compile error in " .. file .. ": " .. tostring(err))
    end

    local ok, runErr = pcall(fn)
    if not ok then
        error("Runtime error in " .. file .. ": " .. tostring(runErr))
    end

    UPF.Modules[file] = true
    info("✅ Loaded:", file)
end

info("🛡 UPF loader finished")
