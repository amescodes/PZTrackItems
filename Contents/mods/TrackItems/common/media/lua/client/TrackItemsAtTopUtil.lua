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

--B42 - only allow skill books and gardening packets Literature items
function isDisallowedLiterature(item)
    -- local sBook = string.gsub(getText("IGUI_ItemCat_SkillBook"), "%s+", "")
    -- local gBook = string.gsub(getText("IGUI_ItemCat_Gardening"), "%s+", "")
    local x = item:getDisplayCategory()
    local y = item:getScriptItem()
    local z = y:getTeachedRecipes()
    local a = item:IsLiterature()
    return item:IsLiterature()
        and not (item:getDisplayCategory() == "SkillBook"
                or item:getDisplayCategory() == "Gardening"
                or (z and z:size() > 0)
                )
end

function isKey(item)
    return ((instanceof(item, "Key")) and not item:isPadlock() and not item:isDigitalPadlock()) or instanceof(item, "KeyRing")
end

function isValidItem(item)
    return item
        and not isMovable(item)
        and not isEntertainment(item)
        and not isDisallowedLiterature(item)
        and (not isKey(item) or SandboxVars.TrackItemsAtTop.AllowKeys)
end
