-- loader_v4.lua
-- Advanced UPF loader v4
-- Features:
--  * Robust downloads with retries/backoff
--  * Optional dependency parsing via UPF_MODULE = { name="...", requires={"..."} } header in modules
--  * Topological sort of modules by name when headers exist
--  * Fallback to explicit MODULES order when no headers or on parse failure
--  * Detailed logging
-- Usage:
--  Replace your old loader with this, edit MODULES list below (file names in repo), then:
--  loadstring(game:HttpGet("https://raw.githubusercontent.com/<your>/script_roblox_proteccion_experimental/main/loader_v4.lua"))()

local BASE_URL = "https://raw.githubusercontent.com/marcouriel776-crypto/script_roblox_proteccion_experimental/main/"

-- EDIT: list all module filenames you want the loader to fetch.
local MODULES = {
    "module_settings.lua",
    "module_utils.lua",
    "module_upf_api.lua",
    "module_core.lua",

    "module_protection.lua",
    "module_smart.lua",
    "module_recovery.lua",
    "module_audio.lua",
    "module_antifreeze.lua",
    "module_resilience.lua",
    "module_modal_detector.lua",
    "module_smart_protection.lua", -- new
    "module_ui.lua",
    "module_ui_theme.lua",
    "module_ui_logs.lua",
}

-- Settings
local MAX_DOWNLOAD_RETRIES = 4
local INITIAL_BACKOFF = 0.25
local BACKOFF_MULT = 2
local TIMEOUT = 10 -- seconds for each fetch (best-effort)

-- Helper logging
local function info(...) print("[loader_v4] ", ...) end
local function warn_(...) warn("[loader_v4] ", ...) end

-- robust http get with retries
local function http_get_with_retry(url)
    local backoff = INITIAL_BACKOFF
    for attempt = 1, MAX_DOWNLOAD_RETRIES do
        local ok, res = pcall(function()
            return game:HttpGet(url, true)
        end)
        if ok and res and #res > 0 then
            return true, res
        end
        warn_("download failed attempt", attempt, "for", url)
        task.wait(backoff)
        backoff = backoff * BACKOFF_MULT
    end
    return false, nil
end

-- parse UPF_MODULE header (very small parser)
local function parse_upf_module_header(source)
    if not source then return nil end
    -- find block like: UPF_MODULE = { ... }
    local header = source:match("UPF_MODULE%s*=%s*{(.-)}")
    if not header then return nil end
    local name = header:match('name%s*=%s*"(.-)"') or header:match("name%s*=%s*'(.-)'")
    local requires_block = header:match("requires%s*=%s*{(.-)}")
    local requires = {}
    if requires_block then
        for req in requires_block:gmatch('"(.-)"') do table.insert(requires, req) end
        for req in requires_block:gmatch("'(.-)'") do table.insert(requires, req) end
    end
    if not name then return nil end
    return { name = name, requires = requires }
end

-- Build a map of module filename -> { source, header }
local modules_data = {}

-- Step 1: download all modules (but do not run)
for _,fname in ipairs(MODULES) do
    local url = BASE_URL .. fname
    info("Fetching", fname)
    local ok, src = http_get_with_retry(url)
    if not ok then
        warn_("Failed to download module:", fname, " url:", url)
        error("Loader aborted: cannot fetch " .. fname)
    end
    modules_data[fname] = { source = src, header = parse_upf_module_header(src) }
    info("Fetched:", fname, modules_data[fname].header and ("module="..modules_data[fname].header.name) or "no header")
end

-- Step 2: if at least two modules have headers, attempt dependency resolution
local name_to_file = {}
local graph = {}
local have_headers = 0
for fname,data in pairs(modules_data) do
    if data.header and data.header.name then
        have_headers = have_headers + 1
        name_to_file[data.header.name] = fname
    end
end

local load_order_files = {}

local function topo_sort_from_headers()
    -- build dependency graph keyed by module name
    for fname,data in pairs(modules_data) do
        local header = data.header
        local nodeName = header and header.name or fname -- fallback name
        graph[nodeName] = graph[nodeName] or { deps = {}, file = fname }
    end
    for fname,data in pairs(modules_data) do
        local header = data.header
        local nodeName = header and header.name or fname
        if header and header.requires and #header.requires > 0 then
            for _,dep in ipairs(header.requires) do
                graph[nodeName] = graph[nodeName] or { deps = {}, file = fname }
                graph[dep] = graph[dep] or { deps = {}, file = name_to_file[dep] or dep }
                table.insert(graph[nodeName].deps, dep)
            end
        end
    end

    -- perform DFS topological sort
    local visited = {}
    local temp = {}
    local order = {}
    local function visit(n)
        if temp[n] then
            error("Dependency cycle detected at module: " .. tostring(n))
        end
        if not visited[n] then
            temp[n] = true
            local node = graph[n]
            if node and node.deps then
                for _,d in ipairs(node.deps) do
                    if graph[d] then visit(d) end
                end
            end
            visited[n] = true
            temp[n] = nil
            table.insert(order, n)
        end
    end

    for name,_ in pairs(graph) do
        if not visited[name] then
            visit(name)
        end
    end

    -- convert order of names to filenames (dedupe)
    local added = {}
    for i = 1, #order do
        local nm = order[i]
        local file = graph[nm] and graph[nm].file or name_to_file[nm] or nm
        if file and not added[file] then
            table.insert(load_order_files, file)
            added[file] = true
        end
    end

    -- ensure any files not in graph are appended (fallback)
    for fname,_ in pairs(modules_data) do
        if not added[fname] then
            table.insert(load_order_files, fname)
            added[fname] = true
        end
    end
end

local ok, err = pcall(function()
    if have_headers >= 2 then
        topo_sort_from_headers()
    else
        -- fallback: use MODULES order
        for _,f in ipairs(MODULES) do table.insert(load_order_files, f) end
    end
end)
if not ok then
    warn_("Dependency resolution failed:", err)
    -- fallback to original order
    load_order_files = {}
    for _,f in ipairs(MODULES) do table.insert(load_order_files, f) end
end

info("Final load order:")
for i,f in ipairs(load_order_files) do info(i, f) end

-- Step 3: load modules in order (loadstring + pcall)
for _,fname in ipairs(load_order_files) do
    local data = modules_data[fname]
    if not data or not data.source then
        warn_("Missing source for", fname)
        error("Aborting - missing source for " .. tostring(fname))
    end
    info("Loading", fname)
    local fn, loadErr = loadstring(data.source)
    if not fn then
        warn_("Error compiling", fname, loadErr)
        error("Aborting - compile error in " .. fname)
    end
    local ok, runErr = pcall(fn)
    if not ok then
        warn_("Error running", fname, runErr)
        error("Aborting - runtime error in " .. fname)
    end
    info("✅ Loaded module:", fname)
end

info("🛡 loader_v4 finished successfully")