require "TrackItemsAtTopUtil"

if not TrackItemsAtTop then
    TrackItemsAtTop = {}
end

TrackItemsAtTop.Enabled = true
TrackItemsAtTop.Verbose = isDebugEnabled()

if not TrackItemsAtTop.Items then
    TrackItemsAtTop.Items = {}
end

function TrackItemsAtTop:init(player)
    if player == nil or player:getModData() == nil then
        return
    end

    if player:getModData().TrackItemsAtTop == nil then
        -- create new mod data
        TrackItemsAtTopPrint("TrackItemsAtTop:init: creating new modData", true)
        player:getModData().TrackItemsAtTop = {}
    else
        -- load mod data
        TrackItemsAtTopPrint("TrackItemsAtTop:init: loading modData", true)
        for key, value in pairs(player:getModData().TrackItemsAtTop) do
            TrackItemsAtTopPrint("TrackItemsAtTop:init: loading "
                ..tostring(key).." = "..tostring(value), true)
            TrackItemsAtTop[key] = value
        end
    end
end

function TrackItemsAtTop:toggleState()
    TrackItemsAtTop.Enabled = not TrackItemsAtTop.Enabled
    ISInventoryPage.dirtyUI()
end

function TrackItemsAtTop:saveItems()
    TrackItemsAtTopPrint("TrackItemsAtTop:saveItems: saving modData")
    getPlayer():getModData()["TrackItemsAtTop"]["Items"] = TrackItemsAtTop.Items
end

function TrackItemsAtTop:TrackOrUntrackItem(item)
    local itemType = item:getFullType()
    if self:UntrackItem(itemType) then
        return
    end
    self:TrackItem(item)
end

function TrackItemsAtTop:TrackItem(item)
    if TrackItemsAtTop.Items and #TrackItemsAtTop.Items >= SandboxVars.TrackItemsAtTop.MaxItems then return end

    local itemType = item:getFullType()

    TrackItemsAtTopPrint("TrackItemsAtTop:TrackItem: looking for item type: " .. itemType, true)

    if type(TrackItemsAtTop.Items) == "table" and #TrackItemsAtTop.Items > 0 then
        TrackItemsAtTopPrint("TrackItemsAtTop:TrackItem: current tracked items length: "..#TrackItemsAtTop.Items, true)
        for index, it in ipairs(TrackItemsAtTop.Items) do
            TrackItemsAtTopPrint("TrackItemsAtTop:TrackItem: current tracked item: "..it.." (index: "..index..")", true)
            if it == itemType then
                TrackItemsAtTopPrint("TrackItemsAtTop:TrackItem: already tracked item type: " .. itemType, true)
                return
            end
        end
    end

    if TrackItemsAtTop.Items and #TrackItemsAtTop.Items == SandboxVars.TrackItemsAtTop.MaxItems then
        TrackItemsAtTopPrint("TrackItemsAtTop:TrackOrUntrackItem: max items reached ("
            ..SandboxVars.TrackItemsAtTop.MaxItems..") - not adding: "..itemType, true)
        return
    end

    TrackItemsAtTopPrint("TrackItemsAtTop:TrackOrUntrackItem: adding item #"..#TrackItemsAtTop.Items ..": "
        ..itemType, true)

    table.insert(TrackItemsAtTop.Items, itemType)
    self:saveItems()
end

function TrackItemsAtTop:UntrackItem(itemType)
    TrackItemsAtTopPrint("TrackItemsAtTop:UntrackItem: looking for item type: "..itemType, true)

    if type(TrackItemsAtTop.Items) == "table" and #TrackItemsAtTop.Items > 0 then
        TrackItemsAtTopPrint("TrackItemsAtTop:UntrackItem: current tracked items length: "..#TrackItemsAtTop.Items,
            true)
        for index, it in ipairs(TrackItemsAtTop.Items) do
            TrackItemsAtTopPrint("TrackItemsAtTop:UntrackItem: current tracked item: "..it.." (index: "
                ..index .. ")", true)
            if it == itemType then
                TrackItemsAtTopPrint("TrackItemsAtTop:UntrackItem: removing found item type: "..itemType, true)
                table.remove(TrackItemsAtTop.Items, index)
                self:saveItems()
                return true
            end
        end
    end
    return false
end

function TrackItemsAtTop:ContainsItem(item)
    if not item then
        return false
    end

    local itemType = item:getFullType()
    for _, it in ipairs(TrackItemsAtTop.Items) do
        if it == itemType then
            return true
        end
    end

    return false
end

if isDebugEnabled() then
    TrackItemsAtTop:init(getPlayer())
end
