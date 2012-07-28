--[[----------------------------------------------------------------------------------------
	[sConsol is a simple Ace3 Addon]

	Copyright (C) 2011, Share

	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published
	by the Free Software Foundation; either version 3 of the License,
	or (at your option) any later version.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with this program;
	if not, see <http://www.gnu.org/licenses/>.
------------------------------------------------------------------------------------------]]

sConsole = LibStub("AceAddon-3.0"):NewAddon("sConsole", "AceEvent-3.0");

local _G = getfenv(0);	

BINDING_HEADER_SHARECONSOLETITLE = "Share Console";
BINDING_NAME_SHARECONSOLETOGGLE = "Toggle the Share console";

local sConsoleFrame = CreateFrame("Frame", "sConsoleFrame", UIParent);

function string.startswith(sbig, slittle)
  if type(slittle) == "table" then
    for k,v in ipairs(slittle) do
      if string.sub(sbig, 1, string.len(v)) == v then 
        return true
      end
    end
    return false
  end
  return string.sub(sbig, 1, string.len(slittle)) == slittle
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

local function get_words(cur_string)
	--get words
	local words = {}
	for word in string.gmatch(cur_string, "[A-Z0-9a-z_.-]+") do 
		table.insert(words, word)
	end
	return words
end

local function fill_space(count)
	local str = ""
	for i = 1, count do
		str = str.." "
	end
	return str
end

local function print_valid_cmds(t)
	for i,v in ipairs(t) do
		sConsole:AddMessage(v)
	end

	if t then
		local s = sConsoleSettings
		local char_len = s.ConsoleFontSize
		local safety_len = 5
		local max_len = 1
		--find 'longest' string
		for i,v in ipairs(t) do
			local cur_len = string.len(v)
			if cur_len > max_len then
				max_len = cur_len
			end
		end
		--include 2* safety for both borders and a safety_len after every column
		local column_width = max_len + safety_len
		local num_column = math.floor((s.ConsoleWidth - 2*safety_len)/column_width)
		
		local lines_to_print = {}
		local num_lines = math.ceil(#t/num_column)
		for i=1, #t do
			space_to_fill = column_width - string.len(t[i])*char_len
			cur_line = i % num_lines
			if not lines_to_print[cur_line] then
				lines_to_print[cur_line] = ""
			end
			print(space_to_fill/char_len) --BUG neg
			lines_to_print[cur_line] = lines_to_print[cur_line]..t[i]..fill_space(space_to_fill/char_len)
		end
		
		for i,v in ipairs(lines_to_print) do
			print(v)
			sConsole:AddMessage(v)
		end
		
		--s.ConsoleWidth
	end
	--GetStringWidth()
	--TODO, multiple on one line for better overview
	--table.foreachi(t, print)
end

--[[ basic functions ]]

local function cmd_help(cmd, arg1, ...)
	if sConsoleFrame.command[arg1].func_help then
		sConsole:AddMessage(sConsoleFrame.command[arg1].func_help)
	else	
		sConsole:AddMessage("Error: You're on your own! For this command it doesn't exist a help entry.")
	end
end

local function cmd_help_dict()
	local t = {}
	for k,v in pairs(sConsoleFrame.command) do
		t[k] = {}
	end
	return t
end

local function cmd_quit()
	sConsole:DisableConsole()
end

local function cmd_quit_dict()
	return {}
end

function sConsole:OnInitialize()
	--NOTE: Royal Blue: (65, 105, 225)
	--NOTE: Sea Green: 	(46, 139, 87)
	sConsole:CreateConsole();
	
	sConsoleFrame.command = {}

	--create the basic commands
	sConsole:AddCommand("help", cmd_help_dict, cmd_help, "The basic help function. Provides help for every listed command.")
	sConsole:AddCommand("quit", cmd_quit_dict(), cmd_quit, "quit the console")
	
	--load modules
	sConsoleFrame.module = {}
	for name, module in self:IterateModules() do
		sConsoleFrame.module[name] = module
		module:Enable()
	end
end

function sConsole:OnEnable()
	sConsole:AddMessage("testi                  xxxxfasfds     fffsf")
	sConsole:AddMessage("asdfasfdsfsdf          morxxx         aaaaaaaaaaaa")
	s = sConsoleSettings
	sConsole:SetPrefix(s.ConsolePrefix)
end

function sConsole:OnDisable()
	--not implemented
end

---create the necessary frames for the console
function sConsole:CreateConsole()
	local s = sConsoleSettings;
	-- s being the ScrollingMessageFrame, e the editbox, p the prefix
	local m, e, p;
	
	local function t(frame)
		local t = frame:CreateTexture(nil,"BACKGROUND");
		t:SetAllPoints(frame);
		t:SetTexture(s.ConsoleTexture);
		t:SetVertexColor(unpack(s.ConsoleColor));
		t:Show()
		return t;
	end
	
	local function f(frame)
		frame:SetFont(s.ConsoleFont, s.ConsoleFontSize, s.ConsoleFontStyle);
		frame:SetTextColor(unpack(s.ConsoleFontColor));
	end
	
	--header frame
	m = CreateFrame("ScrollingMessageFrame", "sConsoleFrame_MessageFrame", sConsoleFrame);
	m:SetPoint(unpack(s.ConsoleFrameAnchor));
	m:SetHeight(s.ConsoleHeight);
	m:SetWidth(s.ConsoleWidth);
	m:SetFrameStrata("DIALOG");
	f(m);
	m:SetJustifyH("LEFT");
	m:SetMaxLines(s.ConsoleMaxLines);
	m:SetFading(s.ConsoleTextFading);
	m:Hide();
  
  --Scrolling
	m:EnableMouseWheel(true)
	m:SetScript("OnMouseWheel", function(self, delta)
		if delta > 0 then
			self:ScrollUp()
		else
			self:ScrollDown()
		end
	end);

	sConsoleFrame.MessageFrame = m
	sConsoleFrame.MessageFrame.texture = t(m)
	
	--editBox frame
	e = CreateFrame("EditBox", nil, sConsoleFrame);
	--TODO so far 5 px spacing between editbox/consoleframe
	e:SetPoint("TOP", m, "BOTTOM", s.ConsoleEditBoxXOffset, s.ConsoleEditBoxYOffset);
	e:SetHeight(s.ConsoleFontSize + 2*s.ConsoleEditBoxTextInset);
	e:SetWidth(s.ConsoleWidth);
	f(e);
	e:SetFrameStrata("DIALOG");
	e:SetAutoFocus(false);
	--TODO
	e:SetTextInsets(s.ConsoleEditBoxTextInset, s.ConsoleEditBoxTextInset, 0, 0);
	e:Hide();
	
	--Enable arrow keys (to be able to use them without alt modifier pressed)
	e:SetAltArrowKeyMode(false);
	e:SetHistoryLines(s.ConsoleEditBoxMaxHistoryLines);
	
	e:SetScript("OnEscapePressed", function(self)
		if self:GetText() ~= "" then
			self:SetText("");
		else
			sConsole:DisableConsole();
		end
	end);
	e:SetScript("OnEnterPressed", function(self)
	  	if self:GetText() ~= "" then
	  		local cur_string = self:GetText()
		  	m:AddMessage(p:GetText()..cur_string)
		  	--TODO save history to a DB
		  	self:AddHistoryLine(cur_string)
		  	
		  	sConsole:RunCommand(cur_string)
		  	self:SetText("")
	  	end
  	end);
	e:SetScript("OnEditFocusLost", function(self)  
		sConsole:DisableConsole()
	end);
	e:SetScript("OnTabPressed", function(self)
		sConsole:CompleteCommand(e)
	end);

	sConsoleFrame.EditBox = e;
	sConsoleFrame.EditBox.texture = t(e);
	
	-- prefix on the EditBox, called 'editBox header'
	p = e:CreateFontString(nil, "OVERLAY");
	f(p);
	--TODO
	p:SetPoint("LEFT", e, 5, 0);
	p:Hide();
	
	sConsoleFrame.Prefix = p
		
	sConsoleFrame.isEnabled = false;
end

--TODO delete, not needed anymore
function sConsole:ToggleConsole()
	if sConsoleFrame.isEnabled then
		sConsole:DisableConsole()
	else
		sConsole:EnableConsole()
	end
end

---activate the console
--show frames, (set defaults)
function sConsole:EnableConsole()
	local console = sConsoleFrame
	--show frames
	console.MessageFrame:Show()
	console.EditBox:Show()
	console.Prefix:Show()
	
	--Increases the frame's frame level above all other frames in its strata ("DIALOG")
	console:Raise();
	console.EditBox:Raise();
	
	--set focus
	console.EditBox:SetFocus();
	
	--change status
	console.isEnabled = true;
end

---deactivate the console 
--hide frames
function sConsole:DisableConsole()
	local console = sConsoleFrame
	--hide frames
	console.MessageFrame:Hide();
	console.EditBox:Hide();
	console.Prefix:Hide();
	
	--clear focus
	console.EditBox:ClearFocus();

	--change status
	console.isEnabled = false;
end

function sConsole:RunCommand(cur_string)
	local words = get_words(cur_string)
	if sConsoleFrame.command[words[1]] then
		sConsoleFrame.command[words[1]].func(unpack(words))
	else
		--TODO
		--sConsole:AddMessage()
	end
end

---add a command to the sConsoleFrame command-table
function sConsole:AddCommand(cmd, cmd_table, func, func_help)
	--HELP: cmd_table can either be a function or a table
	if not sConsoleFrame.command[cmd] then
		if type(cmd_table) == "table" then
			sConsoleFrame.command[cmd] = cmd_table
		elseif type(cmd_table) == "function" then
			sConsoleFrame.command[cmd] = {}
			sConsoleFrame.command[cmd].table_func = cmd_table
		else
			sConsoleFrame.command[cmd] = {}
		end
		sConsoleFrame.command[cmd].func = func
		sConsoleFrame.command[cmd].func_help = func_help
	else
		print("Error: Cannot add"..cmd.." : Command already exists.")
	end
end

function sConsole:RemoveCommand(cmd)
	--TODO
	--NOT TESTED
	--might behave wrong when trying to re-add a cmd with same key name
	if sConsoleFrame.command[cmd] then
		sConsoleFrame.command[cmd] = nil
	end
end

function sConsole:SetPrefix(text)
	local s = sConsoleSettings
	sConsoleFrame.Prefix:SetText(text)
	--TODO delete
	--print(sConsoleFrame.Prefix:GetHeight())
	--print(sConsoleFrame.Prefix:GetWidth())
	--print(sConsoleFrame.Prefix:GetStringWidth())
	sConsoleFrame.EditBox:SetTextInsets(s.ConsoleEditBoxTextInset + sConsoleFrame.Prefix:GetStringWidth(), s.ConsoleEditBoxTextInset, 0, 0)
end

--TODO
function sConsole:PrintError(error, help, module)

end

function sConsole:AddMessage(msg)
	sConsoleFrame.MessageFrame:AddMessage(msg)
end

function sConsole:CompleteCommand(editbox)
	local cur_string = editbox:GetText()
	
	--get words
	local words = get_words(cur_string)
	
	--if last char is space, then add empty string to words
	--basically add an 'empty' word -> sConsole:FindValidCmd prints all possible cmds (since they all start with "" (empty string).)
	--string.len(cur_string) == 0 is need to make it work for the very first commands
	--this is needed to let the program know when the next word begins
	if string.sub(cur_string,string.len(cur_string))== " " or string.len(cur_string) == 0 then
		table.insert(words, "")
	end

	--create referenz to the table with the current cmds
	local c = sConsoleFrame.command
	for i=1, #words -1 do
		if c then
			c = c[words[i]]
		end
	end

	--check if the command so far exists
	if c then
		--if it c.table_func exists, create the table with this function during runtime, else just take the given table
		local complete_string, t = sConsole:FindValidCmd(words[#words], c.table_func and c.table_func() or c)
		if complete_string == "" then
			print_valid_cmds(t)
		else
			editbox:SetText(cur_string..complete_string)
		end
		if #t == 1 then
			editbox:SetText((editbox:GetText()).." ")
		end
		
	end
end

function sConsole:FindValidCmd(cur_string, cmd_dict)
	--return a table of possible commands and a complete_string
	local t = {}
	local complete_string = ""
	local protected_key = {"func", "func_help", "table_func"} 
	
	--find all possible commands
	for k,v in pairs(cmd_dict) do
		if string.startswith(k, cur_string) then
			if not table.contains(protected_key, k) then
				table.insert(t, k)
			end
		end
	end
	
	--find the complete_string
	--take the string.len(cur_string) + 1 letter and check if every command has it. If true, check the 2nd letter, etc.
	--has at least one valid command
	if t[1] then
		local match = true
		for i = string.len(cur_string) + 1, string.len(t[1]) do
			local match_string = string.sub(t[1], i, i)
			for _,v in ipairs(t) do
				if not (match_string == string.sub(v, i, i)) then
					match = false
					break	
				end
			end
			if match then
				complete_string = complete_string..match_string
			else
				break
			end
		end
	end

	return complete_string, t
end



