-- module_modal_detector.lua
-- Detecta modales/diálogos (p. ej. "game paused / check your connection")
-- y activa recuperación segura usando la API pública UPF.
-- No borra ni oculta GUIs del sistema.

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UPF = _G.UPF
if not UPF then
    warn("modal_detector: UPF no inicializado")
    return
end

-- Configuración
local SCAN_INTERVAL = 0.7 -- segundos entre escaneos
local LAST_SCAN = 0

UPF.State = UPF.State or {}
UPF.State.ModalDetected = UPF.State.ModalDetected or false
UPF.State.ModalInfo = UPF.State.ModalInfo or {}

-- Patrones a buscar (puedes ampliarlos/ajustarlos)
local DETECTION_PATTERNS = {
    "paus",                -- pausa/pausado (es)
    "conexi",              -- conexión (es)
    "connection",          -- connection (en)
    "connection lost",
    "check your connection",
    "you have been disconnected",
    "game paused",
    "connection failed",
    "network"
}

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

local function scanGui(root)
    if not root then return nil end
    local found = nil
    local function recurse(obj)
        if found then return end
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            local ok, txt = pcall(function() return obj.Text end)
            if ok and matchesPatterns(txt) then
                found = { object = obj, text = txt, path = obj:GetFullName() }
                return
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

local function onModalDetected(info)
    if not info then return end
    UPF.State.ModalDetected = true
    UPF.State.ModalInfo = { text = info.text, path = info.path, time = tick() }

    warn("[modal_detector] Modal detectado:", info.text, "path:", info.path)

    -- Acciones de recuperación seguras (no destructivas)
    pcall(function()
        if type(UPF.ToggleProtection) == "function" then
            UPF:ToggleProtection(true)
        end
    end)

    pcall(function()
        if type(UPF.ReturnToSafePoint) == "function" then
            UPF:ReturnToSafePoint()
        end
    end)

    pcall(function()
        if type(UPF.SaveSettings) == "function" then
            UPF:SaveSettings()
        end
    end)
end

local function clearModalFlag()
    if UPF.State.ModalDetected then
        UPF.State.ModalDetected = false
        UPF.State.ModalInfo = {}
        print("[modal_detector] Modal cleared")
    end
end

-- Registrar conexión en UPF.Connections para cleanup
UPF.Connections = UPF.Connections or {}
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

print("✅ module_modal_detector loaded (monitor only)")