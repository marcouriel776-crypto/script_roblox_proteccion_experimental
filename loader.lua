-- loader_v4.lua
-- Advanced UPF loader v4
-- Carga módulos en orden seguro, con reintentos de descarga.
-- Sin auto-rejoin. Sin teleports. Sin autoinstalación.

local BASE_URL = "https://raw.githubusercontent.com/marcouriel776-crypto/script_roblox_proteccion_experimental/main/"

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
    "module_smart_protection.lua",
    "module_ui.lua",
    "module_ui_theme.lua",
    "module_ui_logs.lua",
}

getgenv().UPF = getgenv().UPF or {}
local UPF = getgenv().UPF

UPF.Enabled = true
UPF.Modules = UPF.Modules or {}
UPF.Settings = UPF.Settings or {}
UPF.State = UPF.State or {}
UPF.Connections = UPF.Connections or {}

local MAX_DOWNLOAD_RETRIES = 4
local INITIAL_BACKOFF = 0.25
local BACKOFF_MULT = 2

local function info(...)
    print("[loader_v4]", ...)
end

local function warn_(...)
    warn("[loader_v4]", ...)
end

local function http_get_with_retry(url)
    local backoff = INITIAL_BACKOFF

    for attempt = 1, MAX_DOWNLOAD_RETRIES do
        local ok, res = pcall(function()
            return game:HttpGet(url, true)
        end)

        if ok and res and #res > 0 then
            return true, res
        end

        warn_(
            "download failed attempt",
            attempt,
            "for",
            url
        )

        task.wait(backoff)
        backoff = backoff * BACKOFF_MULT
    end

    return false, nil
end

local function parse_upf_module_header(source)
    if not source then
        return nil
    end

    local header = source:match("UPF_MODULE%s*=%s*{(.-)}")
    if not header then
        return nil
    end

    local name = header:match('name%s*=%s*"(.-)"') or header:match("name%s*=%s*'(.-)'")
    local requires_block = header:match("requires%s*=%s*{(.-)}")
    local requires = {}

    if requires_block then
        for req in requires_block:gmatch('"(.-)"') do
            table.insert(requires, req)
        end
        for req in requires_block:gmatch("'(.-)'") do
            table.insert(requires, req)
        end
    end

    if not name then
        return nil
    end

    return {
        name = name,
        requires = requires,
    }
end

local modules_data = {}

for _, fname in ipairs(MODULES) do
    local url = BASE_URL .. fname
    info("Fetching", fname)

    local ok, src = http_get_with_retry(url)
    if not ok then
        warn_("Failed to download module:", fname, "url:", url)
        error("Loader aborted: cannot fetch " .. fname)
    end

    modules_data[fname] = {
        source = src,
        header = parse_upf_module_header(src),
    }

    if modules_data[fname].header then
        info("Fetched:", fname, "module=" .. modules_data[fname].header.name)
    else
        info("Fetched:", fname, "no header")
    end
end

local name_to_file = {}
local graph = {}
local have_headers = 0

for fname, data in pairs(modules_data) do
    if data.header and data.header.name then
        have_headers = have_headers + 1
        name_to_file[data.header.name] = fname
    end
end

local load_order_files = {}

local function topo_sort_from_headers()
    for fname, data in pairs(modules_data) do
        local header = data.header
        local node_name = header and header.name or fname
        graph[node_name] = graph[node_name] or { deps = {}, file = fname }
    end

    for fname, data in pairs(modules_data) do
        local header = data.header
        local node_name = header and header.name or fname

        if header and header.requires and #header.requires > 0 then
            for _, dep in ipairs(header.requires) do
                graph[node_name] = graph[node_name] or { deps = {}, file = fname }
                graph[dep] = graph[dep] or { deps = {}, file = name_to_file[dep] or dep }
                table.insert(graph[node_name].deps, dep)
            end
        end
    end

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
                for _, d in ipairs(node.deps) do
                    if graph[d] then
                        visit(d)
                    end
                end
            end

            visited[n] = true
            temp[n] = nil
            table.insert(order, n)
        end
    end

    for name, _ in pairs(graph) do
        if not visited[name] then
            visit(name)
        end
    end

    local added = {}
    for i = 1, #order do
        local nm = order[i]
        local file = graph[nm] and graph[nm].file or name_to_file[nm] or nm
        if file and not added[file] then
            table.insert(load_order_files, file)
            added[file] = true
        end
    end

    for fname, _ in pairs(modules_data) do
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
        for _, f in ipairs(MODULES) do
            table.insert(load_order_files, f)
        end
    end
end)

if not ok then
    warn_("Dependency resolution failed:", err)
    load_order_files = {}
    for _, f in ipairs(MODULES) do
        table.insert(load_order_files, f)
    end
end

info("Final load order:")
for i, f in ipairs(load_order_files) do
    info(i, f)
end

for _, fname in ipairs(load_order_files) do
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

    local success, runErr = pcall(fn)
    if not success then
        warn_("Error running", fname, runErr)
        error("Aborting - runtime error in " .. fname)
    end

    info("✅ Loaded module:", fname)
end

info("🛡 loader_v4 finished successfully")