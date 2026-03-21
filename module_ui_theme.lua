local UPF = getgenv().UPF

task.spawn(function()
    local tries = 0
    while not UPF.UI or not UPF.UI.Frame do
        task.wait(0.1)
        tries += 1
        if tries > 50 then
            warn("UI nunca cargó (timeout)")
            return
        end
    end

    local frame = UPF.UI.Frame
    frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
end)
