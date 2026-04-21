local UPF = _G.UPF
if not UPF then return end

UPF.Visual = {}
local Visual = UPF.Visual

Visual.Enabled = false

function Visual:Enable()

    if self.Enabled then return end
    self.Enabled = true

    local root = UPF.Root
    if not root then return end

    if root:FindFirstChild("UPF_VISUAL") then return end

    local tag = Instance.new("Folder")
    tag.Name = "UPF_VISUAL"
    tag.Parent = root

    local attach = Instance.new("Attachment", root)

    -- 🔥 aura
    local aura = Instance.new("ParticleEmitter")
    aura.Texture = "rbxassetid://252907458"
    aura.Rate = 25
    aura.Lifetime = NumberRange.new(0.5,1)
    aura.Speed = NumberRange.new(2,5)
    aura.Parent = attach

    -- 💡 luz
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(0,255,120)
    light.Range = 10
    light.Parent = root

    -- 🔊 sonido
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9118823100"
    sound.Looped = true
    sound.Volume = 0.5
    sound.Parent = root
    sound:Play()

    print("💻 Visual ON")
end

function Visual:Disable()

    self.Enabled = false

    local root = UPF.Root
    if not root then return end

    local fx = root:FindFirstChild("UPF_VISUAL")
    if fx then
        fx:Destroy()
    end

    print("❌ Visual OFF")
end

return Visual
