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
        FERAL = { Hit = 8, Expertise = 26, Crit = 25 },
        RESTORATION = { Haste = 20 },
    },
    HUNTER = {
        BEASTMASTERY = { Hit = 8, Crit = 25 },
        MARKSMANSHIP = { Hit = 8, Crit = 25 },
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
        ASSASSINATION = { Hit = 8, Expertise = 26, Crit = 25 },
        COMBAT = { Hit = 8, Expertise = 26, Crit = 25 },
        SUBTLETY = { Hit = 8, Expertise = 26, Crit = 25 },
    },
    SHAMAN = {
        ELEMENTAL = { Hit = 17, Crit = 20 },
        ENHANCEMENT = { Hit = 8, Expertise = 26, Haste = 15 },
        RESTORATION = { Haste = 20 },
    },
    WARLOCK = {
        AFFLICTION = { Hit = 17, Crit = 20 },
        DEMONOLOGY = { Hit = 17, Crit = 20 },
        DESTRUCTION = { Hit = 17, Crit = 20 },
    },
    WARRIOR = {
        ARMS = { Hit = 8, Expertise = 26, Crit = 25 },
        FURY = { Hit = 8, Expertise = 26, Crit = 25 },
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
                results[stat] = stats[stat] >= cap and "Capped" or "Not Capped"
            end
        end
    end
    return results
end

-- Update stats display
local function UpdateStats()
    local class = select(2, UnitClass("player"))
    local specIndex = GetPlayerSpec()
    local spec = specIndex and ({ "BLOOD", "FROST", "UNHOLY" })[specIndex] -- Example for DKs
    local stats = GetPlayerStats()
    local caps = CheckStatCaps(class, spec, stats)

    local text = string.format("Class: %s\n", class)
    if spec then
        text = text .. string.format("Spec: %s\n", spec)
    else
        text = text .. "Spec: Unknown\n"
    end

    text = text .. "Stats:\n"
    for stat, value in pairs(stats) do
        local capStatus = caps and caps[stat] or "No Cap"
        text = text .. string.format("- %s: %.2f (%s)\n", stat, value, capStatus)
    end

    StatcapperFrame.statsText:SetText(text)
end

-- Create the UI frame
StatcapperFrame:SetSize(250, 150)
StatcapperFrame:SetPoint("CENTER")
StatcapperFrame:EnableMouse(true)
StatcapperFrame:SetMovable(true)
StatcapperFrame:RegisterForDrag("LeftButton")
StatcapperFrame:SetScript("OnDragStart", StatcapperFrame.StartMoving)
StatcapperFrame:SetScript("OnDragStop", StatcapperFrame.StopMovingOrSizing)

StatcapperFrame.bg = StatcapperFrame:CreateTexture(nil, "BACKGROUND")
StatcapperFrame.bg:SetAllPoints(true)
StatcapperFrame.bg:SetColorTexture(0, 0, 0, 0.5)

StatcapperFrame.statsText = StatcapperFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
StatcapperFrame.statsText:SetPoint("TOPLEFT", StatcapperFrame, "TOPLEFT", 10, -10)

StatcapperFrame:SetScript("OnEvent", UpdateStats)
