local UPF = _G.UPF

UPF.Assets = {
    Sounds = {},
    Particles = {},
    Decals = {}
}

local Assets = UPF.Assets

for _, v in ipairs(game:GetDescendants()) do

    if v:IsA("Sound") and v.SoundId ~= "" then
        table.insert(Assets.Sounds, v)
    end

    if v:IsA("ParticleEmitter") and v.Texture ~= "" then
        table.insert(Assets.Particles, v)
    end

    if v:IsA("Decal") and v.Texture ~= "" then
        table.insert(Assets.Decals, v)
    end

end

print("✅ Assets:", #Assets.Sounds, #Assets.Particles, #Assets.Decals)
