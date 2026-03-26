local Players = game:GetService("Players")
local UPF = getgenv().UPF

local Admin = {}
UPF.Admin = Admin

local keywords = {"mod", "admin", "owner", "staff"}

function Admin:Check()
    for _, p in ipairs(Players:GetPlayers()) do
        local name = string.lower(p.Name)

        for _, k in ipairs(keywords) do
            if string.find(name, k) then
                warn("[UPF] posible admin detectado:", p.Name)

                UPF.Flags = UPF.Flags or {}
                UPF.Flags.AdminPresent = true
                return
            end
        end
    end

    UPF.Flags.AdminPresent = false
end

return Admin