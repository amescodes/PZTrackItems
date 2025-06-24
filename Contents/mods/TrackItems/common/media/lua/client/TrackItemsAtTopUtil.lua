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
    return item:getDisplayCategory() == getText("IGUI_ItemCat_Entertainment")
end

--B42 - only allow skill books and gardening packets Literature items
function isDisallowedLiterature(item)
    return instanceof(item, "Literature") and not (item:getDisplayCategory() == getText("IGUI_ItemCat_SkillBook") or item:getDisplayCategory() == getText("IGUI_ItemCat_Gardening"))
end

function isKey(item)
    if instanceof(item, "Key") or instanceof(item, "KeyRing")  then return true end
    return false
end

function isValidItem(item)
    return not isMovable(item)
        and not isEntertainment(item)
        and not isDisallowedLiterature(item)
        and (not isKey(item) or SandboxVars.TrackItemsAtTop.AllowKeys)
end
