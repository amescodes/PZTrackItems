require "TrackItemsAtTopUtil"
require "TrackItemsAtTop"
require "ISCharacterTrackItems"

local function trackOrUntrack(items, player)
    local item = items[1]
    if not instanceof(item, "InventoryItem") then
        TrackItemsAtTopPrint("trackOrUntrack: item not InventoryItem! type is: "..item:getType())
        TrackItemsAtTopPrint("trackOrUntrack: getting item.items[1]...")
        item = item.items[1]
    end
    
    if item then
        TrackItemsAtTop:TrackOrUntrackItem(item)
        charTrackItemsHandle:updateTrackedItems()
        ISInventoryPage.dirtyUI()
    end
end

local function TrackItemsAtTopInventoryContextMenuEntry(player, context, items)
    if not TrackItemsAtTop.Enabled then return end

    items = ISInventoryPane.getActualItems(items)
    if type(items) == "table" and #items > 0
    and isValidItem(items[1]) then
        local text = getText("IGUI_TrackItems_TrackItem")
        local containsItem = TrackItemsAtTop:ContainsItem(items[1])
        if containsItem then
            text = getText("IGUI_TrackItems_UntrackItem")
        end
        local trackOrUntrackOption = context:addOption(text, items, trackOrUntrack, player)

        if TrackItemsAtTop.Items and #TrackItemsAtTop.Items >= SandboxVars.TrackItemsAtTop.MaxItems and not containsItem then
            trackOrUntrackOption.notAvailable = true
            trackOrUntrackOption.tooltip = "Max tracked items reached."
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(TrackItemsAtTopInventoryContextMenuEntry)