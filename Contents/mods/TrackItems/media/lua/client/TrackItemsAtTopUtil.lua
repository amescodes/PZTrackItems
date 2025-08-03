function TrackItemsAtTopPrint(txt, debugOnly)
    if debugOnly == nil then
        debugOnly = false
    end
    if not debugOnly or TrackItemsAtTop.Verbose then
        print(txt)
    end
end

function isMovable(item)
    return item:getType() == Type.Moveable
end

function isEntertainment(item)
    return item:getDisplayCategory() == "Entertainment"
end
function isKey(item)
    if item:getFullName() == "Base.KeyRing" then return true end

    local t = item:getType()
    if t == Type.Key then
        local i = instanceItem(item)
        return not i:isPadlock() and not i:isDigitalPadlock()
    end
    return false
end

function isValidItem(item)
    if (instanceof(item, "InventoryItem")) then
        item = item:getScriptItem()
    end
    return item
        and not isMovable(item)
        and not isEntertainment(item)
        and (not isKey(item) or SandboxVars.TrackItemsAtTop.AllowKeys)
end
