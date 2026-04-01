-- installer.lua
-- Instala loader_v4.lua en Delta Autoexecute

local TARGET_DIR = "/storage/emulated/0/Delta/Autoexecute"
local TARGET_FILE = TARGET_DIR .. "loader.lua"

local SOURCE_URL = "https://raw.githubusercontent.com/marcouriel776-crypto/script_roblox_proteccion_experimental/main/loader.lua/"

local function safe_pcall(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok, res
end

local function file_exists(path)
    if type(readfile) ~= "function" then
        return false
    end
    local ok = pcall(readfile, path)
    return ok
end

local function ensure_write_access()
    if type(writefile) ~= "function" then
        return false, "writefile not available"
    end

    local test_file = TARGET_DIR .. "_upf_write_test.tmp"
    local ok, err = pcall(writefile, test_file, "test")
    if not ok then
        return false, err
    end

    pcall(function()
        if type(delfile) == "function" then
            delfile(test_file)
        end
    end)

    return true
end

local function autoinstall()
    if file_exists(TARGET_FILE) then
        print("[loader] ✅ Ya instalado en " .. TARGET_FILE)
        return
    end

    print("[loader] Intentando autoinstalar...")

    local folder_ok = true
    if type(listfiles) == "function" then
        local ok = pcall(function()
            listfiles(TARGET_DIR)
        end)
        folder_ok = ok
    end

    if not folder_ok then
        warn("[loader] ❌ La carpeta no existe o no es accesible: " .. TARGET_DIR)
        warn("[loader] Crea la carpeta manualmente o verifica la ruta correcta.")
        return
    end

    local can_write, write_err = ensure_write_access()
    if not can_write then
        warn("[loader] ❌ No se puede escribir en la carpeta. Error: " .. tostring(write_err))
        warn("[loader] Asegúrate de que Delta tenga permisos de almacenamiento.")
        return
    end
    print("[loader] ✅ Permisos de escritura OK")

    local source
    local download_ok, content = safe_pcall(game.HttpGet, game, SOURCE_URL)
    if download_ok and content and #content > 0 then
        source = content
        print("[loader] ✅ Script descargado desde GitHub")
    end

    if not source then
        warn("[loader] ❌ No se pudo descargar el loader.")
        return
    end

    local write_ok, write_err2 = pcall(writefile, TARGET_FILE, source)
    if write_ok then
        print("[loader] ✅ Autoinstalado correctamente en " .. TARGET_FILE)
        print("[loader] 🚀 A partir de ahora se ejecutará solo al inyectar Delta.")
    else
        warn("[loader] ❌ Error al escribir: " .. tostring(write_err2))
    end
end

autoinstall()
