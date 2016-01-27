-- Author      : Ignifazius

local carrierName = "NOBODY"
local lastCarrier = "XX";
local scanEnabled = false;
local holdingSince = 0;
local flameTable = {};
local hiscoreTable;
local lastCarrierTime = 0;
local tableindex = 1;


local sBFrame = CreateFrame("Frame","statusBarFrame",UIParent)
	sBFrame:SetFrameStrata("BACKGROUND")
	sBFrame:SetWidth(220)
	sBFrame:SetHeight(40)
local sBTexture = sBFrame:CreateTexture(nil,"BACKGROUND")
	sBTexture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
	sBTexture:SetAllPoints(sBFrame)
	sBFrame.texture = sBTexture
	sBFrame:SetPoint("RIGHT", -150, 170)
	sBFrame:Show()

	sBFrame:SetMovable(true)
	sBFrame:EnableMouse(true)
	sBFrame:RegisterForDrag("LeftButton")
	sBFrame:SetScript("OnDragStart", sBFrame.StartMoving)
	sBFrame:SetScript("OnDragStop", sBFrame.StopMovingOrSizing)
	
    local sbtext = sBFrame:CreateFontString(nil, "OVERLAY")
	sbtext:SetFont("Fonts\\ARIALN.TTF", 18, nil)
	sbtext:SetPoint("CENTER",0,0)
	sbtext:SetText(carrierName)
	sBFrame.text = sbtext;


local scanButton = CreateFrame("Button", "Buff", statusBarFrame)
	scanButton:SetPoint("TOPLEFT", statusBarFrame, 0, 15)
	scanButton:SetWidth(100)
	scanButton:SetHeight(25)
	local text = scanButton:CreateFontString(nil, "OVERLAY")
	text:SetFont("Fonts\\ARIALN.TTF", 11, nil)
	text:SetPoint("CENTER",-19,5)
	text:SetText("start scan")
	scanButton.text = text
	scanButton:SetNormalFontObject("GameFontNormalSmall")       
	scanButton:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
	scanButton:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	scanButton:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")
	scanButton:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			scanEnabled = not scanEnabled;
			if scanEnabled then
				text:SetText("stop")
			else
				text:SetText("start")
			end
			
		elseif button == "RightButton" then
			sBFrame:Hide();
		end
	end)
	
	
local flameButton = CreateFrame("Button", "Buff", statusBarFrame)
	flameButton:SetPoint("TOPLEFT", statusBarFrame, 70, 15)
	flameButton:SetWidth(100)
	flameButton:SetHeight(25)
	local text2 = flameButton:CreateFontString(nil, "OVERLAY")
	text2:SetFont("Fonts\\ARIALN.TTF", 11, nil)
	text2:SetPoint("CENTER",-19,5)
	text2:SetText("FLAME")
	flameButton.text = text2
	flameButton:SetNormalFontObject("GameFontNormalSmall")       
	flameButton:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
	flameButton:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	flameButton:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")
	flameButton:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			flameActual();		
		elseif button == "RightButton" then
		end
	end)
	
local flameAllButton = CreateFrame("Button", "Buff", statusBarFrame)
	flameAllButton:SetPoint("TOPLEFT", statusBarFrame, 140, 15)
	flameAllButton:SetWidth(100)
	flameAllButton:SetHeight(25)
	local text3 = flameAllButton:CreateFontString(nil, "OVERLAY")
	text3:SetFont("Fonts\\ARIALN.TTF", 11, nil)
	text3:SetPoint("CENTER",-19,5)
	text3:SetText("FLAME ALL")
	flameAllButton.text = text3
	flameAllButton:SetNormalFontObject("GameFontNormalSmall")       
	flameAllButton:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
	flameAllButton:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	flameAllButton:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")
	flameAllButton:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			printFlameList();
		elseif button == "RightButton" then
		end
	end)
	
	
	
local debugButton = CreateFrame("Button", "Buff", statusBarFrame)
	debugButton:SetPoint("TOPLEFT", statusBarFrame, 0, 40)
	debugButton:SetWidth(100)
	debugButton:SetHeight(25)
	local text4 = debugButton:CreateFontString(nil, "OVERLAY")
	text4:SetFont("Fonts\\ARIALN.TTF", 11, nil)
	text4:SetPoint("CENTER",-19,5)
	text4:SetText("debug")
	debugButton.text = text3
	debugButton:SetNormalFontObject("GameFontNormalSmall")       
	debugButton:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
	debugButton:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	debugButton:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")
	debugButton:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			addToList(tableindex, "1.5" , "Test_"..tableindex);		
			tableindex = tableindex+1;
		elseif button == "RightButton" then
		end
	end)
	
	
	
function findBuff(target)
	if (target ~= nil) then
		for i= 1, 40 do
			local name, _, _, _, _, duration, expirationTime, _, _, _, spellId = UnitAura(target,i);
			--if (spellId == 21562) then --debug: machtwort seele
			if (spellId == 179202) then --live: eye of anzu
				carrierName = UnitName(target);
				return true;
			end
		end
		return false;
	end
end

function round(number, decimals)
    return (("%%.%df"):format(decimals)):format(number)
end

function countTime()
	local seconds = GetTime();
	local diff = seconds - holdingSince;
	return round(diff, 2);
end

function scanRaidForBuff() 
	local count = GetNumGroupMembers();
	for raidIndex=1, count do
		--name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(raidIndex);
		name, _, _, _, _, _, _, _, _, _, _ = GetRaidRosterInfo(raidIndex);
		local unit = "raid"..raidIndex
		if findBuff(unit) then
			carrierName = name;
			break;
		else
			carrierName = "NOBODY";
		end;
	end
end

function addToList(count, time, name)
	print("adding "..name.." to list");
	if name ~= "NOBODY" then
		local str = name.. " - "..time;
		flameTable[count] = str;
		print("tablesize: "..table.getn(flameTable))
	end
end

function flameActual() 
	local message = carrierName.." is holding the Eye for "..countTime().." seconds.";
	--TODO detect lfr? -.-
	SendChatMessage(message, "RAID");
end

function printFlameList() 
	local j = table.getn(flameTable);
	local max = 15;
	if j < max then
		max = j;
	end
	for i=1, max do
		local message = i.." "..flameTable[j-i+1];
		--TODO detect lfr? -.-
		SendChatMessage(message, "RAID");
	end
end


local updater=CreateFrame("Frame")
updater:SetScript("OnUpdate", function(self)
	if (scanEnabled and IsInRaid()) then
		scanRaidForBuff()
		if (lastCarrier == carrierName) then
			--keep time / do nothing
			lastCarrierTime = countTime();
		else
			addToList(tableindex, lastCarrierTime, lastCarrier);
			tableindex = tableindex+1;
			lastCarrier = carrierName;
			holdingSince = GetTime();
		end
		if (tonumber(countTime()) < 1 and carrierName == "NOBODY") then
			sbtext:SetText("");
		else
			sbtext:SetText(carrierName.." "..countTime());
		end
		sBFrame.text = sbtext;
	end
end)



SLASH_ISKARFLAMEASSIST1 = '/ifa';


local function handler(msg, editbox)
	local command, rest = msg:match("^(%S*)%s*(.-)$");
	if command == "show" then
		sBFrame:Show();
	elseif command == "hide" then
		sBFrame:Hide();
	end
end

SlashCmdList["ISKARFLAMEASSIST"] = handler;