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

--B42 - only allow skill books and gardening packets Literature items
function isDisallowedLiterature(item)
    return item:getType() == Type.Literature
        and (item:isMementoLoot()
        or (not (item:getDisplayCategory() == "SkillBook"
        or item:getTeachedRecipes()
                or item:getDisplayCategory() == "Gardening"
                )))
end

function hasOwner(item)
    return item:getTags():contains("ApplyOwnerName")
end

function isKey(item)
    local t = item:getType()
    if item:getTags():contains("KeyRing") then
        return not item:isMementoLoot() or item:getDisplayCategory() == "Container"
    end
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
    if item then
        local x = item:getDisplayCategory()
        local t = item:getType()
        local z = item:getTeachedRecipes()
        local m = item:isMementoLoot()

        local m2 =  isMovable(item)
        local e2 =  isEntertainment(item)
        local l2 =  isDisallowedLiterature(item)
        local k =  isKey(item)
        local o =  hasOwner(item)
    end
    return item
        and not hasOwner(item)
        and not isMovable(item)
        and not isEntertainment(item)
        and not isDisallowedLiterature(item)
        and (not isKey(item) or SandboxVars.TrackItemsAtTop.AllowKeys)
end
