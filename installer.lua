-- installer.lua (FIXED PRO)

local TARGET_DIR = "/storage/emulated/0/Delta/Autoexecute/"
local TARGET_FILE = TARGET_DIR .. "loader.lua"

local SOURCE_URL = "https://raw.githubusercontent.com/marcouriel776-crypto/script_roblox_proteccion_experimental/main/loader_v4.lua"

local function file_exists(path)
    if type(readfile) ~= "function" then return false end
    return pcall(readfile, path)
end

local function ensure_write_access()
    if type(writefile) ~= "function" then
        return false, "writefile not available"
    end

    local test_file = TARGET_DIR .. "_test.tmp"
    local ok = pcall(writefile, test_file, "test")

    if ok and delfile then
        pcall(delfile, test_file)
    end

    return ok
end

local function autoinstall()

    if makefolder then
        pcall(function()
            makefolder(TARGET_DIR)
        end)
    end

    print("[installer] Installing...")

    local can_write, err = ensure_write_access()
    if not can_write then
        warn("[installer] ❌ No write access:", err)
        return
    end

    local ok, src = pcall(game.HttpGet, game, SOURCE_URL)
    if not ok or not src then
        warn("[installer] ❌ Download failed")
        return
    end

    local success, err2 = pcall(writefile, TARGET_FILE, src)
    if success then
        print("[installer] ✅ Installed at:", TARGET_FILE)
    else
        warn("[installer] ❌ Write failed:", err2)
    end
end

autoinstall()
