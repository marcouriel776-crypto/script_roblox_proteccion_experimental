local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local UPF = _G.UPF

local Window = Rayfield:CreateWindow({
   Name = "UPF PRO",
   LoadingTitle = "UPF",
   LoadingSubtitle = "System"
})

local Main = Window:CreateTab("Main", 0)
local Debug = Window:CreateTab("Debug", 0)

Main:CreateToggle({
   Name = "God Mode",
   CurrentValue = false,
   Callback = function(v)
      UPF:ToggleGodMode(v)
   end
})

Main:CreateButton({
   Name = "Recover",
   Callback = function()
      UPF:RecoverPlayer()
   end
})

-- DEBUG REAL
for mod, data in pairs(UPF.LoadResults or {}) do
    Debug:CreateLabel((data.success and "✅ " or "❌ ") .. mod)
end

Rayfield:Notify({
   Title = "UPF",
   Content = "Loaded",
   Duration = 3
})

print("✅ UI PRO CLEAN loaded")
