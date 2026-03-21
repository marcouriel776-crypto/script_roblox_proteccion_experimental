local mt = getrawmetatable(game)
setreadonly(mt, false)

local old = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()

    if method == "Kick" then
        warn("[AntiKick] Kick bloqueado")
        return nil
    end

    return old(self, ...)
end)

setreadonly(mt, true)
