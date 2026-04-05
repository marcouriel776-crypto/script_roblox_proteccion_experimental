-- module_ui.lua (UPF UI PRO CLEAN)

-- =========================
-- LOAD RAYFIELD (SAFE)
-- =========================

local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("❌ Rayfield failed to load")
    return
end

-- =========================
-- WAIT FOR UPF (CRÍTICO)
-- =========================

repeat task.wait() until _G.UPF and _G.UPF.State
local UPF = _G.UPF

print("✅ UPF detected in UI")

-- =========================
-- SAFE CALL HELPER
-- =========================

local function safeCall(func, ...)
    if typeof(func) == "function" then
        local ok, err = pcall(func, ...)
        if not ok then
            warn("UI Callback Error:", err)
        end
    else
        warn("UI tried to call nil function")
    end
end

-- =========================
-- WINDOW
-- =========================

local Window = Rayfield:CreateWindow({
   Name = "🛡 UPF Protection",
   LoadingTitle = "UPF System",
   LoadingSubtitle = "by Marco & Uriel",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "UPF_Config",
      FileName = "settings"
   },
   KeySystem = false
})

-- =========================
-- TABS
-- =========================

local MainTab = Window:CreateTab("Main", 4483362458)
local ProtectionTab = Window:CreateTab("Protection", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- =========================
-- MAIN
-- =========================

MainTab:CreateToggle({
   Name = "💚 God Mode",
   CurrentValue = false,
   Callback = function(Value)
      safeCall(UPF.ToggleGodMode, UPF, Value)
   end,
})

MainTab:CreateButton({
   Name = "📍 Recover Player",
   Callback = function()
      safeCall(UPF.RecoverPlayer, UPF)
   end,
})

MainTab:CreateButton({
   Name = "🧹 Reset Velocity",
   Callback = function()
      if UPF.RootPart then
         UPF.RootPart.AssemblyLinearVelocity = Vector3.zero
      end
   end,
})

-- =========================
-- PROTECTION
-- =========================

ProtectionTab:CreateToggle({
   Name = "🛡 Enable Protection",
   CurrentValue = true,
   Callback = function(Value)
      if UPF.State then
         UPF.State.ProtectionEnabled = Value
      end
   end,
})

ProtectionTab:CreateDropdown({
   Name = "🧠 Smart Mode",
   Options = {"SAFE", "AGGRESSIVE"},
   CurrentOption = UPF.State.SmartMode or "SAFE",
   Callback = function(Option)
      if UPF.State then
         UPF.State.SmartMode = Option
      end
   end,
})

ProtectionTab:CreateToggle({
   Name = "🚫 NoClip Players",
   CurrentValue = false,
   Callback = function(Value)
      if UPF.State then
         UPF.State.NoClipPlayers = Value
      end
   end,
})

-- =========================
-- MISC
-- =========================

MiscTab:CreateButton({
   Name = "🔄 Rejoin Server",
   Callback = function()
      game:GetService("TeleportService"):Teleport(game.PlaceId)
   end,
})

MiscTab:CreateButton({
   Name = "❌ Destroy UI",
   Callback = function()
      Rayfield:Destroy()
   end,
})

-- =========================
-- NOTIFY
-- =========================

Rayfield:Notify({
   Title = "UPF Loaded",
   Content = "Sistema listo sin errores",
   Duration = 4,
})

print("✅ UI PRO CLEAN loaded")