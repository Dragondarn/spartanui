local spartan = LibStub("AceAddon-3.0"):GetAddon("SpartanUI");
local addon = spartan:NewModule("PartyFrames");
----------------------------------------------------------------------------------------------------
local default = {showAuras = 1,partyLock = 1};
suiChar.PartyFrames = suiChar.PartyFrames or {};
setmetatable(suiChar.PartyFrames,{__index = default});
if (not spartan:GetModule("PlayerFrames",true)) then
	-- only do this stuff if PlayerFrames isn't loaded
	do -- ClassIcon as an oUF module
		local ClassIconCoord = {
			WARRIOR = {1,1},
			MAGE = {1,2},
			ROGUE = {1,3},
			DRUID = {1,4},
			HUNTER = {2,1},
			SHAMAN = {2,2},
			PRIEST = {2,3},
			WARLOCK = {2,4},
			PALADIN = {3,1},
			DEATHKNIGHT = {3,2},
			DEFAULT = {4,4}, -- transparent so hidden by default
		};
		local Update = function(self,event,unit)
			if (self.ClassIcon) then
				local _,class = UnitClass(unit);
				local col, row = ClassIconCoord[class or "DEFAULT"][1],ClassIconCoord[class or "DEFAULT"][2];
				local left, top = (row-1)*0.25,(col-1)*0.25;
				self.ClassIcon:SetTexture([[Interface\AddOns\SpartanUI_PlayerFrames\media\icon_class]]);
				self.ClassIcon:SetTexCoord(left,left+0.25,top,top+0.25);
			end
		end
		local Enable = function(self)
			if (self.ClassIcon) then return true; end
		end
		local Disable = function(self) return; end
		oUF:AddElement('SpartanClass', Update,Enable,Disable);
	end
	do -- AFK / DND status text, as an oUF module
		if not oUF.Tags["[afkdnd]"] then
			oUF.Tags["[afkdnd]"] = function(unit)
				if unit then
					return UnitIsAFK(unit) and "AFK" or UnitIsDND(unit) and "DND" or "";
				end
			end;
			oUF.TagEvents["[afkdnd]"] = "PLAYER_FLAGS_CHANGED PLAYER_TARGET_CHANGED UNIT_TARGET";		
		end
	end
end

local bar_texture = [[Interface\TargetingFrame\UI-StatusBar]]
local colors = setmetatable({},{__index = oUF.colors});
do -- setup customized colors
	colors.health = {0/255,255/255,50/255};
	colors.reaction = {};
	colors.reaction[1] = {0.8,0.3,0}; -- Hated
	colors.reaction[2] = colors.reaction[1]; -- Hostile
	colors.reaction[3] = colors.reaction[1]; -- Unfriendly
	colors.reaction[4] = {1, 0.8, 0}; -- Neutral
	colors.reaction[5] = {0,1, 0.2}; -- Friendly
	colors.reaction[6] = colors.reaction[5]; -- Honored
	colors.reaction[7] = colors.reaction[5]; -- Revered
	colors.reaction[8] = colors.reaction[5]; -- Exalted
end
local menu = function(self)
	local unit = string.gsub(self.unit,"(.)",string.upper,1);
	if (_G[unit..'FrameDropDown']) then
		ToggleDropDownMenu(1, nil, _G[unit..'FrameDropDown'], 'cursor')
	elseif (self.unit:match('party')) then
		ToggleDropDownMenu(1, nil, _G['PartyMemberFrame'..self.id..'DropDown'], 'cursor')
	else
		FriendsDropDown.unit = self.unit
		FriendsDropDown.id = self.id
		FriendsDropDown.initialize = RaidFrameDropDown_Initialize
		ToggleDropDownMenu(1, nil, FriendsDropDown, 'cursor')
	end
end
local simple = function(val)
	if (val >= 1e6) then -- 1 million
		return ("%.1f m"):format(val/1e6);
	else
		return val
	end
end
local PostUpdateAura = function(self,event,unit)
	if suiChar and suiChar.PartyFrames and suiChar.PartyFrames.showAuras == 0 then
		self.Auras:Hide();		
	else
		self.Auras:Show();
	end	
end
local PostCastStart = function(self,event,unit,name,rank,text,castid)
	self.Castbar:SetStatusBarColor(1,0.7,0);
end
local PostChannelStart = function(self,event,unit,name,rank,text,castid)
	self.Castbar:SetStatusBarColor(0,1,0);	
end
local PostUpdateHealth = function(self, event, unit, bar, min, max)
	if(UnitIsDead(unit)) then
		bar:SetValue(0);
		bar.value:SetText"Dead"
		bar.ratio:SetText""
	elseif(UnitIsGhost(unit)) then
		bar:SetValue(0)
		bar.value:SetText"Ghost"
		bar.ratio:SetText""
	else
		bar.value:SetFormattedText("%s", simple(min))
		bar.ratio:SetFormattedText("%d%%",(min/max)*100);
	end
end
local PostUpdatePower = function(self, event, unit, bar, min, max)
	if (UnitIsDead(unit) or UnitIsGhost(unit) or not UnitIsConnected(unit) or max == 0) then
		bar.value:SetText""
		bar.ratio:SetText""
	else
		bar.value:SetFormattedText("%s", simple(min));
		bar.ratio:SetFormattedText("%d%%",(min/max)*100);
	end
end
local CreatePartyFrame = function(self,unit)
	local base_plate = [[Interface\AddOns\SpartanUI_PartyFrames\media\base_plate1]]
	local base_ring = [[Interface\AddOns\SpartanUI_PartyFrames\media\base_ring1]]
	do -- setup base artwork
		local artwork = CreateFrame("Frame",nil,self);
		artwork:SetFrameStrata("BACKGROUND");
		artwork:SetFrameLevel(0); artwork:SetAllPoints(self);
		
		artwork.bg = artwork:CreateTexture(nil,"BACKGROUND");
		artwork.bg:SetPoint("TOPLEFT",artwork,"TOPLEFT",-2,10);
		artwork.bg:SetTexture(base_plate);
		
		self.Portrait = artwork:CreateTexture(nil,"BORDER");
		self.Portrait:SetWidth(55); self.Portrait:SetHeight(55);
		self.Portrait:SetPoint("LEFT",self,"LEFT",15,0);
	end
	do -- setup status bars
		do -- cast bar
			local cast = CreateFrame("StatusBar",nil,self);
			cast:SetFrameStrata("BACKGROUND"); cast:SetFrameLevel(2);
			cast:SetWidth(119); cast:SetHeight(16);
			cast:SetStatusBarTexture(bar_texture);
			cast:SetPoint("TOPRIGHT",self,"TOPRIGHT",-55,-24);
			
			cast.Text = cast:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			cast.Text:SetWidth(110); cast.Text:SetHeight(11);
			cast.Text:SetJustifyH("LEFT"); cast.Text:SetJustifyV("BOTTOM");
			cast.Text:SetPoint("RIGHT",cast,"RIGHT",-2,0);
			
			cast.Time = cast:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			cast.Time:SetWidth(40); cast.Time:SetHeight(11);
			cast.Time:SetJustifyH("LEFT"); cast.Time:SetJustifyV("BOTTOM");
			cast.Time:SetPoint("LEFT",cast,"RIGHT",2,0);
			
			self.Castbar = cast;
			self.PostCastStart = PostCastStart;
			self.PostChannelStart = PostChannelStart;
		end
		do -- health bar
			local health = CreateFrame("StatusBar",nil,self);
			health:SetFrameStrata("BACKGROUND"); health:SetFrameLevel(2);
			health:SetWidth(121); health:SetHeight(15);
			health:SetStatusBarTexture(bar_texture);
			health:SetPoint("TOPRIGHT",self.Castbar,"BOTTOMRIGHT",0,-2);
			
			health.value = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.value:SetWidth(110); health.value:SetHeight(11);
			health.value:SetJustifyH("LEFT"); health.value:SetJustifyV("BOTTOM");
			health.value:SetPoint("RIGHT",health,"RIGHT",-2,0);
			
			health.ratio = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.ratio:SetWidth(40); health.ratio:SetHeight(11);
			health.ratio:SetJustifyH("LEFT"); health.ratio:SetJustifyV("BOTTOM");
			health.ratio:SetPoint("LEFT",health,"RIGHT",2,0);
						
			self.Health = health;
			self.Health.frequentUpdates = true;
			self.Health.colorTapping = true;
			self.Health.colorDisconnected = true;
			self.Health.colorHealth = true;
			self.Health.colorReaction = true;
			self.PostUpdateHealth = PostUpdateHealth;
		end
		do -- power bar
			local power = CreateFrame("StatusBar",nil,self);
			power:SetFrameStrata("BACKGROUND"); power:SetFrameLevel(2);
			power:SetWidth(136); power:SetHeight(14);
			power:SetStatusBarTexture(bar_texture);
			power:SetPoint("TOPRIGHT",self.Health,"BOTTOMRIGHT",0,-2);
			
			power.value = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.value:SetWidth(110); power.value:SetHeight(11);
			power.value:SetJustifyH("LEFT"); power.value:SetJustifyV("BOTTOM");
			power.value:SetPoint("RIGHT",power,"RIGHT",-2,0);
			
			power.ratio = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.ratio:SetWidth(40); power.ratio:SetHeight(11);
			power.ratio:SetJustifyH("LEFT"); power.ratio:SetJustifyV("BOTTOM");
			power.ratio:SetPoint("LEFT",power,"RIGHT",2,0);			
			
			self.Power = power;
			self.Power.colorPower = true;
			self.Power.frequentUpdates = true;
			self.PostUpdatePower = PostUpdatePower;
		end
	end
	do -- setup text and icons	
		local ring = CreateFrame("Frame",nil,self);
		ring:SetFrameStrata("BACKGROUND");
		ring:SetAllPoints(self.Portrait); ring:SetFrameLevel(3);
		ring.bg = ring:CreateTexture(nil,"BACKGROUND");
		ring.bg:SetPoint("CENTER",ring,"CENTER",-2,-2);
		ring.bg:SetTexture(base_ring);
		
		self.Name = ring:CreateFontString(nil, "BORDER","SUI_FontOutline11");
		self.Name:SetWidth(150); self.Name:SetHeight(12);
		self.Name:SetJustifyH("LEFT"); self.Name:SetJustifyV("BOTTOM");
		self.Name:SetPoint("TOPRIGHT",self,"TOPRIGHT",-20,-8);
		self:Tag(self.Name, "[name]");
			
		self.Level = ring:CreateFontString(nil,"BORDER","SUI_FontOutline10");			
		self.Level:SetWidth(40); self.Level:SetHeight(12);
		self.Level:SetJustifyH("CENTER"); self.Level:SetJustifyV("BOTTOM");
		self.Level:SetPoint("CENTER",self.Portrait,"CENTER",-27,27);
		self:Tag(self.Level, "[level]");
		
		self.ClassIcon = ring:CreateTexture(nil,"BORDER");
		self.ClassIcon:SetWidth(20); self.ClassIcon:SetHeight(20);
		self.ClassIcon:SetPoint("CENTER",self.Portrait,"CENTER",23,24);

		self.Leader = ring:CreateTexture(nil,"BORDER");
		self.Leader:SetWidth(20); self.Leader:SetHeight(20);
		self.Leader:SetPoint("CENTER",self.Portrait,"TOP",-1,6);
		
		self.MasterLooter = ring:CreateTexture(nil,"BORDER");
		self.MasterLooter:SetWidth(18); self.MasterLooter:SetHeight(18);
		self.MasterLooter:SetPoint("CENTER",self.Portrait,"LEFT",-10,0);

		self.PvP = ring:CreateTexture(nil,"BORDER");
		self.PvP:SetWidth(50); self.PvP:SetHeight(50);
		self.PvP:SetPoint("CENTER",self.Portrait,"BOTTOMLEFT",5,-10);
			
		self.RaidIcon = ring:CreateTexture(nil,"ARTWORK");
		self.RaidIcon:SetWidth(24); self.RaidIcon:SetHeight(24);
		self.RaidIcon:SetPoint("CENTER",self.Portrait,"BOTTOM",-2,-10);

		self.StatusText = ring:CreateFontString(nil, "OVERLAY", "SUI_FontOutline18");
		self.StatusText:SetPoint("CENTER",self.Portrait,"CENTER");
		self.StatusText:SetJustifyH("CENTER");
		self:Tag(self.StatusText, "[afkdnd]");
	end
	do -- setup buffs and debuffs
		self.Auras = CreateFrame("Frame",nil,self);
		self.Auras:SetWidth(15*12); self.Auras:SetHeight(15*1);
		self.Auras:SetPoint("TOPRIGHT",self,"BOTTOMRIGHT",-6,2);
		-- settings
		self.Auras.size = 14;
		self.Auras.spacing = 1;
		self.Auras.initialAnchor = "TOPLEFT";
		self.Auras.gap = false; -- adds an empty spacer between buffs and debuffs
		self.Auras.numBuffs = 8;
		self.Auras.numDebuffs = 4;
		
		self.PreUpdateAura = PreUpdateAura;
		self.PostUpdateAura = PostUpdateAura;
	end
	return self;
end
local CreateUnitFrame = function(self,unit) -- this is a throwback for when we start creating partypets
		self:SetWidth(250); self:SetHeight(80);
		self:SetScript("OnEnter", UnitFrame_OnEnter)
		self:SetScript("OnLeave", UnitFrame_OnLeave)
		self:RegisterForClicks("anyup");
		self:SetAttribute("*type2", "menu");		
		self.menu = menu;
		self.colors = colors;
		return CreatePartyFrame(self,unit);
end
oUF:RegisterStyle("Spartan_PartyFrames", CreateUnitFrame);
