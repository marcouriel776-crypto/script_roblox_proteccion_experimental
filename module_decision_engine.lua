local UPF = getgenv().UPF

local Brain = {}
UPF.Brain = Brain

function Brain:Tick()
    local flags = UPF.Flags or {}

    if flags.AdminPresent then
        warn("[UPF] modo seguro activado (admin presente)")
        UPF.SafeMode = true
    else
        UPF.SafeMode = false
    end

    if flags.SuspiciousMovement then
        warn("[UPF] reduciendo actividad por comportamiento")
        UPF.Throttle = true
    else
        UPF.Throttle = false
    end
end

return Brain