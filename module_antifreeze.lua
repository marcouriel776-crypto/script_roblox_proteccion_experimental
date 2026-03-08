-- module_antifreeze.lua
-- UPF Anti Freeze + Network Popup Remover

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

_G.UPF = _G.UPF or {}
local UPF = _G.UPF

UPF.State = UPF.State or {}
UPF.State.AntiFreeze = true

UPF.AntiFreeze = {}
local AntiFreeze = UPF.AntiFreeze

AntiFreeze.Connections = {}

------------------------------------------------
-- REMOVE BLUR / FREEZE EFFECTS
------------------------------------------------

local function clearVisualFreeze()

    for _,v in pairs(Lighting:GetChildren()) do

        if v:IsA("BlurEffect") then
            v:Destroy()
        end

        if v:IsA("ColorCorrectionEffect") then
            if v.Saturation < 0 then
                v:Destroy()
            end
        end

    end

end

------------------------------------------------
-- REMOVE NETWORK POPUPS
------------------------------------------------

local function scanGui(gui)

    if not gui:IsA("ScreenGui") then return end

    local text = gui.Name:lower()

    if text:find("disconnect")
    or text:find("connection")
    or text:find("network")
    or text:find("internet")
    or text:find("reconnect")
    or text:find("loading") then

        print("🧊 UPF AntiFreeze removed:", gui.Name)

        gui:Destroy()

    end

end

------------------------------------------------
-- GUI MONITOR
------------------------------------------------

local function monitorGui()

    if AntiFreeze.Connections.Gui then
        AntiFreeze.Connections.Gui:Disconnect()
    end

    AntiFreeze.Connections.Gui =
        CoreGui.ChildAdded:Connect(function(child)

            if not UPF.State.AntiFreeze then return end

            task.wait(0.5)

            pcall(function()
                scanGui(child)
            end)

        end)

end

------------------------------------------------
-- FRAME FREEZE DETECTOR
------------------------------------------------

local function detectFrameFreeze()

    local last = tick()

    if AntiFreeze.Connections.Heartbeat then
        AntiFreeze.Connections.Heartbeat:Disconnect()
    end

    AntiFreeze.Connections.Heartbeat =
        RunService.Heartbeat:Connect(function()

            if not UPF.State.AntiFreeze then return end

            local now = tick()

            if now - last > 3 then
                print("🧊 UPF Freeze detected -> recovering")
                clearVisualFreeze()

                if UPF.RecoverPlayer then
                    UPF:RecoverPlayer()
                end
            end

            last = now

        end)

end

------------------------------------------------
-- PUBLIC API
------------------------------------------------

function UPF:ToggleAntiFreeze(on)

    if on == nil then
        UPF.State.AntiFreeze = not UPF.State.AntiFreeze
    else
        UPF.State.AntiFreeze = on
    end

    print("🧊 AntiFreeze:", UPF.State.AntiFreeze)

    if UPF.State.AntiFreeze then
        monitorGui()
        detectFrameFreeze()
        clearVisualFreeze()
    end

    if UPF.SaveSettings then
        UPF:SaveSettings()
    end

end

------------------------------------------------
-- START SYSTEM
------------------------------------------------

monitorGui()
detectFrameFreeze()

print("✅ module_antifreeze loaded")