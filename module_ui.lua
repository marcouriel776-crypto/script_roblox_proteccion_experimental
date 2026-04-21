local UPF = _G.UPF
if not UPF then return end

local Visual = UPF.Visual

-- ejemplo básico sin Rayfield (más estable)
game.StarterGui:SetCore("SendNotification", {
    Title = "UPF",
    Text = "Script cargado",
    Duration = 3
})

-- tecla para activar
local UIS = game:GetService("UserInputService")

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.K then
        if Visual.Enabled then
            Visual:Disable()
        else
            Visual:Enable()
        end
    end
end)

print("✅ UI loaded")
