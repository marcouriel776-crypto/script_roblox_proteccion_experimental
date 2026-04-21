local UPF = _G.UPF or {}
_G.UPF = UPF

UPF.Assets = {
    Sounds = {},
    Particles = {},
    Decals = {}
}

local function addUnique(tbl, value)
    if value and value ~= "" and not table.find(tbl, value) then
        table.insert(tbl, value)
    end
end

local function scan()
    print("🔍 Scanning game assets...")

    for _, v in ipairs(game:GetDescendants()) do

        if v:IsA("Sound") then
            addUnique(UPF.Assets.Sounds, v.SoundId)
        end

        if v:IsA("ParticleEmitter") then
            addUnique(UPF.Assets.Particles, v.Texture)
        end

        if v:IsA("Decal") then
            addUnique(UPF.Assets.Decals, v.Texture)
        end

    end

    print("✅ Scan complete")
    print("🎧 Sounds:", #UPF.Assets.Sounds)
    print("💨 Particles:", #UPF.Assets.Particles)
    print("🖼 Decals:", #UPF.Assets.Decals)
end

task.spawn(scan)
