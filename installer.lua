-- installer.lua (GOD MODE)

local TARGET_DIR = "/storage/emulated/0/Delta/Autoexecute/"
local TARGET_FILE = TARGET_DIR .. "upf_loader.lua"

local SOURCE_URL = "https://raw.githubusercontent.com/marcouriel776-crypto/script_roblox_proteccion_experimental/main/loader.lua"
local VERSION_URL = "https://raw.githubusercontent.com/marcouriel776-crypto/script_roblox_proteccion_experimental/main/version.txt"

local CURRENT_VERSION = "1.0.0"

-- =========================
-- UTILS
-- =========================

local function log(...)
    print("[UPF INSTALLER]", ...)
end

local function warn_(...)
    warn("[UPF INSTALLER]", ...)
end

local function safe_http(url)
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)

    if ok and res and #res > 0 then
        return res
    end

    return nil
end

local function file_exists(path)
    if type(readfile) ~= "function" then return false end
    return pcall(readfile, path)
end

local function write_safe(path, content)
    if type(writefile) ~= "function" then
        return false, "writefile not supported"
    end

    local ok, err = pcall(writefile, path, content)
    return ok, err
end

-- =========================
-- VERSION CHECK
-- =========================

local function needs_update()
    local remote_version = safe_http(VERSION_URL)

    if not remote_version then
        warn_("No se pudo verificar versión (offline mode)")
        return true
    end

    remote_version = remote_version:gsub("%s+", "")

    if remote_version ~= CURRENT_VERSION then
        log("Nueva versión detectada:", remote_version)
        return true
    end

    log("Ya tienes la última versión")
    return false
end

-- =========================
-- INSTALL / UPDATE
-- =========================

local function install()

    -- crear carpeta si no existe
    if makefolder then
        pcall(function()
            makefolder(TARGET_DIR)
        end)
    end

    log("Verificando instalación...")

    local update = needs_update()

    if file_exists(TARGET_FILE) and not update then
        log("Loader ya instalado y actualizado")
        return
    end

    log("Descargando loader...")

    local source = safe_http(SOURCE_URL)

    if not source then
        warn_("❌ No se pudo descargar loader")
        return
    end

    -- validación básica
    if not source:find("UPF") then
        warn_("❌ Archivo corrupto o inválido")
        return
    end

    local ok, err = write_safe(TARGET_FILE, source)

    if ok then
        log("✅ Instalación completa en:", TARGET_FILE)
    else
        warn_("❌ Error al escribir:", err)
    end
end

-- =========================
-- AUTOEXEC (MULTI-EXECUTOR)
-- =========================

local function setup_autoexec()

    local code = 'loadstring(readfile("'..TARGET_FILE..'"))()'

    if syn and syn.queue_on_teleport then
        syn.queue_on_teleport(code)
        log("Autoexec configurado (Synapse)")
    elseif queue_on_teleport then
        queue_on_teleport(code)
        log("Autoexec configurado (KRNL/Fluxus)")
    else
        warn_("Autoexec no soportado en este executor")
    end

end

-- =========================
-- RUN
-- =========================

install()
setup_autoexec()

log("🚀 UPF INSTALLER GOD MODE READY")
