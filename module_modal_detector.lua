-- module_modal_detector.lua (mejorado - heurísticas para reducir falsos positivos)
-- Detecta modales/diálogos (p. ej. "game paused / check your connection")
-- NO destruye GUIs. Actúa sólo con medidas de recuperación seguras.
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local UPF = _G.UPF
if not UPF then
    warn("modal_detector: UPF no inicializado")
    return
end

-- CONFIG
local SCAN_INTERVAL = 0.8 -- segundos entre escaneos
local MIN_TEXT_LENGTH = 10 -- textos mas cortos se ignoran (probablemente no modal)
local MIN_VIEWPORT_COVERAGE = 0.30 -- ancestro debe cubrir al menos 30% del viewport para considerarse modal
local LAST_SCAN = 0

-- patrones para detectar (se mantienen, pero ahora con heurísticas)
local DETECTION_PATTERNS = {
    "paus",                -- pausa/pausado (es)
    "conexi",              -- conexión (es)
    "connection",          -- connection (en)
    "connection lost",
    "check your connection",
    "you have been disconnected",
    "game paused",
    "connection failed",
    "network",
}

-- BLACKLIST de substrings en path o nombres de componentes que queremos IGNORAR (chat, ejecutores, etc)
local PATH_BLACKLIST = {
    "ExperienceChat",
    "TextMessage",
    "Executor",
    "InfiniteYield",
    "Exploit",
    "Overlay.Code", -- muchos ejecutores meten su overlay con "Overlay.Code"
    "AppLayout", -- a veces experiencia-chat
}

-- util: comprueba si una cadena contiene alguna de las blacklist
local function pathIsBlacklisted(path)
    if not path or type(path) ~= "string" then return false end
    local lower = string.lower(path)
    for _, part in ipairs(PATH_BLACKLIST) do
        if string.find(lower, string.lower(part), 1, true) then
            return true
        end
    end
    return false
end

-- util: matching simple de patrones
local function matchesPatterns(s)
    if not s or type(s) ~= "string" then return false end
    local lower = string.lower(s)
    for _, pat in ipairs(DETECTION_PATTERNS) do
        if string.find(lower, pat, 1, true) then
            return true
        end
    end
    return false
end

-- obtiene el ancestro "modal candidate": sube desde el objeto hasta encontrar Frame/ViewportFrame/ScreenGui
local function findModalAncestor(obj)
    local cur = obj
    local candidate = nil
    while cur do
        if cur:IsA("ScreenGui") then
            candidate = cur
            break
        end
        if cur:IsA("Frame") or cur:IsA("ImageLabel") or cur:IsA("ImageButton") or cur:IsA("ViewportFrame") then
            candidate = cur
        end
        cur = cur.Parent
    end
    return candidate
end

-- calcula porcentaje aproximado que ocupa el guiObject respecto al viewport (0..1), usa Workspace.CurrentCamera.ViewportSize
local function viewportCoverage(guiObject)
    local ok, cam = pcall(function() return Workspace.CurrentCamera end)
    if not ok or not cam then return 0 end
    local ok2, vs = pcall(function() return cam.ViewportSize end)
    if not ok2 or not vs then return 0 end

    local absSize
    local ok3, s = pcall(function() return guiObject.AbsoluteSize end)
    if not ok3 then return 0 end
    absSize = s

    local area = absSize.X * absSize.Y
    local screenArea = vs.X * vs.Y
    if screenArea <= 0 then return 0 end
    return area / screenArea
end

-- decide si un objeto text->ancestro parece un modal real
local function isLikelyModal(textObj)
    if not textObj or not textObj.Parent then return false end
    -- ignore if path contains blacklisted phrase
    local ok, fullPath = pcall(function() return textObj:GetFullName() end)
    if ok and pathIsBlacklisted(fullPath) then
        return false, "blacklisted_path"
    end

    -- texto muy corto o vacío → ignorar
    local ok2, txt = pcall(function() return textObj.Text end)
    if not ok2 or type(txt) ~= "string" then return false, "no_text"
    end
    local stripped = string.gsub(txt, "%s+", "")
    if #stripped < MIN_TEXT_LENGTH then
        return false, "short_text"
    end

    -- si contiene solo tags html-like sin texto claro, ignorar
    local justTags = string.match(txt, "^%s*<[%w%p]+>.*</[%w%p]+>%s*$")
    if justTags and #stripped < 30 then
        return false, "only_tags"
    end

    -- encuentra ancestro candidato
    local anc = findModalAncestor(textObj)
    if not anc then
        return false, "no_ancestor"
    end

    -- si ancestor es ScreenGui → medir coverage de sus hijos directos (a menudo executor overlays son ScreenGui small)
    local coverage = viewportCoverage(anc)
    if coverage >= MIN_VIEWPORT_COVERAGE then
        -- además asegurar que está visible y no totalmente transparente
        if anc.Visible == true then
            -- BackgroundTransparency check: algunos elementos no tienen BackgroundTransparency property
            local bgTrans = 1
            pcall(function()
                if anc.BackgroundTransparency then bgTrans = anc.BackgroundTransparency end
            end)
            if (bgTrans or 1) < 0.95 then
                return true, "big_anch_cover"
            else
                -- si cubre mucho pero es transparente, aun así tratarlo como modal
                return true, "big_anc_transparent"
            end
        end
    end

    -- si ancestor es Frame y tiene BackgroundTransparency baja y es visible -> considerarlo
    local ok3, bgT = pcall(function() return anc.BackgroundTransparency end)
    if ok3 and anc.Visible and (type(bgT) == "number" and bgT < 0.9) then
        return true, "frame_bg"
    end

    -- Por defecto: no es modal
    return false, "heuristics_fail"
end

-- escaneo recursivo del gui (con protección)
local function scanGui(root)
    if not root then return nil end
    local found = nil
    local function recurse(obj)
        if found then return end
        -- check types that hold text
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            local ok, txt = pcall(function() return obj.Text end)
            if ok and txt and matchesPatterns(txt) then
                local likely, reason = isLikelyModal(obj)
                if likely then
                    found = { object = obj, text = txt, path = (pcall(function() return obj:GetFullName() end) and obj:GetFullName() or "unknown"), reason = reason }
                    return
                else
                    -- opcional: debug (comentar si ruidoso)
                    -- warn("[modal_detector] Ignored candidate:", txt, "reason:", reason, "path:", (pcall(function() return obj:GetFullName() end) and obj:GetFullName() or "unknown"))
                end
            end
        end
        for _, c in ipairs(obj:GetChildren()) do
            recurse(c)
            if found then return end
        end
    end
    recurse(root)
    return found
end

-- escanea CoreGui y PlayerGui
local function scanAllGuis()
    local ok, res = pcall(function()
        local cg = game:GetService("CoreGui")
        local r = scanGui(cg)
        if r then return r end
        local plrg = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
        if plrg then
            return scanGui(plrg)
        end
        return nil
    end)
    if ok then return res end
    return nil
end

-- acción segura (no destructiva) cuando detectamos modal
local function onModalDetected(info)
    if not info then return end
    UPF.State.ModalDetected = true
    UPF.State.ModalInfo = { text = info.text, path = info.path, time = tick(), reason = info.reason }

    warn("[modal_detector] Modal detectado:", info.text, "path:", info.path, "reason:", info.reason)

    -- medidas seguras: activar protección, intentar regresar a safepoint, guardar estado
    pcall(function()
        if type(UPF.ToggleProtection) == "function" then UPF:ToggleProtection(true) end
    end)

    pcall(function()
        if type(UPF.ReturnToSafePoint) == "function" then UPF:ReturnToSafePoint() end
    end)

    pcall(function()
        if type(UPF.SaveSettings) == "function" then UPF:SaveSettings() end
    end)
end

local function clearModalFlag()
    if UPF.State.ModalDetected then
        UPF.State.ModalDetected = false
        UPF.State.ModalInfo = {}
        print("[modal_detector] Modal cleared")
    end
end

-- registrar conexión (reemplaza si ya existe)
UPF.Connections = UPF.Connections or {}
if UPF.Connections.ModalDetector and typeof(UPF.Connections.ModalDetector) == "RBXScriptConnection" then
    pcall(function() UPF.Connections.ModalDetector:Disconnect() end)
    UPF.Connections.ModalDetector = nil
end

UPF.Connections.ModalDetector = RunService.Heartbeat:Connect(function()
    if tick() - LAST_SCAN < SCAN_INTERVAL then return end
    LAST_SCAN = tick()

    local found = scanAllGuis()
    if found then
        local last = UPF.State.ModalInfo
        if not last or last.text ~= found.text or tick() - (last.time or 0) > 5 then
            onModalDetected(found)
        end
    else
        clearModalFlag()
    end
end)

print("✅ module_modal_detector (heuristics) loaded")