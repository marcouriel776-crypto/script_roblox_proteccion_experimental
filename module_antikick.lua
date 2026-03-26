local mt = getrawmetatable(game)
setreadonly(mt, false)

local old = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()

    if method == "Kick" then
        warn("[UPF] Kick bloqueado (seguro)")
        return nil
    end

    return old(self, ...)
end)

setreadonly(mt, true)

print("AntiKick v2 loaded")