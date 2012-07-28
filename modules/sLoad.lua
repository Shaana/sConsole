if not sConsole then return end

local mod = sConsole:NewModule("sLoad", "AceEvent-3.0");

local function cmd_load(cmd, arg1, ...)
	loaded, reason = LoadAddOn(arg1)
	sConsole:AddMessage("loading addon: "..arg1)
	if loaded then
		sConsole:AddMessage("success: loaded addon")
	else
		sConsole:AddMessage("fail: couldn't load addon, because it's "..reason)
	end
end

local function cmd_load_dict()
	local t = {}
	for i=1, GetNumAddOns() do
		name, _, _, _, loadable = GetAddOnInfo(i)
		if IsAddOnLoadOnDemand(i) and not IsAddOnLoaded(i) and loadable then
			t[name] = {}
		end
	end
	return t
end

function mod:Enable()
	sConsole:AddCommand("load", cmd_load_dict, cmd_load, "load disabled addons")
end