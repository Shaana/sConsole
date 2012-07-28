if not sConsole then return end

local mod = sConsole:NewModule("sInvite", "AceEvent-3.0");

--allows you to set rules, tags to invite ppl
--f.e if someone whispers a certain string, invite the person.


local cmd_table = {
	

}

local function filter_whisper()

end

function mod:Enable()
	sConsole:AddCommand("invite", nil, nil, "invite helper")
end


--	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filter_whisper)
--	self:RegisterEvent("CHAT_MSG_WHISPER")