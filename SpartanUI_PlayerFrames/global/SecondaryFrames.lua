local addon = LibStub:GetLibrary("SpartanUI_PlayerFrames");
if (not addon) then return; end
---------------------------------------------------------------------------
local bar_texture = [[Interface\TargetingFrame\UI-StatusBar]]
local base_plate = [[Interface\AddOns\SpartanUI_PlayerFrames\media\base_plate3]]
local base_ring = [[Interface\AddOns\SpartanUI_PlayerFrames\media\base_ring3]]
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
local CreatePetFrame = function(self,unit)
	do -- setup base artwork
		local artwork = CreateFrame("Frame",nil,self);
		artwork:SetFrameStrata("BACKGROUND");
		artwork:SetFrameLevel(0); artwork:SetAllPoints(self);
		
		artwork.bg = artwork:CreateTexture(nil,"BACKGROUND");
		artwork.bg:SetPoint("CENTER"); artwork.bg:SetTexture(base_plate);
		artwork.bg:SetWidth(256); artwork.bg:SetHeight(85);
		artwork.bg:SetTexCoord(0,1,0,85/128);

		self.Portrait = self:CreateTexture(nil,"BACKGROUND");
		self.Portrait:SetWidth(56); self.Portrait:SetHeight(50);
		self.Portrait:SetPoint("CENTER",self,"CENTER",88,-8);
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
		ring.bg:SetTexture(base_ring);
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
		
		self.PvP = ring:CreateTexture(nil,"BORDER");
		self.PvP:SetWidth(48); self.PvP:SetHeight(48);
		self.PvP:SetPoint("CENTER",ring,"CENTER",-20,-36);
		
		self.RaidIcon = ring:CreateTexture(nil,"ARTWORK");
		self.RaidIcon:SetAllPoints(self.Portrait);
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
	do -- setup base artwork
		local artwork = CreateFrame("Frame",nil,self);
		artwork:SetFrameStrata("BACKGROUND");
		artwork:SetFrameLevel(0); artwork:SetAllPoints(self);
		
		artwork.bg = artwork:CreateTexture(nil,"BACKGROUND");
		artwork.bg:SetPoint("CENTER"); artwork.bg:SetTexture(base_plate);
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
		ring.bg:SetTexture(base_ring);
		
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
		self.PvP:SetPoint("CENTER",ring,"CENTER",26,-36);
		
		self.RaidIcon = ring:CreateTexture(nil,"ARTWORK");
		self.RaidIcon:SetAllPoints(self.Portrait);
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
local CreateUnitFrames = function(self,unit)
	self.menu = menu;
	self:SetParent("SpartanUI");
	self:SetScript("OnEnter", UnitFrame_OnEnter);
	self:SetScript("OnLeave", UnitFrame_OnLeave);
	self:RegisterForClicks("anyup");
	self:SetAttribute("*type2", "menu");		
	self:SetWidth(210); self:SetHeight(60);
	self.colors = addon.colors;
	return (unit == "targettarget" and CreateToTFrame(self,unit)) or CreatePetFrame(self,unit);
end
---------------------------------------------------------------------------
oUF:RegisterStyle("Spartan_PlayerFrames_Secondary", CreateUnitFrames);
oUF:SetActiveStyle("Spartan_PlayerFrames_Secondary");

addon.targettarget = oUF:Spawn("targettarget","SUI_TOTFrame");
addon.targettarget:SetPoint("LEFT",addon.target,"RIGHT",18,3);

addon.pet = oUF:Spawn("pet","SUI_PetFrame");
addon.pet:SetPoint("RIGHT",addon.player,"LEFT",-18,3);
