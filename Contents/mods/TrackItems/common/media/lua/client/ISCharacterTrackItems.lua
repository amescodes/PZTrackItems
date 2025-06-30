require "ISUI/ISPanelJoypad"
require "ISCharacterTrackItems_ISCharacterInfoWindow_AddTab"
require "TrackItemsAtTop"
require "TrackItemsAtTopUtil"

charTrackItemsHandle = nil

ISCharacterTrackItems = ISPanelJoypad:derive("ISCharacterTrackItems")

ISCharacterTrackItems.SMALL_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()

ISCharacterTrackItems.DisplayedItems = {}

function ISCharacterTrackItems:initialise()
    TrackItemsAtTopPrint("ISCharacterTrackItems:initialise", false)
    ISPanelJoypad.initialise(self)
end

function ISCharacterTrackItems:createChildren()
    TrackItemsAtTopPrint("ISCharacterTrackItems:createChildren", true)
    TrackItemsAtTop:init(self.char)

    self.textY = 0
    self.inputX = self:getWidth() / 2

    self.textY = self.textY + 10

    self:createTickBox("Enabled", "UI_char_TrackItemsAtTop_Enable", "UI_char_TrackItemsAtTop_Enable_Tooltip",
        self.onEnabledChange)
    self.textY = self.textY + 10

    local pad = 10
    local w = 42
    local xmax = math.floor((self.width - (self.textX * 2)) / (w + pad))
    local xcount = 0

    for i = 0, SandboxVars.TrackItemsAtTop.MaxItems - 1 do
        self:createItemBox(i + 1, w, (xcount * (w + pad)) + self.textX, self.textY)

        xcount = xcount + 1

        if xcount >= xmax then
            xcount = 0
            self.textY = self.textY + w + pad
        end
    end

    local txt = getText("UI_char_TrackItemsAtTop_Info")
    local maxWid = getTextManager():MeasureStringX(UIFont.Small, txt) + (self.textX * 2)
    self.width = math.max(self.width, maxWid)

    self.textY = self["item" .. SandboxVars.TrackItemsAtTop.MaxItems]:getBottom() + 10

    self.infoLabel = ISLabel:new(self.textX, self.textY, ISCharacterTrackItems.SMALL_FONT_HGT, txt, 1, 1, 1, 0.7,
        UIFont.Small, true)
    self:addChild(self.infoLabel)

    if SandboxVars.TrackItemsAtTop.AllowItemListSearch then
        self.textY = self.textY + 30
        self.addItemButton = ISButton:new(self.textX, self.textY, 60, 25, getText("UI_char_TrackItemsAtTop_AddItem"),
            self, ISCharacterTrackItems.openTrackItemsList)
        self.addItemButton:initialise()
        self.addItemButton.enable = TrackItemsAtTop.Items and #TrackItemsAtTop.Items < SandboxVars.TrackItemsAtTop.MaxItems
        self:addChild(self.addItemButton)

        self.textY = self.addItemButton:getBottom() + 5
    else
        self.textY = self.textY + 10
    end

    self:updateTrackedItems()
end

function ISCharacterTrackItems:openTrackItemsList()
    if not SandboxVars.TrackItemsAtTop.AllowItemListSearch then return end
    if TrackItemsAtTop.Items and #TrackItemsAtTop.Items >= SandboxVars.TrackItemsAtTop.MaxItems then return end
    
    if trackItemsListHandle == nil then
        local width = 300
        local height = 300
        trackItemsListHandle = ISTrackItemsListWindow:new(0, 0, width, height)
        trackItemsListHandle:initialise()
        trackItemsListHandle:instantiate()
    end
    trackItemsListHandle.pinButton:setVisible(false)
    trackItemsListHandle.collapseButton:setVisible(false)
    trackItemsListHandle:addToUIManager()
    trackItemsListHandle:setVisible(true)
    return trackItemsListHandle
end

function ISCharacterTrackItems:render()
    if not self.char:getModData() then
        self:clearStencilRect()
        return
    end

    local tabHeight = self.y
    local maxHeight = getCore():getScreenHeight() - tabHeight - 20
    if ISWindow and ISWindow.TitleBarHeight then
        maxHeight = maxHeight - ISWindow.TitleBarHeight
    end

    local fontHeight = getTextManager():getFontHeight(UIFont.Small)
    local h = self.textY + fontHeight
    local finalHeight = math.min(h, maxHeight)
    self:setHeightAndParentHeight(finalHeight)
    self:setScrollHeight(h)

    local txt = getText("UI_char_TrackItemsAtTop_Info")
    local maxWid = getTextManager():MeasureStringX(UIFont.Small, txt) + (self.textX * 2)
    self:setWidthAndParentWidth(math.max(self.width, maxWid))

    self.addItemButton.enable = TrackItemsAtTop.Items and #TrackItemsAtTop.Items < SandboxVars.TrackItemsAtTop.MaxItems
end

function ISCharacterTrackItems:new(x, y, width, height, playerNum)
    local o = {}
    o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.playerNum = playerNum
    o.char = getSpecificPlayer(playerNum)
    o:noBackground()
    o.textX = 20
    o.inputX = 300
    o.textY = 0

    ISCharacterTrackItems.instance = o
    return o
end

function ISCharacterTrackItems:onTickChange(index, Enabled, settingId)
    TrackItemsAtTop[settingId] = Enabled
    local x = self.char:getModData()
    x.TrackItemsAtTop[settingId] = TrackItemsAtTop[settingId]
end

function ISCharacterTrackItems:onEnabledChange(index, Enabled, settingId)
    self:onTickChange(index, Enabled, settingId)
    ISInventoryPage.dirtyUI()
end

function ISCharacterTrackItems:createTickBox(settingId, text, tooltip, onTickChange)
    local txtWidth = getTextManager():MeasureStringX(UIFont.Medium, getText(text))
    local tickBoxHeight = getTextManager():getFontHeight(UIFont.Medium)
    local viewID = "tickbox_" .. settingId
    if self[viewID] then
        self:removeChild(self[settingId])
    end
    self[viewID] = ISTickBox:new(self.textX, self.textY, txtWidth, tickBoxHeight, viewID, self, onTickChange, settingId)
    self[viewID]:initialise()
    self:addChild(self[viewID])
    self[viewID]:addOption(getText(text))
    self[viewID]:setSelected(1, TrackItemsAtTop[settingId])
    self[viewID].tooltip = getText(tooltip)

    self.textY = self[viewID]:getBottom()
end

function ISCharacterTrackItems:createItemBox(id, width, xStart, yPos)
    local viewID = "item" .. id
    if self[viewID] then
        self:removeChild(self[viewID])
    end
    self[viewID] = ISRect:new(xStart, yPos, width, width, 0.8, 0, 0, 0)
    self[viewID]:initialise()
    self:addChild(self[viewID])
end

local function untrackItem(box, itemType)
    TrackItemsAtTop:UntrackItem(itemType)
    ISInventoryPage.dirtyUI()
    charTrackItemsHandle:updateTrackedItems()
end

local function makeOnRightMouseUp(boxItem, playerIndex, itemType)
    local infoPanel = getPlayerInfoPanel(playerIndex)
    local onRightMouseUp = function(rect, x, y)
        local contextMenu = ISContextMenu.get(playerIndex, (infoPanel:getX() + rect.parent:getX() + x),
            (infoPanel:getY() + rect.parent:getY() + y), 1, 1)

        contextMenu:addOption("Untrack", boxItem, untrackItem, itemType)
    end

    boxItem.onRightMouseUp = onRightMouseUp
end

function ISCharacterTrackItems:addItemToBox(itemType, id)
    local viewID = "item" .. id
    local rectBox = self[viewID]
    if not rectBox then
        return
    end

    local item = instanceItem(itemType)
    local tex = item:getTex()
    local iWid = tex:getWidthOrig()
    if iWid > 32 then
        iWid = 32
    end
    local iHgt = tex:getHeightOrig()
    if iHgt > 32 then
        iHgt = 32
    end

    local pad = 5
    rectBox["item"] = ISImage:new(pad, pad, iWid, iHgt,tex)
    rectBox["item"]:initialise()
    makeOnRightMouseUp(rectBox["item"], self.playerNum, itemType)
    rectBox["item"].mouseovertext = item.name
    rectBox:addChild(rectBox["item"])
end

function ISCharacterTrackItems:removeItemFromBox(id)
    local viewID = "item" .. id
    local rectBox = self[viewID]
    if not rectBox or not rectBox["item"] then
        return
    end

    rectBox:removeChild(rectBox["item"])
    rectBox["item"] = nil
end

function ISCharacterTrackItems:clearAllItemBoxes()
    if ISCharacterTrackItems.DisplayedItems and #ISCharacterTrackItems.DisplayedItems > 0 then
        for i = 1, #ISCharacterTrackItems.DisplayedItems do
            self:removeItemFromBox(i)
        end
    end
end

function ISCharacterTrackItems:updateTrackedItems()
    if not TrackItemsAtTop.Enabled or not TrackItemsAtTop.Items then
        return
    end

    if not ISCharacterTrackItems.DisplayedItems then
        ISCharacterTrackItems.DisplayedItems = {}
    end

    if #ISCharacterTrackItems.DisplayedItems ~= #TrackItemsAtTop.Items then
        -- sync items
        self:clearAllItemBoxes()
        ISCharacterTrackItems.DisplayedItems = {}
        if #TrackItemsAtTop.Items > 0 then
            for i, item in ipairs(TrackItemsAtTop.Items) do
                ISCharacterTrackItems.DisplayedItems[i] = item
                self:addItemToBox(item, i)
            end
        end
    end
end
