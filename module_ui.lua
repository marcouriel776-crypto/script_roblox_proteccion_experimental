-- module_ui.lua (Rayfield)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "UPF Protection System",
   LoadingTitle = "UPF",
   LoadingSubtitle = "by Marco & Uriel",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "UPF_Config",
      FileName = "settings"
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false
})
