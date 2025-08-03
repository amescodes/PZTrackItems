require "TrackItemsAtTop"

local old_ISInventoryPane_renderdetails = ISInventoryPane.renderdetails
function ISInventoryPane:renderdetails(doDragged)
    old_ISInventoryPane_renderdetails(self,doDragged)
    if not TrackItemsAtTop.Enabled or doDragged or not SandboxVars.TrackItemsAtTop.HighlightTrackedItems then return end

    for i, items in ipairs(self.itemslist) do
        local item = items.items[1]
        if TrackItemsAtTop:ContainsItem(item) then
            --TrackItemsAtTopPrint("ISInventoryPane:renderdetails: item found - updating inventory pane")
            self:drawRect(1, ((i-1)*self.itemHgt)+self.headerHgt, self.column4, self.itemHgt, 0.15, 0.95, 0.89, 0, 0.29)
        end
    end
end

local old_ISInventoryPane_itemSortByNameInc = ISInventoryPane.itemSortByNameInc
ISInventoryPane.itemSortByNameInc = function(a, b)

    if not TrackItemsAtTop.Enabled then
        return old_ISInventoryPane_itemSortByNameInc(a, b)
    end

    if a.equipped and not b.equipped then
        return false
    end
    if b.equipped and not a.equipped then
        return true
    end
    if a.inHotbar and not b.inHotbar then
        return true
    end
    if b.inHotbar and not a.inHotbar then
        return false
    end

    local containsA = TrackItemsAtTop:ContainsItem(a.items[1])
    local containsB = TrackItemsAtTop:ContainsItem(b.items[1])

    if containsA and containsB then
        return old_ISInventoryPane_itemSortByNameInc(a, b)
    end

    if containsA and not containsB then
        return true
    end

    if containsB and not containsA then
        return false
    end

    return old_ISInventoryPane_itemSortByNameInc(a, b)
end

local old_ISInventoryPane_itemSortByNameDesc = ISInventoryPane.itemSortByNameDesc
ISInventoryPane.itemSortByNameDesc = function(a, b)

    if not TrackItemsAtTop.Enabled then
        return old_ISInventoryPane_itemSortByNameDesc(a, b)
    end

    if a.equipped and not b.equipped then
        return false
    end
    if b.equipped and not a.equipped then
        return true
    end
    if a.inHotbar and not b.inHotbar then
        return true
    end
    if b.inHotbar and not a.inHotbar then
        return false
    end

    local containsA = TrackItemsAtTop:ContainsItem(a.items[1])
    local containsB = TrackItemsAtTop:ContainsItem(b.items[1])

    if containsA and containsB then
        return old_ISInventoryPane_itemSortByNameDesc(a, b)
    end

    if containsA and not containsB then
        return true
    end

    if containsB and not containsA then
        return false
    end

    return old_ISInventoryPane_itemSortByNameDesc(a, b)
end

local old_ISInventoryPane_itemSortByCatInc = ISInventoryPane.itemSortByCatInc
ISInventoryPane.itemSortByCatInc = function(a, b)

    if not TrackItemsAtTop.Enabled then
        return old_ISInventoryPane_itemSortByCatInc(a, b)
    end

    if a.equipped and not b.equipped then
        return false
    end
    if b.equipped and not a.equipped then
        return true
    end

    local containsA = TrackItemsAtTop:ContainsItem(a.items[1])
    local containsB = TrackItemsAtTop:ContainsItem(b.items[1])

    if containsA and containsB then
        return old_ISInventoryPane_itemSortByCatInc(a, b)
    end

    if containsA and not containsB then
        return true
    end

    if containsB and not containsA then
        return false
    end

    return old_ISInventoryPane_itemSortByCatInc(a, b)
end

local old_ISInventoryPane_itemSortByCatDesc = ISInventoryPane.itemSortByCatDesc
ISInventoryPane.itemSortByCatDesc = function(a, b)

    if not TrackItemsAtTop.Enabled then
        return old_ISInventoryPane_itemSortByCatDesc(a, b)
    end

    if a.equipped and not b.equipped then
        return false
    end
    if b.equipped and not a.equipped then
        return true
    end

    local containsA = TrackItemsAtTop:ContainsItem(a.items[1])
    local containsB = TrackItemsAtTop:ContainsItem(b.items[1])

    if containsA and containsB then
        return old_ISInventoryPane_itemSortByCatDesc(a, b)
    end

    if containsA and not containsB then
        return true
    end

    if containsB and not containsA then
        return false
    end

    return old_ISInventoryPane_itemSortByCatDesc(a, b)
end
