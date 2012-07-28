--we can move that mod to sZoneFrame later
local mod = sConsole:NewModule("sChatFrame", "AceEvent-3.0");
local sConsole = sConsole;
local _G = _G;

function mod:Enable()
	print("bab")
	--self:ShowFrame(3);
	--do nothing :) [so far]
	--run sConsole:AddCommand();
end

function mod:ShowFrame(index)
	--show frames
	_G["ChatFrame"..index]:Show();
	_G["ChatFrame"..index.."Tab"]:Show();
	
	local chatTypes = {"SAY",
	 									"EMOTE,TEXT_EMOTE", 
	 									"YELL",
	 									"MONSTER_SAY",
	 									"MONSTER_PARTY",
	 									"MONSTER_YELL",
	 									"MONSTER_WHISPER",
	 									"MONSTER_EMOTE",
	 									"BATTLEGROUND",
	 									"BATTLEGROUND_LEADER",
	 									"BOSS_EMOTE",
	 									"BOSS_WHISPER",
	 									"CHANNEL_JOIN",
	 									"CHANNEL_LEAVE",
	 									"CHANNEL_NOTICE",
	 									"CHANNEL_NOTICE_USER",
	 									"CHANNEL_LIST",
	 									"ACHIEVEMENT",
	 									"GUILD_ACHIEVEMENT",
	 									"TARGETICONS",
	 									"CHANNEL1",
	 									"CHANNEL2",
	 									"CHANNEL3",
	 									"CHANNEL4",
	 									"CHANNEL5",
	 									"SYSTEM_NEUTRAL",
	 									"SYSTEM_ALLIANCE",
	 									"SYSTEM_HORDE",
	 									"MONEY",
	 									"OPENING",
	 									"PET_INFO",
	 									"COMBAT_MISC_INFO",
	 									};
	 									
	for _, v in ipairs(chatTypes) do
		print("hu")
		AddChatWindowMessages(index, "CHAT_MSG_"..v);
	end
	
end

function mod:HideFrame(index)

end