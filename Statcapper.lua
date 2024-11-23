-- Create the addon frame
local StatcapperFrame = CreateFrame("Frame", "StatcapperFrame", UIParent)

-- Register events
StatcapperFrame:RegisterEvent("PLAYER_LOGIN")
StatcapperFrame:RegisterEvent("CHARACTER_POINTS_CHANGED")

-- Define class-specific stat caps
local statCaps = {
    DEATHKNIGHT = {
        BLOOD = { Hit = 8, Expertise = 26, Crit = 20 },
        FROST = { Hit = 8, Expertise = 26, Haste = 15 },
        UNHOLY = { Hit = 8, Expertise = 26, Haste = 15 },
    },
    DRUID = {
        BALANCE = { Hit = 17, Haste = 20 },
        FERAL = { Hit = 8, Expertise = 26, Crit = 25, ArmorPen = 1400 },
        RESTORATION = { Haste = 20 },
    },
    HUNTER = {
        BEASTMASTERY = { Hit = 8, Crit = 25, ArmorPen = 1400 },
        MARKSMANSHIP = { Hit = 8, Crit = 25, ArmorPen = 1400 },
        SURVIVAL = { Hit = 8, Crit = 25 },
    },
    MAGE = {
        ARCANE = { Hit = 17, Crit = 30 },
        FIRE = { Hit = 17, Crit = 30 },
        FROST = { Hit = 17, Crit = 30 },
    },
    PALADIN = {
        HOLY = { Haste = 20 },
        PROTECTION = { Hit = 8, Expertise = 26, Block = 102.4 },
        RETRIBUTION = { Hit = 8, Expertise = 26, Crit = 25 },
    },
    PRIEST = {
        DISCIPLINE = { Haste = 20 },
        HOLY = { Haste = 20 },
        SHADOW = { Hit = 17, Crit = 20 },
    },
    ROGUE = {
        ASSASSINATION = { Hit = 8, Expertise = 26, Crit = 25, ArmorPen = 1400 },
        COMBAT = { Hit = 8, Expertise = 26, Crit = 25, ArmorPen = 1400 },
        SUBTLETY = { Hit = 8, Expertise = 26, Crit = 25 },
    },
    SHAMAN = {
        ELEMENTAL = { Hit = 17, Crit = 20 },
        ENHANCEMENT = { Hit = 8, Expertise = 26, Haste = 15, ArmorPen = 1400 },
        RESTORATION = { Haste = 20 },
    },
    WARLOCK = {
        AFFLICTION = { Hit = 17, Crit = 20 },
        DEMONOLOGY = { Hit = 17, Crit = 20 },
        DESTRUCTION = { Hit = 17, Crit = 20 },
    },
    WARRIOR = {
        ARMS = { Hit = 8, Expertise = 26, Crit = 25, ArmorPen = 1400 },
        FURY = { Hit = 8, Expertise = 26, Crit = 25, ArmorPen = 1400 },
        PROTECTION = { Hit = 8, Expertise = 26, Block = 102.4 },
    },
}

-- Detect player's specialization
local function GetPlayerSpec()
    local highestPoints = 0
    local primaryTree = nil
    for i = 1, 3 do
        local _, _, pointsSpent = GetTalentTabInfo(i)
        if pointsSpent > highestPoints then
            highestPoints = pointsSpent
            primaryTree = i
        end
    end
    return primaryTree
end

-- Get player's stats
local function GetPlayerStats()
    local stats = {
        Hit = GetCombatRatingBonus(CR_HIT_MELEE),
        SpellHit = GetCombatRatingBonus(CR_HIT_SPELL),
        Expertise = GetExpertise(),
        Crit = GetCritChance(),
        Haste = GetHaste(),
        Block = GetBlockChance(),
        ArmorPen = GetCombatRatingBonus(CR_ARMOR_PENETRATION),
        AttackPower = UnitAttackPower("player"),
        SpellPower = GetSpellBonusDamage(7), -- 7 is the magic school for highest spell power
    }
    return stats
end

-- Check stats against caps
local function CheckStatCaps(class, spec, stats)
    local caps = statCaps[class] and statCaps[class][spec]
    local results = {}
    if caps then
        for stat, cap in pairs(caps) do
            if stats[stat] then
                local needed = math.max(0, cap - stats[stat])
                results[stat] = {
                    current = stats[stat],
                    needed = needed,
                    cap = cap,
                }
            end
        end
    end
    return results
end

-- Update stats display
local function UpdateStats()
    local class = select(2, UnitClass("player"))
    local specIndex = GetPlayerSpec()
    local specName = statCaps[class] and next(statCaps[class], specIndex - 1) or "Unknown"
    local stats = GetPlayerStats()
    local caps = CheckStatCaps(class, specName, stats)

    local text = string.format("Class: %s\n", class)
    if specName then
        text = text .. string.format("Spec: %s\n", specName)
    else
        text = text .. "Spec: Unknown\n"
    end

    text = text .. "Stats:\n"
    for stat, values in pairs(caps) do
        text = text .. string.format(
            "- %s (%d): %.2f (%d)\n",
            stat,
            values.cap,
            values.current,
            values.needed
        )
    end

    -- Add uncapped stats
    text = text .. "\nAdditional Stats:\n"
    for stat, value in pairs(stats) do
        if not caps or not caps[stat] then
            text = text .. string.format("- %s: %.2f\n", stat, value)
        end
    end

    StatcapperFrame.statsText:SetText(text)
end

-- Create the addon frame with BackdropTemplate
StatcapperFrame:SetSize(300, 300)
StatcapperFrame:SetPoint("CENTER")
StatcapperFrame:EnableMouse(true)
StatcapperFrame:SetMovable(true)
StatcapperFrame:SetResizable(true)
StatcapperFrame:RegisterForDrag("LeftButton")
StatcapperFrame:SetScript("OnDragStart", StatcapperFrame.StartMoving)
StatcapperFrame:SetScript("OnDragStop", StatcapperFrame.StopMovingOrSizing)

-- Add resizable grip
local resizeGrip = CreateFrame("Frame", nil, StatcapperFrame, "BackdropTemplate")
resizeGrip:SetSize(16, 16)
resizeGrip:SetPoint("BOTTOMRIGHT")
resizeGrip:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up",
})
resizeGrip:SetScript("OnMouseDown", function() StatcapperFrame:StartSizing("BOTTOMRIGHT") end)
resizeGrip:SetScript("OnMouseUp", function() StatcapperFrame:StopMovingOrSizing() end)

-- Define the backdrop
StatcapperFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 16,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
StatcapperFrame:SetBackdropColor(0, 0, 0, 0.8)

-- Add a title text
StatcapperFrame.title = StatcapperFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
StatcapperFrame.title:SetPoint("TOP", StatcapperFrame, "TOP", 0, -10)
StatcapperFrame.title:SetText("Statcapper")

-- Add a text area for stats
StatcapperFrame.statsText = StatcapperFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
StatcapperFrame.statsText:SetPoint("TOPLEFT", StatcapperFrame, "TOPLEFT", 10, -30)
StatcapperFrame.statsText:SetJustifyH("LEFT")
StatcapperFrame.statsText:SetWidth(280)

-- Hook events to update stats
StatcapperFrame:SetScript("OnEvent", UpdateStats)

-- Show the frame initially
StatcapperFrame:Show()
