-- Author      : Ignifazius

local carrierName = "NOBODY"
local lastCarrier = "XX";
local scanEnabled = false;
local holdingSince = 0;


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


local debugButton = CreateFrame("Button", "Buff", statusBarFrame)
	debugButton:SetPoint("TOPLEFT", statusBarFrame, 0, 15)
	debugButton:SetWidth(100)
	debugButton:SetHeight(25)
	local text = debugButton:CreateFontString(nil, "OVERLAY")
	text:SetFont("Fonts\\ARIALN.TTF", 11, nil)
	text:SetPoint("CENTER",-19,5)
	text:SetText("start scan")
	debugButton.text = text
	debugButton:SetNormalFontObject("GameFontNormalSmall")       
	debugButton:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
	debugButton:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	debugButton:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")
	debugButton:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			scanEnabled = not scanEnabled;
			if scanEnabled then
				text:SetText("stop")
			else
				text:SetText("start")
			end
			
		elseif button == "RightButton" then
			scanEnabled = false;
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

local updater=CreateFrame("Frame")
updater:SetScript("OnUpdate", function(self)
	if (scanEnabled and IsInRaid()) then
		scanRaidForBuff()
		if (lastCarrier == carrierName) then
			--keep time / do nothing
		else
			lastCarrier = carrierName;
			holdingSince = GetTime();
		end
		sbtext:SetText(carrierName.." "..countTime())
		sBFrame.text = sbtext;
	end
end)
