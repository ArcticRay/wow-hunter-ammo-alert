local ADDON_NAME = ...
local DEFAULT_THRESHOLD = 200

local frame = CreateFrame("Frame")
local alertFrame, alertText
local lastLowState = false
local lastAmmoID

local function IsHunter()
    local _, class = UnitClass("player")
    return class == "HUNTER"
end

local function GetAmmoSlot()
    return INVSLOT_AMMO or 0
end

local function GetAmmoCount()
    local slot = GetAmmoSlot()
    local ammoID = GetInventoryItemID and GetInventoryItemID("player", slot)
    if not ammoID then return nil, nil end

    local count
    if type(GetInventoryItemCount) == "function" then
        count = GetInventoryItemCount("player", slot) or 0
    elseif C_Item and type(C_Item.GetItemCount) == "function" then
        count = C_Item.GetItemCount(ammoID) or 0
    else
        print("|cffff5555HunterAmmoAlert:|r Keine unterstützte API zum Zählen der Munition gefunden.")
        return nil, ammoID
    end

    -- WoW may report 1 for an empty ammo slot.
    if count == 1 and GetInventoryItemTexture
        and not GetInventoryItemTexture("player", slot) then
        count = 0
    end
    return count, ammoID
end

local function GetThreshold()
    local value = HunterAmmoAlertDB and tonumber(HunterAmmoAlertDB.threshold)
    return value and math.max(1, value) or DEFAULT_THRESHOLD
end

local function CreateAlert()
    if alertFrame then return end
    alertFrame = CreateFrame("Frame", "HunterAmmoAlertFrame", UIParent, "BackdropTemplate")
    alertFrame:SetSize(360, 64)
    alertFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
    alertFrame:SetFrameStrata("HIGH")
    alertFrame:SetMovable(true)
    alertFrame:EnableMouse(true)
    alertFrame:RegisterForDrag("LeftButton")
    alertFrame:SetClampedToScreen(true)
    alertFrame:SetScript("OnDragStart", function(self)
        if IsShiftKeyDown() then
            self:StartMoving()
        end
    end)
    alertFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint(1)
        HunterAmmoAlertDB = HunterAmmoAlertDB or {}
        HunterAmmoAlertDB.position = {
            point = point,
            relativePoint = relativePoint,
            x = x,
            y = y,
        }
    end)

    local saved = HunterAmmoAlertDB and HunterAmmoAlertDB.position
    if saved and saved.point and saved.relativePoint then
        alertFrame:ClearAllPoints()
        alertFrame:SetPoint(saved.point, UIParent, saved.relativePoint, saved.x or 0, saved.y or 0)
    end
    alertFrame:Hide()
    alertFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    alertFrame:SetBackdropColor(0.35, 0.02, 0.02, 0.95)
    alertText = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    alertText:SetPoint("CENTER")
    alertText:SetTextColor(1, 0.25, 0.2)
end

local function ShowWarning(count, threshold)
    CreateAlert()
    alertText:SetText(("WENIG MUNITION!  %d / %d"):format(count, threshold))
    alertFrame:Show()
    if PlaySound then
        if SOUNDKIT and SOUNDKIT.RAID_WARNING then
            PlaySound(SOUNDKIT.RAID_WARNING)
        else
            PlaySound(8959)
        end
    end
end

local function HideWarning()
    if alertFrame then alertFrame:Hide() end
end

local function CheckAmmo()
    if not IsHunter() then return end
    local count, ammoID = GetAmmoCount()
    if not ammoID then
        HideWarning()
        lastLowState, lastAmmoID = false, nil
        return
    end
    if count == nil then return end

    local threshold = GetThreshold()
    local isLow = count < threshold
    if isLow then
        if not lastLowState or lastAmmoID ~= ammoID then
            ShowWarning(count, threshold)
        else
            CreateAlert()
            alertText:SetText(("WENIG MUNITION!  %d / %d"):format(count, threshold))
            alertFrame:Show()
        end
    else
        HideWarning()
    end
    lastLowState, lastAmmoID = isLow, ammoID
end

local function PrintStatus()
    if not IsHunter() then
        print("|cffff5555HunterAmmoAlert:|r Dieses Addon ist nur für Jäger gedacht.")
        return
    end
    local count, ammoID = GetAmmoCount()
    if not ammoID then
        print("|cffff5555HunterAmmoAlert:|r Keine Munition im Munitionsplatz gefunden.")
    elseif count ~= nil then
        print(("|cff55ff55HunterAmmoAlert:|r %d Munition (Warnschwelle: %d)."):format(count, GetThreshold()))
    end
end

SLASH_HUNTERAMMOALERT1 = "/haa"
SlashCmdList.HUNTERAMMOALERT = function(msg)
    local command, value = (msg or ""):match("^(%S*)%s*(.-)$")
    command = (command or ""):lower()
    if command == "threshold" then
        local newValue = tonumber(value)
        if newValue and newValue >= 1 then
            HunterAmmoAlertDB = HunterAmmoAlertDB or {}
            HunterAmmoAlertDB.threshold = math.floor(newValue)
            print(("|cff55ff55HunterAmmoAlert:|r Warnschwelle auf %d gesetzt."):format(HunterAmmoAlertDB.threshold))
            CheckAmmo()
        else
            print("|cffff5555HunterAmmoAlert:|r Verwendung: /haa threshold 200")
        end
    elseif command == "status" then
        PrintStatus()
    else
        print("|cff55ff55HunterAmmoAlert|r – Befehle:")
        print("/haa status – aktuellen Munitionsbestand anzeigen")
        print("/haa threshold 200 – Warnschwelle ändern")
        print("Warnung mit SHIFT + linker Maustaste ziehen, um sie zu verschieben.")
    end
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
frame:SetScript("OnEvent", function(self, event, unit)
    if event == "UNIT_INVENTORY_CHANGED" and unit ~= "player" then return end
    if event == "PLAYER_LOGIN" then HunterAmmoAlertDB = HunterAmmoAlertDB or {} end
    CheckAmmo()
end)
