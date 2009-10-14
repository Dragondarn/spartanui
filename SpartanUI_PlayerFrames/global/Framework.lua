local spartan = LibStub("AceAddon-3.0"):GetAddon("SpartanUI");
local addon = spartan:NewModule("PlayerFrames");
----------------------------------------------------------------------------------------------------
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
		if (self.unit ~= unit) then return; end
		if (not self.ClassIcon) then return; end
		local _,class = UnitClass(unit);
		local col, row = ClassIconCoord[class or "DEFAULT"][1],ClassIconCoord[class or "DEFAULT"][2];
		local left, top = (row-1)*0.25,(col-1)*0.25;
		self.ClassIcon:SetTexture[[Interface\AddOns\SpartanUI_PlayerFrames\media\icon_class]]
		self.ClassIcon:SetTexCoord(left,left+0.25,top,top+0.25);
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
do -- Level Skull as an oUF module
	local Update = function(self,event,unit)
		if (self.unit ~= unit) then return; end
		if (not self.LevelSkull) then return; end
		local level = UnitLevel(unit);
		self.LevelSkull:SetTexture[[Interface\TargetingFrame\UI-TargetingFrame-Skull]]
		if level < 0 then
			self.LevelSkull:SetTexCoord(0,1,0,1);
			if self.Level then self.Level:SetText"" end
		else
			self.LevelSkull:SetTexCoord(0,0.01,0,0.01);
		end
	end
	local Enable = function(self)
		if (self.LevelSkull) then return true; end
	end
	local Disable = function(self) return; end
	oUF:AddElement('LevelSkull', Update,Enable,Disable);
end
do -- Rare / Elite dragon graphic as an oUF module
	local Update = function(self,event,unit)
		if (self.unit ~= unit) then return; end
		if (not self.RareElite) then return; end
		local c = UnitClassification(unit);
		self.RareElite:SetTexture[[Interface\AddOns\SpartanUI_PlayerFrames\media\elite_rare]];
		if c == "worldboss" or c == "elite" or c == "rareelite" then
			self.RareElite:SetTexCoord(0,1,0,1);
			self.RareElite:SetVertexColor(1,0.9,0,1);
		elseif c == "rare" then
			self.RareElite:SetTexCoord(0,1,0,1);
			self.RareElite:SetVertexColor(1,1,1,1);
		else
			self.RareElite:SetTexCoord(0,0.1,0,0.1);
		end
	end
	local Enable = function(self)
		if (self.RareElite) then return true; end
	end
	local Disable = function(self) return; end
	oUF:AddElement('RareElite', Update,Enable,Disable);
end

do -- addon colors
	addon.colors = {};
	addon.colors.health = {0/255,255/255,50/255};
	addon.colors.reaction = {};
	addon.colors.reaction[1] = {0.8,0.3,0}; -- Hated
	addon.colors.reaction[2] = addon.colors.reaction[1]; -- Hostile
	addon.colors.reaction[3] = addon.colors.reaction[1]; -- Unfriendly
	addon.colors.reaction[4] = {1, 0.8, 0}; -- Neutral
	addon.colors.reaction[5] = {0,1, 0.2}; -- Friendly
	addon.colors.reaction[6] = addon.colors.reaction[5]; -- Honored
	addon.colors.reaction[7] = addon.colors.reaction[5]; -- Revered
	addon.colors.reaction[8] = addon.colors.reaction[5]; -- Exalted
	if (oUF and oUF.colors) then
		addon.colors = setmetatable(addon.colors,{__index = oUF.colors});
	end
end
local bar_texture = [[Interface\TargetingFrame\UI-StatusBar]]
local base_plate1 = [[Interface\AddOns\SpartanUI_PlayerFrames\media\base_plate1]]
local base_ring1 = [[Interface\AddOns\SpartanUI_PlayerFrames\media\base_ring1]]
local base_plate3 = [[Interface\AddOns\SpartanUI_PlayerFrames\media\base_plate3]]
local base_ring3 = [[Interface\AddOns\SpartanUI_PlayerFrames\media\base_ring3]]
local menu = function(self)
	local unit = string.gsub(self.unit,"(.)",string.upper,1);
	if (_G[unit..'FrameDropDown']) then
		ToggleDropDownMenu(1, nil, _G[unit..'FrameDropDown'], 'cursor')
	end
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
		bar.value:SetFormattedText("%s / %s", min,max)
		bar.ratio:SetFormattedText("%d%%",(min/max)*100);
	end
end
local PostUpdatePower = function(self, event, unit, bar, min, max)
	if (UnitIsDead(unit) or UnitIsGhost(unit) or not UnitIsConnected(unit) or max == 0) then
		bar.value:SetText""
		bar.ratio:SetText""
	else
		bar.value:SetFormattedText("%s / %s", min,max);
		bar.ratio:SetFormattedText("%d%%",(min/max)*100);
	end
end
local PostCastStart = function(self,event,unit,name,rank,text,castid)
	self.Castbar:SetStatusBarColor(1,0.7,0);
end
local PostChannelStart = function(self,event,unit,name,rank,text,castid)
	self.Castbar:SetStatusBarColor(0,1,0);	
end
local PostUpdateAura = function(self,event,unit)
	if suiChar and suiChar.PlayerFrames and suiChar.PlayerFrames[unit] == 0 then
		self.Auras:Hide();		
	else
		self.Auras:Show();
	end	
end
local CreatePlayerFrame = function(self,unit)
	self:SetWidth(280); self:SetHeight(80);
	do -- setup base artwork
		local artwork = CreateFrame("Frame",nil,self);
		artwork:SetFrameStrata("BACKGROUND");
		artwork:SetFrameLevel(0); artwork:SetAllPoints(self);
		
		artwork.bg = artwork:CreateTexture(nil,"BACKGROUND");
		artwork.bg:SetPoint("CENTER");
		artwork.bg:SetTexture(base_plate1);

		self.Portrait = self:CreateTexture(nil,"BORDER");
		self.Portrait:SetWidth(64); self.Portrait:SetHeight(64);
		self.Portrait:SetPoint("CENTER",self,"CENTER",80,3);
	end
	do -- setup status bars
		do -- cast bar
			local cast = CreateFrame("StatusBar",nil,self);
			cast:SetFrameStrata("BACKGROUND"); cast:SetFrameLevel(2);
			cast:SetWidth(153); cast:SetHeight(16);
			cast:SetStatusBarTexture(bar_texture);
			cast:SetPoint("TOPLEFT",self,"TOPLEFT",36,-23);
			
			cast.Text = cast:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			cast.Text:SetWidth(135); cast.Text:SetHeight(11);
			cast.Text:SetJustifyH("RIGHT"); cast.Text:SetJustifyV("MIDDLE");
			cast.Text:SetPoint("LEFT",cast,"LEFT",4,0);			
			
			cast.Time = cast:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			cast.Time:SetWidth(90); cast.Time:SetHeight(11);			
			cast.Time:SetJustifyH("RIGHT"); cast.Time:SetJustifyV("MIDDLE");
			cast.Time:SetPoint("RIGHT",cast,"LEFT",-2,0);
			
			self.Castbar = cast;
			self.PostCastStart = PostCastStart;
			self.PostChannelStart = PostChannelStart;
		end
		do -- health bar
			local health = CreateFrame("StatusBar",nil,self);
			health:SetFrameStrata("BACKGROUND"); health:SetFrameLevel(2);
			health:SetWidth(150); health:SetHeight(16);
			health:SetStatusBarTexture(bar_texture);
			health:SetPoint("TOPLEFT",self.Castbar,"BOTTOMLEFT",0,-2);
			
			health.value = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.value:SetWidth(135); health.value:SetHeight(11);
			health.value:SetJustifyH("RIGHT"); health.value:SetJustifyV("MIDDLE");
			health.value:SetPoint("LEFT",health,"LEFT",4,0);
			
			health.ratio = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.ratio:SetWidth(90); health.ratio:SetHeight(11);
			health.ratio:SetJustifyH("RIGHT"); health.ratio:SetJustifyV("MIDDLE");
			health.ratio:SetPoint("RIGHT",health,"LEFT",-2,0);
			
			self.Health = health;
			self.Health.frequentUpdates = true;
			self.Health.colorTapping = true;
			self.Health.colorDisconnected = true;
			self.Health.colorReaction = true;
			self.Health.colorHealth = true;		
			self.PostUpdateHealth = PostUpdateHealth;
		end
		do -- power bar
			local power = CreateFrame("StatusBar",nil,self);
			power:SetFrameStrata("BACKGROUND"); power:SetFrameLevel(2);
			power:SetWidth(155); power:SetHeight(14);
			power:SetStatusBarTexture(bar_texture);
			power:SetPoint("TOPLEFT",self.Health,"BOTTOMLEFT",0,-2);
			
			power.value = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.value:SetWidth(135); power.value:SetHeight(11);
			power.value:SetJustifyH("RIGHT"); power.value:SetJustifyV("MIDDLE");
			power.value:SetPoint("LEFT",power,"LEFT",4,0);
			
			power.ratio = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.ratio:SetWidth(90); power.ratio:SetHeight(11);
			power.ratio:SetJustifyH("RIGHT"); power.ratio:SetJustifyV("MIDDLE");
			power.ratio:SetPoint("RIGHT",power,"LEFT",-2,0);
			
			self.Power = power;
			self.Power.colorPower = true;
			self.Power.frequentUpdates = true;
			self.PostUpdatePower = PostUpdatePower;
		end
	end
	do -- setup ring, icons, and text
		local ring = CreateFrame("Frame",nil,self);
		ring:SetFrameStrata("BACKGROUND");
		ring:SetAllPoints(self.Portrait); ring:SetFrameLevel(3);
		ring.bg = ring:CreateTexture(nil,"BACKGROUND");
		ring.bg:SetPoint("CENTER",ring,"CENTER",-80,-3);
		ring.bg:SetTexture(base_ring1);
		
		self.Name = ring:CreateFontString(nil, "BORDER","SUI_FontOutline12");
		self.Name:SetHeight(12); self.Name:SetWidth(170); self.Name:SetJustifyH("RIGHT");
		self.Name:SetPoint("TOPLEFT",self,"TOPLEFT",5,-6);
		self:Tag(self.Name, "[name]");
		
		self.Level = ring:CreateFontString(nil,"BORDER","SUI_FontOutline11");			
		self.Level:SetWidth(40); self.Level:SetHeight(11);
		self.Level:SetJustifyH("CENTER"); self.Level:SetJustifyV("MIDDLE");
		self.Level:SetPoint("CENTER",ring,"CENTER",51,12);
		self:Tag(self.Level, "[level]");		
		
		self.ClassIcon = ring:CreateTexture(nil,"BORDER");
		self.ClassIcon:SetWidth(22); self.ClassIcon:SetHeight(22);
		self.ClassIcon:SetPoint("CENTER",ring,"CENTER",-29,21);
		
		self.Leader = ring:CreateTexture(nil,"BORDER");
		self.Leader:SetWidth(20); self.Leader:SetHeight(20);
		self.Leader:SetPoint("CENTER",ring,"TOP");
		
		self.MasterLooter = ring:CreateTexture(nil,"BORDER");
		self.MasterLooter:SetWidth(18); self.MasterLooter:SetHeight(18);
		self.MasterLooter:SetPoint("CENTER",ring,"TOPRIGHT",-6,-6);
		
		self.PvP = ring:CreateTexture(nil,"BORDER");
		self.PvP:SetWidth(48); self.PvP:SetHeight(48);
		self.PvP:SetPoint("CENTER",ring,"CENTER",-20,-40);
		
		self.Resting = ring:CreateTexture(nil,"ARTWORK");
		self.Resting:SetWidth(32); self.Resting:SetHeight(30);
		self.Resting:SetPoint("CENTER",self.ClassIcon,"CENTER");
			
		self.Combat = ring:CreateTexture(nil,"ARTWORK");
		self.Combat:SetWidth(32); self.Combat:SetHeight(32);
		self.Combat:SetPoint("CENTER",self.Level,"TOPLEFT");
		
		self.RaidIcon = ring:CreateTexture(nil,"ARTWORK");
		self.RaidIcon:SetWidth(24); self.RaidIcon:SetHeight(24);
		self.RaidIcon:SetPoint("CENTER",ring,"LEFT",-2,-3);
			
		self.StatusText = ring:CreateFontString(nil, "OVERLAY", "SUI_FontOutline22");
		self.StatusText:SetPoint("CENTER",ring,"CENTER");
		self.StatusText:SetJustifyH("CENTER");
		self:Tag(self.StatusText, "[afkdnd]");	
	end
	do -- setup buffs and debuffs
		self.Auras = CreateFrame("Frame",nil,self);
		self.Auras:SetWidth(22*10); self.Auras:SetHeight(22*2);
		self.Auras:SetPoint("BOTTOMLEFT",self,"TOPLEFT",10,0);
		self.Auras:SetFrameStrata("BACKGROUND");
		self.Auras:SetFrameLevel(4);
		-- settings
		self.Auras.size = 20; self.Auras.spacing = 1;
		self.Auras.initialAnchor = "BOTTOMLEFT";
		self.Auras["growth-x"] = "RIGHT";
		self.Auras["growth-y"] = "UP";
		self.Auras.gap = false;
		self.Auras.numBuffs = 10;
		self.Auras.numDebuffs = 10;

		self.PostUpdateAura = PostUpdateAura;
	end
	return self;
end
local CreateTargetFrame = function(self,unit)
	self:SetWidth(280); self:SetHeight(80);
	do --setup base artwork
		local artwork = CreateFrame("Frame",nil,self);
		artwork:SetFrameStrata("BACKGROUND");
		artwork:SetFrameLevel(0); artwork:SetAllPoints(self);
		
		artwork.bg = artwork:CreateTexture(nil,"BACKGROUND");
		artwork.bg:SetPoint("CENTER");
		artwork.bg:SetTexture(base_plate1);
		artwork.bg:SetTexCoord(1,0,0,1);

		self.Portrait = self:CreateTexture(nil,"BORDER");
		self.Portrait:SetWidth(64); self.Portrait:SetHeight(64);
		self.Portrait:SetPoint("CENTER",self,"CENTER",-80,3);
	end
	do -- setup status bars
		do -- cast bar
			local cast = CreateFrame("StatusBar",nil,self);
			cast:SetFrameStrata("BACKGROUND"); cast:SetFrameLevel(2);
			cast:SetWidth(153); cast:SetHeight(16);
			cast:SetStatusBarTexture(bar_texture);
			cast:SetPoint("TOPRIGHT",self,"TOPRIGHT",-36,-23);
			
			cast.Text = cast:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			cast.Text:SetWidth(135); cast.Text:SetHeight(11);
			cast.Text:SetJustifyH("LEFT"); cast.Text:SetJustifyV("MIDDLE");
			cast.Text:SetPoint("RIGHT",cast,"RIGHT",-4,0);
			
			cast.Time = cast:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			cast.Time:SetWidth(90); cast.Time:SetHeight(11);
			cast.Time:SetJustifyH("LEFT"); cast.Time:SetJustifyV("MIDDLE");
			cast.Time:SetPoint("LEFT",cast,"RIGHT",2,0);
			
			self.Castbar = cast;
			self.PostCastStart = PostCastStart;
			self.PostChannelStart = PostChannelStart;
		end
		do -- health bar
			local health = CreateFrame("StatusBar",nil,self);
			health:SetFrameStrata("BACKGROUND"); health:SetFrameLevel(2);
			health:SetWidth(150); health:SetHeight(16);
			health:SetStatusBarTexture(bar_texture);	
			health:SetPoint("TOPRIGHT",self.Castbar,"BOTTOMRIGHT",0,-2);
			
			health.value = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.value:SetWidth(135); health.value:SetHeight(11);
			health.value:SetJustifyH("LEFT"); health.value:SetJustifyV("MIDDLE");
			health.value:SetPoint("RIGHT",health,"RIGHT",-4,0);
			
			
			health.ratio = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.ratio:SetWidth(90); health.ratio:SetHeight(11);
			health.ratio:SetJustifyH("LEFT"); health.ratio:SetJustifyV("MIDDLE");
			health.ratio:SetPoint("LEFT",health,"RIGHT",2,0);
			
			self.Health = health;
			self.Health.frequentUpdates = true;
			self.Health.colorTapping = true;
			self.Health.colorDisconnected = true;
			self.Health.colorReaction = true;
			self.Health.colorHealth = true;		
			self.PostUpdateHealth = PostUpdateHealth;
		end
		do -- power bar
			local power = CreateFrame("StatusBar",nil,self);
			power:SetFrameStrata("BACKGROUND"); power:SetFrameLevel(2);
			power:SetWidth(155); power:SetHeight(14);
			power:SetStatusBarTexture(bar_texture);
			power:SetPoint("TOPRIGHT",self.Health,"BOTTOMRIGHT",0,-2);
			
			power.value = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.value:SetWidth(135); power.value:SetHeight(11);
			power.value:SetJustifyH("LEFT"); power.value:SetJustifyV("MIDDLE");
			power.value:SetPoint("RIGHT",power,"RIGHT",-4,0);
			
			power.ratio = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.ratio:SetWidth(90); power.ratio:SetHeight(11);
			power.ratio:SetJustifyH("LEFT"); power.ratio:SetJustifyV("MIDDLE");
			power.ratio:SetPoint("LEFT",power,"RIGHT",2,0);
			
			self.Power = power;
			self.Power.colorPower = true;
			self.Power.frequentUpdates = true;
			self.PostUpdatePower = PostUpdatePower;
		end
	end
	do -- setup ring, icons, and text
		local ring = CreateFrame("Frame",nil,self);
		ring:SetFrameStrata("BACKGROUND");
		ring:SetAllPoints(self.Portrait); ring:SetFrameLevel(3);
		ring.bg = ring:CreateTexture(nil,"BACKGROUND");
		ring.bg:SetPoint("CENTER",ring,"CENTER",80,-3);
		ring.bg:SetTexture(base_ring1);
		ring.bg:SetTexCoord(1,0,0,1);
		
		self.Name = ring:CreateFontString(nil, "BORDER","SUI_FontOutline12");
		self.Name:SetWidth(170); self.Name:SetHeight(12); 
		self.Name:SetJustifyH("LEFT"); self.Name:SetJustifyV("MIDDLE");
		self.Name:SetPoint("TOPRIGHT",self,"TOPRIGHT",-5,-6);
		self:Tag(self.Name,"[name]");
		
		self.Level = ring:CreateFontString(nil,"BORDER","SUI_FontOutline11");			
		self.Level:SetWidth(40); self.Level:SetHeight(11);
		self.Level:SetJustifyH("CENTER"); self.Level:SetJustifyV("MIDDLE");
		self.Level:SetPoint("CENTER",ring,"CENTER",-50,12);
		self:Tag(self.Level, "[difficulty][level]");
		
		self.ClassIcon = ring:CreateTexture(nil,"BORDER");
		self.ClassIcon:SetWidth(22); self.ClassIcon:SetHeight(22);
		self.ClassIcon:SetPoint("CENTER",ring,"CENTER",29,21);
		
		self.Leader = ring:CreateTexture(nil,"BORDER");
		self.Leader:SetWidth(20); self.Leader:SetHeight(20);
		self.Leader:SetPoint("CENTER",ring,"TOP");
		
		self.MasterLooter = ring:CreateTexture(nil,"BORDER");
		self.MasterLooter:SetWidth(18); self.MasterLooter:SetHeight(18);
		self.MasterLooter:SetPoint("CENTER",ring,"TOPLEFT",6,-6);
		
		self.PvP = ring:CreateTexture(nil,"BORDER");
		self.PvP:SetWidth(48); self.PvP:SetHeight(48);
		self.PvP:SetPoint("CENTER",ring,"CENTER",35,-40);
		
		self.LevelSkull = ring:CreateTexture(nil,"ARTWORK");
		self.LevelSkull:SetWidth(16); self.LevelSkull:SetHeight(16);
		self.LevelSkull:SetPoint("CENTER",self.Level,"CENTER");
		
		self.RareElite = ring:CreateTexture(nil,"ARTWORK");
		self.RareElite:SetWidth(150); self.RareElite:SetHeight(150);
		self.RareElite:SetPoint("CENTER",ring,"CENTER",-12,-4);
		
		self.RaidIcon = ring:CreateTexture(nil,"ARTWORK");
		self.RaidIcon:SetWidth(24); self.RaidIcon:SetHeight(24);
		self.RaidIcon:SetPoint("CENTER",ring,"RIGHT",2,-4);
		
		self.StatusText = ring:CreateFontString(nil, "OVERLAY", "SUI_FontOutline22");
		self.StatusText:SetPoint("CENTER",ring,"CENTER");
		self.StatusText:SetJustifyH("CENTER");
		self:Tag(self.StatusText, "[afkdnd]");	

		self.CPoints = ring:CreateFontString(nil, "BORDER","SUI_FontOutline13");
		self.CPoints:SetPoint("TOP",ring,"BOTTOM");
		for i = 1, 5 do
			self.CPoints[i] = ring:CreateTexture(nil,"OVERLAY");
			self.CPoints[i]:SetTexture([[Interface\AddOns\SpartanUI_PlayerFrames\media\icon_combo]]);
		end
		self.CPoints[1]:SetPoint("CENTER",ring,"LEFT",-6,-6);
		self.CPoints[2]:SetPoint("TOP",self.CPoints[1],"BOTTOM",3,6);
		self.CPoints[3]:SetPoint("TOP",self.CPoints[2],"BOTTOM",6,8);
		self.CPoints[4]:SetPoint("TOP",self.CPoints[3],"BOTTOM",7,9);
		self.CPoints[5]:SetPoint("TOP",self.CPoints[4],"BOTTOM",9,11);		
		ring:SetScript("OnUpdate",function()
			if self.CPoints then
				local cp = GetComboPoints("player","target");
				self.CPoints:SetText( (cp > 0 and cp) or "");
			end
		end);
	end
	do -- setup buffs and debuffs
		self.Auras = CreateFrame("Frame",nil,self);
		self.Auras:SetWidth(22*10); self.Auras:SetHeight(22*2);
		self.Auras:SetPoint("BOTTOMRIGHT",self,"TOPRIGHT",-10,0);
		self.Auras:SetFrameStrata("BACKGROUND");
		self.Auras:SetFrameLevel(4);
		-- settings
		self.Auras.size = 20; self.Auras.spacing = 1;
		self.Auras.initialAnchor = "BOTTOMRIGHT";
		self.Auras["growth-x"] = "LEFT";
		self.Auras["growth-y"] = "UP";
		self.Auras.gap = false;
		self.Auras.numBuffs = 10;
		self.Auras.numDebuffs = 10;

		self.PostUpdateAura = PostUpdateAura;
	end
	return self;
end
local CreatePetFrame = function(self,unit)
	self:SetWidth(210); self:SetHeight(60);
	do -- setup base artwork
		local artwork = CreateFrame("Frame",nil,self);
		artwork:SetFrameStrata("BACKGROUND");
		artwork:SetFrameLevel(0); artwork:SetAllPoints(self);
		
		artwork.bg = artwork:CreateTexture(nil,"BACKGROUND");
		artwork.bg:SetPoint("CENTER"); artwork.bg:SetTexture(base_plate3);
		artwork.bg:SetWidth(256); artwork.bg:SetHeight(85);
		artwork.bg:SetTexCoord(0,1,0,85/128);

		self.Portrait = self:CreateTexture(nil,"BACKGROUND");
		self.Portrait:SetWidth(56); self.Portrait:SetHeight(50);
		self.Portrait:SetPoint("CENTER",self,"CENTER",87,-8);
	end
	do -- setup status bars
		do -- cast bar
			local cast = CreateFrame("StatusBar",nil,self);
			cast:SetFrameStrata("BACKGROUND"); cast:SetFrameLevel(2);
			cast:SetWidth(120); cast:SetHeight(15);
			cast:SetStatusBarTexture(bar_texture);
			cast:SetPoint("TOPLEFT",self,"TOPLEFT",36,-23);
			
			cast.Text = cast:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			cast.Text:SetWidth(110); cast.Text:SetHeight(11);
			cast.Text:SetJustifyH("RIGHT"); cast.Text:SetJustifyV("MIDDLE");
			cast.Text:SetPoint("LEFT",cast,"LEFT",4,0);
			
			cast.Time = cast:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			cast.Time:SetWidth(40); cast.Time:SetHeight(11);
			cast.Time:SetJustifyH("RIGHT"); cast.Time:SetJustifyV("MIDDLE");
			cast.Time:SetPoint("RIGHT",cast,"LEFT",-2,0);
			
			self.Castbar = cast;
			self.PostCastStart = PostCastStart;
			self.PostChannelStart = PostChannelStart;
		end
		do -- health bar
			local health = CreateFrame("StatusBar",nil,self);
			health:SetFrameStrata("BACKGROUND"); health:SetFrameLevel(2);
			health:SetWidth(120); health:SetHeight(16);
			health:SetStatusBarTexture(bar_texture);
			health:SetPoint("TOPLEFT",self.Castbar,"BOTTOMLEFT",0,-2);
			
			health.value = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.value:SetWidth(110); health.value:SetHeight(11);
			health.value:SetJustifyH("RIGHT"); health.value:SetJustifyV("MIDDLE");
			health.value:SetPoint("LEFT",health,"LEFT",4,0);
			
			health.ratio = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.ratio:SetWidth(40); health.ratio:SetHeight(11);
			health.ratio:SetJustifyH("RIGHT"); health.ratio:SetJustifyV("MIDDLE");
			health.ratio:SetPoint("RIGHT",health,"LEFT",-2,0);			
			
			self.Health = health;
			self.Health.colorTapping = true;
			self.Health.colorDisconnected = true;
			self.Health.colorHappiness = true;
			self.Health.colorHealth = true;
			self.Health.colorReaction = true;
			self.PostUpdateHealth = PostUpdateHealth;
		end
		do -- power bar
			local power = CreateFrame("StatusBar",nil,self);
			power:SetFrameStrata("BACKGROUND"); power:SetFrameLevel(2);
			power:SetWidth(135); power:SetHeight(14);
			power:SetStatusBarTexture(bar_texture);
			power:SetPoint("TOPLEFT",self.Health,"BOTTOMLEFT",0,-1);
			
			power.value = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.value:SetWidth(110); power.value:SetHeight(11);
			power.value:SetJustifyH("RIGHT"); power.value:SetJustifyV("MIDDLE");
			power.value:SetPoint("LEFT",power,"LEFT",4,0);
			
			power.ratio = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.ratio:SetWidth(40); power.ratio:SetHeight(11);
			power.ratio:SetJustifyH("RIGHT"); power.ratio:SetJustifyV("MIDDLE");
			power.ratio:SetPoint("RIGHT",power,"LEFT",-2,0);
			
			self.Power = power;
			self.Power.colorPower = true;
			self.Power.frequentUpdates = true;
			self.PostUpdatePower = PostUpdatePower;
		end
	end
	do -- setup ring, icons, and text
		local ring = CreateFrame("Frame",nil,self);
		ring:SetFrameStrata("BACKGROUND");
		ring:SetAllPoints(self.Portrait); ring:SetFrameLevel(3);
		ring.bg = ring:CreateTexture(nil,"BACKGROUND");
		ring.bg:SetPoint("CENTER",ring,"CENTER",-2,-3);
		ring.bg:SetTexture(base_ring3);
		ring.bg:SetTexCoord(1,0,0,1);
		
		self.Name = ring:CreateFontString(nil, "BORDER","SUI_FontOutline12");
		self.Name:SetHeight(12); self.Name:SetWidth(150); self.Name:SetJustifyH("RIGHT");
		self.Name:SetPoint("TOPLEFT",self,"TOPLEFT",3,-5);
		self:Tag(self.Name,"[name]");
		
		self.Level = ring:CreateFontString(nil,"BORDER","SUI_FontOutline10");			
		self.Level:SetWidth(36); self.Level:SetHeight(11);
		self.Level:SetJustifyH("CENTER"); self.Level:SetJustifyV("MIDDLE");
		self.Level:SetPoint("CENTER",ring,"CENTER",24,25);
		self:Tag(self.Level, "[level]");
		
		self.ClassIcon = ring:CreateTexture(nil,"BORDER");
		self.ClassIcon:SetWidth(22); self.ClassIcon:SetHeight(22);
		self.ClassIcon:SetPoint("CENTER",ring,"CENTER",-27,24);
		
		self.Happiness = ring:CreateTexture(nil,"ARTWORK");
		self.Happiness:SetWidth(22); self.Happiness:SetHeight(22);
		self.Happiness:SetPoint("CENTER",ring,"CENTER",-27,24);
		
		self.PvP = ring:CreateTexture(nil,"BORDER");
		self.PvP:SetWidth(48); self.PvP:SetHeight(48);
		self.PvP:SetPoint("CENTER",ring,"CENTER",-20,-36);
		
		self.RaidIcon = ring:CreateTexture(nil,"ARTWORK");
		self.RaidIcon:SetAllPoints(self.Portrait);
		
		self.RaidIcon = ring:CreateTexture(nil,"ARTWORK");
		self.RaidIcon:SetWidth(20); self.RaidIcon:SetHeight(20);
		self.RaidIcon:SetPoint("CENTER",ring,"LEFT",-5,0);
	end
	do -- setup buffs and debuffs
		self.Auras = CreateFrame("Frame",nil,self);
		self.Auras:SetWidth(17*11); self.Auras:SetHeight(16*1);
		self.Auras:SetPoint("BOTTOMLEFT",self,"TOPLEFT",10,0);
		self.Auras:SetFrameStrata("BACKGROUND");
		self.Auras:SetFrameLevel(4);
		-- settings
		self.Auras.size = 16;
		self.Auras.spacing = 1;
		self.Auras.initialAnchor = "BOTTOMLEFT";
		self.Auras["growth-x"] = "RIGHT";
		self.Auras["growth-y"] = "UP";
		self.Auras.gap = false;	
		self.Auras.numBuffs = 8;
		self.Auras.numDebuffs = 3;

		self.PostUpdateAura = PostUpdateAura;
	end
	return self;
end
local CreateToTFrame = function(self,unit)
	self:SetWidth(210); self:SetHeight(60);
	do -- setup base artwork
		local artwork = CreateFrame("Frame",nil,self);
		artwork:SetFrameStrata("BACKGROUND");
		artwork:SetFrameLevel(0); artwork:SetAllPoints(self);
		
		artwork.bg = artwork:CreateTexture(nil,"BACKGROUND");
		artwork.bg:SetPoint("CENTER"); artwork.bg:SetTexture(base_plate3);
		artwork.bg:SetWidth(256); artwork.bg:SetHeight(85);
		artwork.bg:SetTexCoord(1,0,0,85/128);

		self.Portrait = self:CreateTexture(nil,"BACKGROUND");
		self.Portrait:SetWidth(56); self.Portrait:SetHeight(50);
		self.Portrait:SetPoint("CENTER",self,"CENTER",-83,-8);
	end
	do -- setup status bars
		do -- cast bar
			local cast = CreateFrame("StatusBar",nil,self);
			cast:SetFrameStrata("BACKGROUND"); cast:SetFrameLevel(2);
			cast:SetWidth(120); cast:SetHeight(15);
			cast:SetStatusBarTexture(bar_texture);
			cast:SetPoint("TOPRIGHT",self,"TOPRIGHT",-36,-23);
			
			cast.Text = cast:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			cast.Text:SetWidth(110); cast.Text:SetHeight(11);
			cast.Text:SetJustifyH("LEFT"); cast.Text:SetJustifyV("MIDDLE");
			cast.Text:SetPoint("RIGHT",cast,"RIGHT",-4,0);
			
			cast.Time = cast:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			cast.Time:SetWidth(40); cast.Time:SetHeight(11);
			cast.Time:SetJustifyH("LEFT"); cast.Time:SetJustifyV("MIDDLE");
			cast.Time:SetPoint("LEFT",cast,"RIGHT",4,0);
			
			self.Castbar = cast;
			self.PostCastStart = PostCastStart;
			self.PostChannelStart = PostChannelStart;
		end
		do -- health bar
			local health = CreateFrame("StatusBar",nil,self);
			health:SetFrameStrata("BACKGROUND"); health:SetFrameLevel(2);
			health:SetWidth(120); health:SetHeight(16);
			health:SetStatusBarTexture(bar_texture);
			health:SetPoint("TOPRIGHT",self.Castbar,"BOTTOMRIGHT",0,-2);
			
			health.value = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.value:SetWidth(110); health.value:SetHeight(11);
			health.value:SetJustifyH("LEFT"); health.value:SetJustifyV("MIDDLE");
			health.value:SetPoint("RIGHT",health,"RIGHT",-4,0);
			
			health.ratio = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.ratio:SetWidth(40); health.ratio:SetHeight(11);
			health.ratio:SetJustifyH("LEFT"); health.ratio:SetJustifyV("MIDDLE");
			health.ratio:SetPoint("LEFT",health,"RIGHT",4,0);			
						
			self.Health = health;
			self.Health.colorTapping = true;
			self.Health.colorDisconnected = true;
			self.Health.colorHappiness = true;
			self.Health.colorHealth = true;
			self.Health.colorReaction = true;
			self.PostUpdateHealth = PostUpdateHealth;
		end
		do -- power bar
			local power = CreateFrame("StatusBar",nil,self);
			power:SetFrameStrata("BACKGROUND"); power:SetFrameLevel(2);
			power:SetWidth(135); power:SetHeight(14);
			power:SetStatusBarTexture(bar_texture);
			power:SetPoint("TOPRIGHT",self.Health,"BOTTOMRIGHT",0,-1);
			
			power.value = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.value:SetWidth(110); power.value:SetHeight(11);
			power.value:SetJustifyH("LEFT"); power.value:SetJustifyV("MIDDLE");
			power.value:SetPoint("RIGHT",power,"RIGHT",-4,0);
			
			power.ratio = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.ratio:SetWidth(40); power.ratio:SetHeight(11);
			power.ratio:SetJustifyH("LEFT"); power.ratio:SetJustifyV("MIDDLE");
			power.ratio:SetPoint("LEFT",power,"RIGHT",4,0);			
			
			self.Power = power;
			self.Power.colorPower = true;
			self.Power.frequentUpdates = true;
			self.PostUpdatePower = PostUpdatePower;
		end
	end
	do -- setup ring, icons, and text
		local ring = CreateFrame("Frame",nil,self);
		ring:SetFrameStrata("BACKGROUND");
		ring:SetAllPoints(self.Portrait); ring:SetFrameLevel(3);
		ring.bg = ring:CreateTexture(nil,"BACKGROUND");
		ring.bg:SetPoint("CENTER",ring,"CENTER",-2,-3);
		ring.bg:SetTexture(base_ring3);
		
		self.Name = ring:CreateFontString(nil, "BORDER","SUI_FontOutline12");
		self.Name:SetHeight(12); self.Name:SetWidth(150); self.Name:SetJustifyH("LEFT");
		self.Name:SetPoint("TOPRIGHT",self,"TOPRIGHT",-3,-5);
		self:Tag(self.Name,"[name]");
		
		self.Level = ring:CreateFontString(nil,"BORDER","SUI_FontOutline10");			
		self.Level:SetWidth(36); self.Level:SetHeight(11);
		self.Level:SetJustifyH("CENTER"); self.Level:SetJustifyV("MIDDLE");
		self.Level:SetPoint("CENTER",ring,"CENTER",-27,25);
		self:Tag(self.Level, "[level]");
		
		self.ClassIcon = ring:CreateTexture(nil,"BORDER");
		self.ClassIcon:SetWidth(22); self.ClassIcon:SetHeight(22);
		self.ClassIcon:SetPoint("CENTER",ring,"CENTER",23,24);
		
		self.PvP = ring:CreateTexture(nil,"BORDER");
		self.PvP:SetWidth(48); self.PvP:SetHeight(48);
		self.PvP:SetPoint("CENTER",ring,"CENTER",30,-36);
		
		self.RaidIcon = ring:CreateTexture(nil,"ARTWORK");
		self.RaidIcon:SetWidth(20); self.RaidIcon:SetHeight(20);
		self.RaidIcon:SetPoint("CENTER",ring,"RIGHT",1,-1);
	end
	do -- setup buffs and debuffs
		self.Auras = CreateFrame("Frame",nil,self);
		self.Auras:SetWidth(17*11); self.Auras:SetHeight(16*1);
		self.Auras:SetPoint("BOTTOMRIGHT",self,"TOPRIGHT",-10,0);
		self.Auras:SetFrameStrata("BACKGROUND");
		self.Auras:SetFrameLevel(4);
		-- settings
		self.Auras.size = 16;
		self.Auras.spacing = 1;
		self.Auras.initialAnchor = "BOTTOMRIGHT";
		self.Auras["growth-x"] = "LEFT";
		self.Auras["growth-y"] = "UP";
		self.Auras.gap = false;
		self.Auras.numBuffs = 8;
		self.Auras.numDebuffs = 3;

		self.PostUpdateAura = PostUpdateAura;
	end
	return self;
end
local CreateUnitFrame = function(self,unit)
	self.menu = menu;
	self:SetParent("SpartanUI");
	self:SetFrameStrata("BACKGROUND"); self:SetFrameLevel(1);
	self:SetScript("OnEnter", UnitFrame_OnEnter);
	self:SetScript("OnLeave", UnitFrame_OnLeave);
	self:RegisterForClicks("anyup");
	self:SetAttribute("*type2", "menu");
	self.colors = addon.colors;
	return (unit == "target" and CreateTargetFrame(self,unit)) or (unit == "targettarget" and CreateToTFrame(self,unit)) or (unit == "player" and CreatePlayerFrame(self,unit)) or CreatePetFrame(self,unit);
end

oUF:RegisterStyle("Spartan_PlayerFrames", CreateUnitFrame);
