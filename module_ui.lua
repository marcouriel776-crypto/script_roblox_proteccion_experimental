local UPF = _G.UPF
local Assets = UPF.Assets
local Visual = UPF.Visual

local UIS = game:GetService("UserInputService")

local index = 1
local mode = "Particles" -- Sounds / Particles / Decals

local function notify(text)
    game.StarterGui:SetCore("SendNotification", {
        Title = "UPF Browser",
        Text = text,
        Duration = 2
    })
end

local function applyCurrent()
    if mode == "Particles" then
        local tex = Assets.Particles[index]
        if tex then
            Visual:ApplyParticle(tex)
            notify("Particle: "..index)
        end

    elseif mode == "Sounds" then
        local snd = Assets.Sounds[index]
        if snd then
            Visual:PlaySound(snd)
            notify("Sound: "..index)
        end
    end
end

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == Enum.KeyCode.Right then
        index += 1
        applyCurrent()

    elseif input.KeyCode == Enum.KeyCode.Left then
        index = math.max(1, index - 1)
        applyCurrent()

    elseif input.KeyCode == Enum.KeyCode.M then
        if mode == "Particles" then
            mode = "Sounds"
        else
            mode = "Particles"
        end
        notify("Mode: "..mode)
    end
end)

print("🎛 Asset Browser ready")
