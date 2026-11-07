-- LinkHead: press a hotkey to get the Wowhead link for whatever you're
-- hovering (NPC, item, interactable object) or whichever quest is open.

BINDING_HEADER_LINKHEAD_CATEGORY = "LinkHead"
BINDING_NAME_LINKHEAD_LOOKUP = "Look up on Wowhead"

local WOWHEAD_BASE = "https://www.wowhead.com/"

local UNIT_GUID_PAGE = {
	Creature = "npc",
	Vehicle = "npc",
	GameObject = "object",
}

-- Pulls the Wowhead page type + id out of a unit's GUID, if it has one.
local function GetUnitWowheadTarget(unit)
	if not UnitExists(unit) then
		return nil
	end
	local guid = UnitGUID(unit)
	if not guid then
		return nil
	end
	local kind, _, _, _, _, id = strsplit("-", guid)
	local page = UNIT_GUID_PAGE[kind]
	if not page or not id then
		return nil
	end
	return page, id, UnitName(unit)
end

-- Pulls an item id out of whatever GameTooltip is currently showing.
local function GetTooltipItemTarget()
	if not GameTooltip:IsShown() then
		return nil
	end
	local _, link = GameTooltip:GetItem()
	if not link then
		return nil
	end
	local itemID = link:match("item:(%d+)")
	if not itemID then
		return nil
	end
	return "item", itemID
end

-- Pulls the active quest id out of an open quest frame (greeting, detail,
-- reward screens) or the currently selected quest in the quest log.
local function GetQuestTarget()
	if GetQuestID then
		local questID = GetQuestID()
		if questID and questID ~= 0 then
			return "quest", questID
		end
	end
	if C_QuestLog and C_QuestLog.GetSelectedQuestID then
		local questID = C_QuestLog.GetSelectedQuestID()
		if questID and questID ~= 0 then
			return "quest", questID
		end
	end
	return nil
end

local function FindWowheadTarget()
	local page, id, name = GetTooltipItemTarget()
	if page then
		return page, id, name
	end

	page, id, name = GetUnitWowheadTarget("mouseover")
	if page then
		return page, id, name
	end

	page, id = GetQuestTarget()
	if page then
		return page, id
	end

	-- "npc" is the special unit token WoW uses for the NPC behind an open
	-- gossip/quest/vendor frame.
	page, id, name = GetUnitWowheadTarget("npc")
	if page then
		return page, id, name
	end

	page, id, name = GetUnitWowheadTarget("target")
	if page then
		return page, id, name
	end

	return nil
end

local popup

local function EnsurePopup()
	if popup then
		return popup
	end

	popup = CreateFrame("Frame", "LinkHeadPopup", UIParent, "BackdropTemplateWithFinalShadow")
	popup:SetSize(420, 90)
	popup:SetPoint("CENTER")
	popup:SetFrameStrata("DIALOG")
	popup:SetMovable(true)
	popup:EnableMouse(true)
	popup:RegisterForDrag("LeftButton")
	popup:SetScript("OnDragStart", popup.StartMoving)
	popup:SetScript("OnDragStop", popup.StopMovingOrSizing)
	if popup.SetBackdrop then
		popup:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true, tileSize = 32, edgeSize = 32,
			insets = { left = 11, right = 12, top = 12, bottom = 11 },
		})
	end

	local title = popup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOP", 0, -16)
	title:SetText("LinkHead")
	popup.title = title

	local editBox = CreateFrame("EditBox", nil, popup, "InputBoxTemplate")
	editBox:SetSize(380, 20)
	editBox:SetPoint("TOP", 0, -40)
	editBox:SetAutoFocus(true)
	editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	editBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
	editBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
	popup.editBox = editBox

	local hint = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	hint:SetPoint("TOP", editBox, "BOTTOM", 0, -8)
	hint:SetText("Ctrl+C to copy, Esc to close")
	popup.hint = hint

	local close = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)

	return popup
end

local function ShowURL(url, label)
	local frame = EnsurePopup()
	frame.title:SetText(label and ("LinkHead - " .. label) or "LinkHead")
	frame.editBox:SetText(url)
	frame.editBox:HighlightText()
	frame.editBox:SetFocus()
	frame:Show()

	if C_System and C_System.SetClipboard then
		C_System.SetClipboard(url)
	end
end

function LinkHead_Lookup()
	local page, id, name = FindWowheadTarget()
	if not page then
		print("|cffff6060LinkHead:|r nothing to look up. Hover an NPC, item, or interactable object, or open a quest.")
		return
	end

	local url = WOWHEAD_BASE .. page .. "=" .. tostring(id)
	ShowURL(url, name)
end
