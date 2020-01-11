--[[----------------------------------------------------------------------------
--
-- QueensCourtHelper
--
----------------------------------------------------------------------------]]--

QueensCourtHelperMixin = { }

local printTag = ORANGE_FONT_COLOR_CODE
                     .. "QueensCourtHelper: "
                     .. FONT_COLOR_CODE_CLOSE

local function printf(fmt, ...)
    local msg = string.format(fmt, ...)
    SELECTED_CHAT_FRAME:AddMessage(printTag .. msg)
end

function QueensCourtHelperMixin:SlashCommand(arg)
    if arg == "show" then
        self:Show()
    elseif arg == "hide" then
        self:Hide()
    elseif arg == "reset" then
        self:ClearAllPoints()
        self:SetPoint("LEFT")
        self:SetUserPlaced('false')
    else
        printf("/qch show | hide | reset")
    end
    return true
end

function QueensCourtHelperMixin:SetupSlashCommand()
    SlashCmdList['QueensCourtHelper'] = function (...) self:SlashCommand(...) end
    _G.SLASH_QueensCourtHelper1 = "/qch"

end

function QueensCourtHelperMixin:OnLoad()
    printf('Initialized.')
    self:SetupSlashCommand()

    self.Salute:SetAttribute('type', 'macro')
    self.Curtsey:SetAttribute('type', 'macro')
    self.Applause:SetAttribute('type', 'macro')
    self.Grovel:SetAttribute('type', 'macro')
    self.Kneel:SetAttribute('type', 'macro')
    self.Salute:SetAttribute('macrotext', '/target Queen Azshara\n/salute\n/targetlasttarget')
    self.Curtsey:SetAttribute('macrotext', '/target Queen Azshara\n/curtsey\n/targetlasttarget')
    self.Applause:SetAttribute('macrotext', '/target Queen Azshara\n/applause\n/targetlasttarget')
    self.Grovel:SetAttribute('macrotext', '/target Queen Azshara\n/grovel\n/targetlasttarget')
    self.Kneel:SetAttribute('macrotext', '/target Queen Azshara\n/kneel\n/targetlasttarget')

    self:RegisterEvent("ENCOUNTER_START")
    self:RegisterForDrag("LeftButton")
end

function QueensCourtHelperMixin:OnEvent(event, ...)
    local arg1 = ...
    if event == "PLAYER_LOGIN" then
        self:Initialize()
    elseif event == "ENCOUNTER_START" and arg1 == 2311 then
        self:Show()
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
    elseif event == "PLAYER_REGEN_ENABLED" and self:IsShown() then
        self:Hide()
        self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        self:UnregisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    elseif event == "CHAT_MSG_RAID_BOSS_EMOTE" then
        self:CMRBE(...)
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        self:CLEU()
    end
end

function QueensCourtHelperMixin:SetHighlight(frame)
    for _,f in ipairs({ self.Salute, self.Curtsey, self.Applause, self.Grovel, self.Kneel}) do
        if frame == f then
            f:LockHighlight()
        else
            f:UnlockHighlight()
        end
    end
end

function QueensCourtHelperMixin:CMRBE(msg, npc, _, _, target)
    if msg:find("spell:298050") then        -- Form Ranks
        self:SetHighlight(self.Salute)
    elseif msg:find("spell:297566") then    -- Deferred Sentence
        self:SetHighlight(self.Grovel)
    end
end

function QueensCourtHelperMixin:CLEU()
    local _, e, _, _, _, _, _, dstGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
    if dstGUID ~= UnitGUID('player') then return end
    if e == "SPELL_AURA_APPLIED" then
        if spellID == 301244 then           -- Repeat Performance
            self.SetHighlight(self.Curtsey)
        elseif spellID == 297656 then       -- Stand Alone
            self.SetHighlight(self.Applause)
        elseif spellID == 297585 then       -- Obey or Suffer
            self.SetHighlight(self.Kneel)
        end
    end
end
