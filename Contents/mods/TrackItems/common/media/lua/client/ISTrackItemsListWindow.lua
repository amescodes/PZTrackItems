require "ISUI/ISCollapsableWindow"
require "TrackItemsAtTop"
require "TrackItemsAtTopUtil"

trackItemsListHandle = nil

ISTrackItemsListWindow = ISCollapsableWindow:derive("ISTrackItemsListWindow")

ISTrackItemsListWindow.SMALL_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
ISTrackItemsListWindow.MEDIUM_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()

local limit = 100

function ISTrackItemsListWindow:onFilterChange()
    local filterText = string.trim(self.parent.filterEntry:getInternalText())
    self.parent:filter(filterText)
end

local function getZomboidItemsList()
    local allItems = getAllItems()
    local amount = allItems:size() - 1
    
    local finalItems = {}
    for i = 0, amount do
        local item = allItems:get(i)
        if item and not item:getObsolete() and not item:isHidden() then
            local c = item:getDisplayCategory()
            local i = item:getIcon()
            local t = item:getNormalTexture()

            local itemInstance = instanceItem(item)
            if isValidItem(itemInstance) then
                table.insert(finalItems,itemInstance)
            end
        end
    end

    return finalItems
end

function ISTrackItemsListWindow:filter(filterText)
    filterText = string.lower(filterText)

    local allItems = self.itemsCache
    if not allItems then
        allItems = getZomboidItemsList()
        self.itemsCache = allItems
    end

    self.items:clear()
    local count = 0
    if allItems then
    for _,item in ipairs(allItems) do
            if item then
                if count < limit then
                    if not TrackItemsAtTop:ContainsItem(item)
                    and ((not filterText or filterText == "") or string.contains(string.lower(item:getDisplayName()), string.lower(filterText)) or string.contains(string.lower(item:getFullType()), string.lower(filterText))) then
                        local type = item:getFullType()
                        self.items:addItem(type, item)
                        count = count + 1
                    end
                end
            end
        end
    end
    
    local label = getText("IGUI_TrackItems_ShowingInSearch") .. " " .. count .. " " .. getText("IGUI_TrackItems_Items")
    self.totalFound:setName(label)
end

function ISTrackItemsListWindow:doDrawItem(y, item, alt)
    local baseItemDY = 0
    if item.item:getName() then
        baseItemDY = self.SMALL_FONT_HGT
        item.height = self.itemheight + baseItemDY
    end

    if y + self:getYScroll() >= self.height then
        return y + item.height
    end
    if y + item.height + self:getYScroll() <= 0 then
        return y + item.height
    end

    local a = 0.9
    self:drawRectBorder(0, (y), self:getWidth(), item.height - 1, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), item.height - 1, 0.3, 0.7, 0.35, 0.15)
    end

    self:drawText(item.item:getName(), 32, y + 10, 1, 1, 1, a, UIFont.Small)
    self:drawTextureScaledAspect(item.item:getTex(), 8, y + 8, 20, 20, 1, 1, 1, 1)

    return y + item.height
end

function ISTrackItemsListWindow:onDoubleClick(item)
    if item then
        TrackItemsAtTop:TrackItem(item)
        charTrackItemsHandle:updateTrackedItems()
        ISInventoryPage.dirtyUI()
    end
    self:close()
end

function ISTrackItemsListWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()

    self.textX = 20
    self.textY = th + 20

    self.filterLabel = ISLabel:new(self.textX, self.textY, 1, getText("IGUI_TrackItems_SearchItem"), 1, 1, 1, 1,
        UIFont.Small, true)
    self:addChild(self.filterLabel)

    self.filterEntry = ISTextEntryBox:new("", self.textX +
        getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_TrackItems_SearchItem")) + 10,
        self.textY - self.SMALL_FONT_HGT / 2, 150, 1)
    self.filterEntry:initialise()
    self.filterEntry:instantiate()
    self.filterEntry:setText("")
    self.filterEntry:setClearButton(true)
    self.filterEntry.onTextChange = ISTrackItemsListWindow.onFilterChange
    self:addChild(self.filterEntry)

    self.textY = self.textY + 20

    self.items = ISScrollingListBox:new(self.textX, self.textY + 20, 260, 180)
    self.items:initialise()
    self.items:instantiate()
    self.items:setAnchorRight(false)
    self.items:setAnchorBottom(true)
    self.items.font = UIFont.NewSmall
    self.items.itemheight = self.MEDIUM_FONT_HGT
    self.items.selected = 1
    self.items.joypadParent = self
    self.items.drawBorder = false
    self.items.SMALL_FONT_HGT = self.SMALL_FONT_HGT
    self.items.MEDIUM_FONT_HGT = self.MEDIUM_FONT_HGT
    self.items.doDrawItem = ISTrackItemsListWindow.doDrawItem
    self.items:setOnMouseDoubleClick(self,ISTrackItemsListWindow.onDoubleClick)
    self:addChild(self.items)

    local allItems = getZomboidItemsList()
    self.itemsCache = allItems
    local count = 0
    if allItems then
        for _, item in ipairs(allItems) do
            if count <= limit then
                if item then
                    local containsItem = TrackItemsAtTop:ContainsItem(item)
                    if not containsItem then
                        local type = item:getFullType()
                        self.items:addItem(type, item)
                    end
                    if count >= limit then
                        break
                    end
                    count = count + 1
                end
            end
        end
    end

    local label = getText("IGUI_TrackItems_ShowingInSearch") .. " " .. count .. " " .. getText("IGUI_TrackItems_Items")
    self.totalFound = ISLabel:new(self.textX, self.textY, ISTrackItemsListWindow.SMALL_FONT_HGT, label, 1, 1, 1, 0.7,
        UIFont.Small, true)
    self:addChild(self.totalFound)

    self.trackButton = ISButton:new(120, self.items:getBottom() + 10, 60, 25, getText("IGUI_TrackItems_TrackItem"),
        self, ISTrackItemsListWindow.trackButton)
    self.trackButton:initialise()
    self.trackButton.enable = true
    self:addChild(self.trackButton)

    self:bringToTop()
end

function ISTrackItemsListWindow:trackButton(button)
    if #self.items.items <= 0 then
        return
    end
    local rowIndex = self.items.selected
    local item = self.items.items[rowIndex]
    item = item["item"]
    if item then
        TrackItemsAtTop:TrackItem(item)
        charTrackItemsHandle:updateTrackedItems()
        ISInventoryPage.dirtyUI()
    end

    self:close()
end

function ISTrackItemsListWindow:close()
    ISCollapsableWindow.close(self)
    self:removeFromUIManager()
end

function ISTrackItemsListWindow:new(x, y, width, height)
    local o = {}
    if x == 0 and y == 0 then
        x = (getCore():getScreenWidth() / 2) - (width / 2)
        y = (getCore():getScreenHeight() / 2) - (height / 2)
    end
    o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    o.fgBar = {
        r = 0,
        g = 0.6,
        b = 0,
        a = 0.7
    }
    self.__index = self
    o.title = getText("UI_char_TrackItemsAtTop_AddItem")
    o.resizable = false
    return o
end
