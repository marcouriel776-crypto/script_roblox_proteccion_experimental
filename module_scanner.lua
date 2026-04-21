local UPF = _G.UPF

local Scanner = {}

Scanner.Results = {
    Server = {
        Particles = {},
        Sounds = {}
    },
    Local = {
        Particles = {},
        Sounds = {}
    }
}

local MAX_SCAN = 5000 -- anti-lag

-- =========================
-- DETECTOR
-- =========================

local function isServerAsset(obj)
    return obj:IsDescendantOf(game.Workspace)
        or obj:IsDescendantOf(game.ReplicatedStorage)
end

local function classify(obj)
    if obj:IsA("ParticleEmitter") then
        return "Particles"
    elseif obj:IsA("Sound") then
        return "Sounds"
    end
end

-- =========================
-- SCAN
-- =========================

function Scanner:Scan()
    table.clear(self.Results.Server.Particles)
    table.clear(self.Results.Server.Sounds)
    table.clear(self.Results.Local.Particles)
    table.clear(self.Results.Local.Sounds)

    local count = 0

    for _, obj in ipairs(game:GetDescendants()) do
        count += 1
        if count > MAX_SCAN then break end

        local category = classify(obj)
        if category then
            if isServerAsset(obj) then
                table.insert(self.Results.Server[category], obj)
            else
                table.insert(self.Results.Local[category], obj)
            end
        end
    end

    print("✅ Scan complete")
    print("Server Particles:", #self.Results.Server.Particles)
    print("Server Sounds:", #self.Results.Server.Sounds)
    print("Local Particles:", #self.Results.Local.Particles)
    print("Local Sounds:", #self.Results.Local.Sounds)
end

UPF.Scanner = Scanner

print("🔍 Scanner PRO loaded")
