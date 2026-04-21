local UPF = _G.UPF
if not UPF then return end

UPF.Visual = {}
local Visual = UPF.Visual

Visual.Enabled = false

function Visual:ApplyParticle(texture)
    local root = UPF.Root
    if not root then return end

    self:Clear()

    local attach = Instance.new("Attachment", root)

    local p = Instance.new("ParticleEmitter")
    p.Texture = texture
    p.Rate = 25
    p.Lifetime = NumberRange.new(1)
    p.Parent = attach
end

function Visual:PlaySound(id)
    local root = UPF.Root
    if not root then return end

    local sound = Instance.new("Sound")
    sound.SoundId = id
    sound.Volume = 1
    sound.Parent = root
    sound:Play()
end

function Visual:Clear()
    local root = UPF.Root
    if not root then return end

    for _, v in ipairs(root:GetChildren()) do
        if v:IsA("Attachment") or v:IsA("Sound") then
            v:Destroy()
        end
    end
end
