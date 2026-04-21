local UPF = _G.UPF
local Visual = {}

Visual.Current = nil

local function fixCamera()
    local char = UPF.Character
    if not char then return end

    local hum = UPF.Humanoid
    if hum then
        workspace.CurrentCamera.CameraSubject = hum
    end
end

function Visual:Clear()
    if self.Current then
        self.Current:Destroy()
        self.Current = nil
    end

    fixCamera()
end

function Visual:ApplyParticle(p)
    self:Clear()

    local root = UPF.Root
    if not root then return end

    local attach = Instance.new("Attachment")
    attach.Parent = root

    local clone = p:Clone()
    clone.Parent = attach

    if clone:IsA("ParticleEmitter") then
        clone.Enabled = true
        clone.Rate = math.clamp(clone.Rate, 0, 50) -- anti lag
    end

    self.Current = attach
end

function Visual:PlaySound(s)
    self:Clear()

    local root = UPF.Root
    if not root then return end

    local sound = s:Clone()
    sound.Parent = root
    sound:Play()

    self.Current = sound
end

UPF.Visual = Visual

print("✅ Visual loaded")
