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

local sConsoleFrame;

function sConsole:OnInitialize()

	--NOTE: Royal Blue: (65, 105, 225)
	--NOTE: Sea Green: 	(46, 139, 87)
	sConsole:CreateConsole();
end

function sConsole:OnEnable()
	--load modules
	local modList = {};
	for name, module in self:IterateModules() do
		modList[name] = module;
	  module:Enable();
	end
	sConsoleFrame.module = modList;
	
	sConsoleFrame:SetPrefix("> ")
	
	sConsoleFrame.command = {		["help"] = "C1",
															["her"] = "C2",
															["hef"] = "C3",
															["heu"] = "C4",
															["here"] = "C5",
															["heee"] = "C6",
															
	};
	
end

function sConsole:OnDisable()
	--not implemented
end

---create the necessary frames for the console
function sConsole:CreateConsole()
	local s = sConsoleSettings;
	-- c being the console, e the editbox, p the prefix
	local c, e, p;
	
	local function t(frame)
		local t = frame:CreateTexture(nil,"BACKGROUND");
		t:SetAllPoints(frame);
		t:SetTexture(s.ConsoleTexture);
		t:SetVertexColor(unpack(s.ConsoleColor));
		return t;
	end
	
	local function f(frame)
		frame:SetFont(s.ConsoleFont, s.ConsoleFontSize, s.ConsoleFontStyle);
		frame:SetTextColor(unpack(s.ConsoleFontColor));
	end
	
	--header frame
	c = CreateFrame("ScrollingMessageFrame", "sConsoleFrame", UIParent);
	c:SetPoint(unpack(s.ConsoleFrameAnchor));
  c:SetHeight(s.ConsoleHeight);
  c:SetWidth(s.ConsoleWidth);
  c:SetFrameStrata("DIALOG");
  f(c);
  c:SetJustifyH("LEFT");
  c:SetMaxLines(s.ConsoleMaxLines);
  c:SetFading(s.ConsoleTextFading);
  c:Hide();
  
  --Scrolling
	c:EnableMouseWheel(true);
	c:SetScript("OnMouseWheel", function(self, delta)
		if delta > 0 then
			self:ScrollUp();
		else
			self:ScrollDown();
		end
	end);

  c.command = {};
	c.texture = t(c);
	
	--editBox frame
	e = CreateFrame("EditBox", nil, c);
	--TODO so far 5 px spacing between editbox/consoleframe
	e:SetPoint("TOP", c, "BOTTOM", s.ConsoleEditBoxXOffset, s.ConsoleEditBoxYOffset);
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
			sConsole:DisableConsole(c);
		end
	end);
  e:SetScript("OnEnterPressed", function(self)
  	if self:GetText() ~= "" then 
	  	c:AddMessage(self:GetText());
	  	--TODO save history to a DB
	  	self:AddHistoryLine(self:GetText());
	  	self:SetText("");
  	end
  end);
  e:SetScript("OnEditFocusLost", function(self)  
  	sConsole:DisableConsole(c);
  end);
  e:SetScript("OnTabPressed", function(self)
  	print("tab")  
  	sConsole:AutoCompleteText(c, self:GetText());
  end);

	c.editBox = e;
	c.editBox.texture = t(e);
	
	
	-- prefix on the EditBox, called 'editBox header'
	p = e:CreateFontString(nil, "OVERLAY");
	f(p);
	--TODO
	p:SetPoint("LEFT", e, 5, 0);
	p:Hide();
	
	c.editBox.prefix = p;
	
	function c:SetPrefix(text)
		p:SetText(text);
		e:SetTextInsets(s.ConsoleEditBoxTextInset + p:GetStringWidth(), s.ConsoleEditBoxTextInset, 0, 0);
	end
	
	c.isEnabled = false;
	
	sConsoleFrame = c;
end

function sConsole:ToggleConsole()
	if sConsoleFrame.isEnabled then
		sConsole:DisableConsole(sConsoleFrame);
	else
		sConsole:EnableConsole(sConsoleFrame);
	end
end

---activate the console
--show frames, (set defaults)
function sConsole:EnableConsole(console)
	--show frames
	console:Show();
	console.editBox:Show();
	console.editBox.prefix:Show();
	
	--Increases the frame's frame level above all other frames in its strata ("DIALOG")
	console:Raise();
	console.editBox:Raise();
	
	--set focus
	console.editBox:SetFocus();
	
	--change status
	console.isEnabled = true;
end

---deactivate the console 
--hide frames
function sConsole:DisableConsole(console)
	--hide frames
	console:Hide();
	console.editBox:Hide();
	console.editBox.prefix:Hide();
	
	--clear focus
	console.editBox:ClearFocus();

	--change status
	console.isEnabled = false;
end

---add a command to the sConsoleFrame command-table
function sConsole:AddCommand()

end

function sConsole:AutoCompleteText(console, text)
	--terribly inefficent, even if there is only 2 commans left in the possible_coms, the next tab is gonna call autocomplete again!
	--try something like sConsoleFrame:OnTab() --> then override the function in AutoCompleteText()
	-- if possible_coms shows up cmd found or error --> restore sConsoleFrame:OnTab() to AutoCompleteText()
	--simply call AutoCompleteText with a different table, prob should change to word/text pars (see below)

-- prob better change paras to 'word', 'table' so we can use this function for sub commands as well (just paste sub table then)
	local possible_coms = {};
	--DOESNT WORK
	local numSameChars = 20;
	
	for k,v in pairs(console.command) do
		--print(k)
		--print(v)
		--prob replace with while, cause break sucks
		--print(string.len(text))

		for i = 1, string.len(text) do
			if string.sub(text, i, i) == string.sub(k, i, i) then
				--goood
				print("i:"..i);
				if i == string.len(text) then
					possible_coms[#possible_coms + 1] = k;
				end
			else
				print("i_break:"..i);
				if i < numSameChars then
					print("i:"..i);
					print("num:"..numSameChars);
					numSameChars = i;
				end
				break;
			end

		end
	end

	if #possible_coms == 1 then
		-->command found
		print("cmd found");
		print(numSameChars)
		console.editBox:SetText(possible_coms[1].." ");
	elseif #possible_coms > 1 then
		print("many");
		print(numSameChars);
		for k,v in pairs(possible_coms) do
			print(v)
		end
	elseif #possible_coms == 0 then
		print("0");
		print(numSameChars);
	end
	
	
end