local UPF = _G.UPF
local Assets = UPF.Assets
local Lighting = game:GetService("Lighting")

local Devil = {}
Devil.Enabled = false
Devil.Connections = {}
Devil.Objects = {}

local function clearAll()
    for _, obj in ipairs(Devil.Objects) do
        if obj and obj.Destroy then
            pcall(function() obj:Destroy() end)
        end
    end
    Devil.Objects = {}
end

function Devil:Disable()
    self.Enabled = false

    for _, c in pairs(self.Connections) do
        pcall(function() c:Disconnect() end)
    end

    self.Connections = {}

    clearAll()

    -- reset lighting
    Lighting.Ambient = Color3.new(1,1,1)
    Lighting.Brightness = 2
end

function Devil:Enable()
    if self.Enabled then return end
    self.Enabled = true

    local root = UPF.Root
    if not root then return end

    clearAll()

    -- 🔥 PARTICLE BASE
    if Assets.Particles[1] then
        local att = Instance.new("Attachment", root)
        local p = Assets.Particles[1]:Clone()
        p.Parent = att
        p.Rate = 40
        p.Enabled = true

        table.insert(self.Objects, att)
    end

    -- 👁️ HIGHLIGHT (aura visible para todos)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(0,255,150)
    highlight.OutlineColor = Color3.fromRGB(0,0,0)
    highlight.Parent = UPF.Character

    table.insert(self.Objects, highlight)

    -- 🔊 SOUND LOOP
    if Assets.Sounds[1] then
        local s = Assets.Sounds[1]:Clone()
        s.Parent = root
        s.Looped = true
        s.Volume = 0.5
        s:Play()

        table.insert(self.Objects, s)
    end

    -- 🌈 RGB + PULSE LOOP
    self.Connections.RGB = game:GetService("RunService").RenderStepped:Connect(function()
        if not self.Enabled then return end

        local t = tick()

        -- RGB ambiente
        Lighting.Ambient = Color3.fromHSV((t % 5)/5, 1, 1)

        -- PULSO (brillo dinámico)
        Lighting.Brightness = 2 + math.sin(t*3)*1

        -- color aura
        if highlight then
            highlight.FillColor = Color3.fromHSV((t % 3)/3, 1, 1)
        end
    end)
end

UPF.Devil = Devil

print("😈 Devil MAX loaded")
