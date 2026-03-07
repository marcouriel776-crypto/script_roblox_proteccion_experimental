-- module_resilience.lua
-- Resilience module: Anti-Kick (detection), Auto-Reconnect, Smart Recovery + UI notifications
-- No borra GUIs del sistema. Usa UPF público para acciones (ReturnToSafePoint, SaveSettings, ToggleProtection).
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local UPF = _G.UPF
if not UPF then
    warn("module_resilience: UPF no inicializado, esperando...")
    -- no abortamos del todo: intentamos esperar a core
    repeat task.wait(0.2) until _G.UPF or tick() - (tick()) > 5
    UPF = _G.UPF
    if not UPF then
        warn("module_resilience: UPF no disponible, saliendo.")
        return
    end
end

-- CONFIG
local SCAN_INTERVAL = 0.8
local KICK_DETECTION_PATTERNS = {
    "you have been kicked",
    "you were removed",
    "you have been disconnected",
    "connection lost",
    "check your connection",
    "you have been kicked",
    "you were kicked",
    "you were removed from the game",
    "disconnected",
    "network error",
}
local RECONNECT_COOLDOWN = 8         -- segundos entre intentos
local MAX_RECONNECT_ATTEMPTS = 4
local SMART_RECOVERY_COOLDOWN = 3    -- segundos entre recuperaciones automáticas
local SAFE_Y_HIGH = 2000
local SAFE_Y_LOW = -500
local STUCK_TIME = 3                 -- segundos sin movimiento para considerar "stuck"
local FLING_VELOCITY_THRESHOLD = 150 -- m/s detect fling
local MIN_MODAL_TEXT_LEN = 8

-- Estado
UPF.State = UPF.State or {}
UPF.State.Resilience = UPF.State.Resilience or {}
local state = UPF.State.Resilience
state.lastModal = state.lastModal or {}
state.reconnectAttempts = 0
state.lastReconnect = 0
state.lastRecovery = 0
state.lastSafeCFrame = state.lastSafeCFrame or nil
state.lastPos = state.lastPos or nil
state.lastMoveTick = state.lastMoveTick or tick()
state.safeRecorded = state.safeRecorded or false

-- utilidades de texto
local function lower(s) return (type(s)=="string") and string.lower(s) or "" end
local function containsAny(s, list)
    s = lower(s or "")
    for _, p in ipairs(list) do
        if string.find(s, lower(p), 1, true) then return true end
    end
    return false
end

-- heurísticas: reusar scanGui idea (ligera) para detectar textos "kick / disconnect" en CoreGui / PlayerGui
local function isCandidateText(obj)
    if not obj then return false, nil end
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return false, nil end
    local ok, txt = pcall(function() return obj.Text end)
    if not ok or type(txt) ~= "string" then return false, nil end
    if #txt < MIN_MODAL_TEXT_LEN then return false, nil end
    return true, txt
end

local function findKickModal(root)
    if not root then return nil end
    local found = nil
    local function recurse(o)
        if found then return end
        local isText, txt = isCandidateText(o)
        if isText and containsAny(txt, KICK_DETECTION_PATTERNS) then
            -- ensure some visibility / size heuristics to avoid chat messages
            local ok, vis = pcall(function() return o.Visible end)
            if ok and vis == true then
                -- try ancestor area coverage (best-effort)
                local anc = o
                local depth = 0
                while anc and depth < 8 do
                    if anc:IsA("ScreenGui") or anc:IsA("Frame") or anc:IsA("ImageLabel") then break end
                    anc = anc.Parent; depth = depth + 1
                end
                local path = pcall(function() return o:GetFullName() end) and o:GetFullName() or "unknown"
                found = {object=o, text=txt, path=path}
                return
            end
        end
        for _,c in ipairs(o:GetChildren()) do
            recurse(c)
            if found then return end
        end
    end
    recurse(root)
    return found
end

local function scanCoreAndPlayerGui()
    local ok, found = pcall(function()
        local cg = game:GetService("CoreGui")
        local r = findKickModal(cg)
        if r then return r end
        local pg = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
        if pg then return findKickModal(pg) end
        return nil
    end)
    if ok then return found end
    return nil
end

-- UI Notification (si UPF.UI disponible)
local function ensureNotificationUI()
    if UPF.UI and UPF.UI.ScreenGui then
        local sg = UPF.UI.ScreenGui
        if sg:FindFirstChild("ResilienceNotify") then return sg.ResilienceNotify end
        local n = Instance.new("Frame")
        n.Name = "ResilienceNotify"
        n.Size = UDim2.fromOffset(380,80)
        n.Position = UDim2.fromScale(0.5, 0.05)
        n.AnchorPoint = Vector2.new(0.5,0)
        n.BackgroundColor3 = Color3.fromRGB(20,20,30)
        n.Visible = false
        n.Parent = sg
        Instance.new("UICorner", n).CornerRadius = UDim.new(0,10)
        local label = Instance.new("TextLabel", n)
        label.Name = "Label"
        label.Size = UDim2.fromScale(1,0.6)
        label.Position = UDim2.fromScale(0,0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextScaled = true
        label.TextColor3 = Color3.fromRGB(255,210,120)
        label.Text = ""
        local btnFrame = Instance.new("Frame", n)
        btnFrame.Size = UDim2.fromScale(1, 0.4)
        btnFrame.Position = UDim2.fromScale(0,0.6)
        btnFrame.BackgroundTransparency = 1
        local recBtn = Instance.new("TextButton", btnFrame)
        recBtn.Size = UDim2.fromScale(0.46, 0.85)
        recBtn.Position = UDim2.fromScale(0.02, 0.08)
        recBtn.Text = "Attempt Recovery"
        recBtn.Font = Enum.Font.GothamBold
        recBtn.TextScaled = true
        recBtn.BackgroundColor3 = Color3.fromRGB(60,160,90)
        Instance.new("UICorner", recBtn).CornerRadius = UDim.new(0,8)
        local rejoinBtn = Instance.new("TextButton", btnFrame)
        rejoinBtn.Size = UDim2.fromScale(0.46, 0.85)
        rejoinBtn.Position = UDim2.fromScale(0.52, 0.08)
        rejoinBtn.Text = "Reconnect"
        rejoinBtn.Font = Enum.Font.GothamBold
        rejoinBtn.TextScaled = true
        rejoinBtn.BackgroundColor3 = Color3.fromRGB(70,130,220)
        Instance.new("UICorner", rejoinBtn).CornerRadius = UDim.new(0,8)

        -- handlers assigned later by module (we return references)
        return n
    end
    return nil
end

local notifFrame = ensureNotificationUI()
local function showNotification(text)
    if notifFrame and notifFrame:IsA("Frame") then
        notifFrame.Label.Text = text
        notifFrame.Visible = true
        quickTween = (function() end) -- no-op local tweening optional; keep simple
        task.delay(6, function()
            pcall(function() notifFrame.Visible = false end)
        end)
    else
        -- fallback console
        print("[resilience] NOTE:", text)
    end
end

-- SMART RECOVERY functions
local function clearForces(part)
    if not part then return end
    pcall(function()
        part.AssemblyLinearVelocity = Vector3.zero
        part.AssemblyAngularVelocity = Vector3.zero
    end)
    for _,v in ipairs(part:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("LinearVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyGyro") or v:IsA("AngularVelocity") then
            pcall(function() v:Destroy() end)
        end
    end
end

local function recordSafePoint()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if hrp and hum and hum.Health > 1 and hum.FloorMaterial ~= Enum.Material.Air then
        state.lastSafeCFrame = hrp.CFrame
        state.safeRecorded = true
    end
end

-- Recovery action (safe and conservative)
local function recoverPlayerImmediate()
    if tick() - state.lastRecovery < SMART_RECOVERY_COOLDOWN then return false end
    state.lastRecovery = tick()
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if hrp then
        pcall(function()
            clearForces(hrp)
            if state.lastSafeCFrame then
                hrp.CFrame = state.lastSafeCFrame
            else
                hrp.CFrame = hrp.CFrame + Vector3.new(0,5,0)
            end
            hrp.Anchored = true
            task.wait(0.12)
            hrp.Anchored = false
        end)
    end
    -- ensure protection on and save settings
    pcall(function() if type(UPF.ToggleProtection) == "function" then UPF:ToggleProtection(true) end end)
    pcall(function() if type(UPF.SaveSettings) == "function" then UPF:SaveSettings() end end)
    showNotification("Recovery attempted")
    return true
end

-- Attempt reconnect (teleport to placeId). Tries several times with cooldown.
local function attemptReconnect()
    if tick() - state.lastReconnect < RECONNECT_COOLDOWN then
        return false, "cooldown"
    end
    if state.reconnectAttempts >= MAX_RECONNECT_ATTEMPTS then
        return false, "max_attempts"
    end
    state.reconnectAttempts = state.reconnectAttempts + 1
    state.lastReconnect = tick()

    showNotification("Attempting reconnect (attempt "..tostring(state.reconnectAttempts)..")")
    -- Save settings first
    pcall(function() if type(UPF.SaveSettings) == "function" then UPF:SaveSettings() end end)

    -- try teleport to same place (may join another server)
    local ok, err = pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
    if not ok then
        warn("[resilience] Teleport failed:", err)
        return false, err
    end
    return true
end

-- TRACK MOVEMENT / SAFE POINT
local function heartbeatTrack(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    -- record safe point when on floor & slow
    local vel = 0
    pcall(function() vel = hrp.AssemblyLinearVelocity.Magnitude end)
    if hum.FloorMaterial ~= Enum.Material.Air and vel < 10 then
        state.lastSafeCFrame = hrp.CFrame
    end

    -- stuck detection
    local pos = hrp.Position
    if state.lastPos then
        if (pos - state.lastPos).Magnitude > 0.2 or vel > 1 then
            state.lastMoveTick = tick()
        end
    else
        state.lastMoveTick = tick()
    end
    state.lastPos = pos

    if tick() - state.lastMoveTick > STUCK_TIME then
        -- stuck detected
        showNotification("Player appears stuck — attempting recovery")
        pcall(recoverPlayerImmediate)
    end

    -- out-of-bounds
    if pos.Y > SAFE_Y_HIGH or pos.Y < SAFE_Y_LOW then
        showNotification("Out-of-bounds detected — recovering")
        pcall(recoverPlayerImmediate)
    end

    -- fling detection (other players)
    if vel > FLING_VELOCITY_THRESHOLD then
        showNotification("High velocity detected — clearing forces")
        pcall(clearForces, hrp)
    end
end

-- MAIN modal detector integration
local LAST_MODAL_SCAN = 0
local MODAL_SCAN_INTERVAL = SCAN_INTERVAL

UPF.Connections = UPF.Connections or {}
if UPF.Connections.Resilience then
    pcall(function() UPF.Connections.Resilience:Disconnect() end)
    UPF.Connections.Resilience = nil
end

UPF.Connections.Resilience = RunService.Heartbeat:Connect(function(dt)
    -- heartbeat tracking for movement & recovery
    pcall(function() heartbeatTrack(dt) end)

    if tick() - LAST_MODAL_SCAN < MODAL_SCAN_INTERVAL then return end
    LAST_MODAL_SCAN = tick()

    local found = nil
    local ok, res = pcall(function()
        local cg = game:GetService("CoreGui")
        local r = nil
        -- search CoreGui first
        local function scan(root)
            if not root then return nil end
            for _,child in ipairs(root:GetChildren()) do
                local ok2, txt = pcall(function()
                    if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then return child.Text end
                    -- nested scan
                    return nil
                end)
                if ok2 and txt and containsAny(txt, KICK_DETECTION_PATTERNS) then
                    return child
                end
                -- deeper scan
                local sub = scan(child)
                if sub then return sub end
            end
            return nil
        end
        r = scan(cg)
        if r then return r end
        local pg = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            return scan(pg)
        end
        return nil
    end)
    if ok and res then
        -- found candidate text object
        local txt = pcall(function() return res.Text end) and res.Text or "??"
        local path = (pcall(function() return res:GetFullName() end) and res:GetFullName()) or "unknown"
        state.lastModal = { text = txt, path = path, time = tick() }
        -- log
        warn("[resilience] Modal detected:", txt, "path:", path)
        showNotification("Modal detected: "..(txt:sub(1,60)))
        -- auto actions: try recovery first
        pcall(recoverPlayerImmediate)
        -- and attempt reconnect if persistent or contains harsh tokens
        if containsAny(txt, {"kicked","you were removed","banned"}) then
            -- if likely kick, try reconnect after small delay
            task.delay(0.8, function()
                if tick() - state.lastReconnect > RECONNECT_COOLDOWN then
                    pcall(function() attemptReconnect() end)
                end
            end)
        else
            -- schedule a reconnect attempt if modal persists for some time
            task.delay(6, function()
                if state.lastModal and tick() - (state.lastModal.time or 0) < 10 then
                    -- modal still recent; attempt reconnect (limited)
                    if state.reconnectAttempts < MAX_RECONNECT_ATTEMPTS then
                        pcall(function() attemptReconnect() end)
                    end
                end
            end)
        end
    end
end)

-- expose functions for manual control
UPF.Resilience = UPF.Resilience or {}
UPF.Resilience.AttemptReconnect = attemptReconnect
UPF.Resilience.AttemptRecovery = recoverPlayerImmediate
UPF.Resilience.RecordSafePoint = recordSafePoint
UPF.Resilience.GetState = function() return state end

-- initial safe record if possible
pcall(function() UPF.Resilience.RecordSafePoint() end)

print("✅ module_resilience loaded — Anti-Kick detector, Auto-Reconnect & Smart Recovery ready")