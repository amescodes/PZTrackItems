function TrackItemsAtTopPrint(txt, debugOnly)
    if debugOnly == nil then
        debugOnly = false
    end
    if not debugOnly or TrackItemsAtTop.Verbose then
        print(txt)
    end
end

function isMovable(item)
    if instanceof(item, "Moveable") then return true end
    return false
end

function isEntertainment(item)
    return item:getDisplayCategory() == getText("IGUI_ItemCat_Entertainment") or item:getSaveType() == getText("IGUI_ItemCat_Entertainment")
end

function isKey(item)
    return ((instanceof(item, "Key")) and not item:isPadlock() and not item:isDigitalPadlock()) or instanceof(item, "KeyRing")
end

function isValidItem(item)
    return not item == nil
        and not isMovable(item)
        and not isEntertainment(item)
        and (not isKey(item) or SandboxVars.TrackItemsAtTop.AllowKeys)
end
