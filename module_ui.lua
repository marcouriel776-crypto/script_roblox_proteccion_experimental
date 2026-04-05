-- module_ui.lua (UPF + Rayfield PRO)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local UPF = _G.UPF
if not UPF then warn("UPF missing"); return end

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
      if UPF.ToggleGodMode then
         UPF:ToggleGodMode(Value)
      end
   end,
})

MainTab:CreateButton({
   Name = "📍 Recover Player",
   Callback = function()
      if UPF.RecoverPlayer then
         UPF:RecoverPlayer()
      end
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
      UPF.State.ProtectionEnabled = Value
   end,
})

ProtectionTab:CreateDropdown({
   Name = "🧠 Smart Mode",
   Options = {"SAFE", "AGGRESSIVE"},
   CurrentOption = "SAFE",
   Callback = function(Option)
      UPF.State.SmartMode = Option
   end,
})

ProtectionTab:CreateToggle({
   Name = "🚫 Anti-Fling (NoClip Players)",
   CurrentValue = true,
   Callback = function(Value)
      UPF.State.NoClipPlayers = Value
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
   Content = "Sistema listo",
   Duration = 4,
})

print("✅ Rayfield UI loaded")
