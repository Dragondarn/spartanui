local addon = LibStub:GetLibrary("SpartanUI_PartyFrames");
if (not addon) then return; end
---------------------------------------------------------------------------
local CreatePartyFrame, CreatePetFrame;
local bar_texture = [[Interface\TargetingFrame\UI-StatusBar]]
local colors = setmetatable({},{__index = oUF.colors});
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
	do -- create the base frame
		self:SetWidth(250); self:SetHeight(80);
		self:SetScript("OnEnter", UnitFrame_OnEnter)
		self:SetScript("OnLeave", UnitFrame_OnLeave)
		self:RegisterForClicks("anyup")
		self:SetAttribute("*type2", "menu");
		
		self.menu = menu;
		self.colors = colors;
	end
	do -- setup base artwork
		local artwork = CreateFrame("Frame",nil,self);
		artwork:SetFrameStrata("BACKGROUND");
		artwork:SetAllPoints(self);
		
		self.Portrait = artwork:CreateTexture(nil,"BORDER");
		self.Portrait:SetWidth(55); self.Portrait:SetHeight(55);
		self.Portrait:SetPoint("LEFT",self,"LEFT",15,0);	
		
		artwork.bg = artwork:CreateTexture(nil,"BACKGROUND");
		artwork.bg:SetPoint("TOPLEFT",artwork,"TOPLEFT",-2,10);
		artwork.bg:SetTexture(base_plate);
	end
	do -- setup status bars
		do -- health bar
			local health = CreateFrame("StatusBar",nil,self);
			health:SetFrameStrata("LOW");
			health:SetWidth(119); health:SetHeight(16);
			health:SetStatusBarTexture(bar_texture);
			health:SetPoint("TOPRIGHT",self,"TOPRIGHT",-55,-26);
			
			health.value = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.value:SetWidth(110); health.value:SetHeight(12);
			health.value:SetJustifyH("LEFT"); health.value:SetJustifyV("TOP");
			health.value:SetPoint("RIGHT",health,"RIGHT",-2,0);
			
			health.ratio = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			health.ratio:SetWidth(40); health.ratio:SetHeight(12);
			health.ratio:SetJustifyH("LEFT"); health.ratio:SetJustifyV("TOP");
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
			power:SetFrameStrata("LOW");
			power:SetWidth(121); power:SetHeight(16);
			power:SetStatusBarTexture(bar_texture);
			power:SetPoint("TOPRIGHT",self.Health,"BOTTOMRIGHT",0,-1);
			
			power.value = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.value:SetWidth(110); power.value:SetHeight(12);
			power.value:SetJustifyH("LEFT"); power.value:SetJustifyV("TOP");
			power.value:SetPoint("RIGHT",power,"RIGHT",-2,0);
			
			power.ratio = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			power.ratio:SetWidth(40); power.ratio:SetHeight(12);
			power.ratio:SetJustifyH("LEFT"); power.ratio:SetJustifyV("TOP");
			power.ratio:SetPoint("LEFT",power,"RIGHT",2,0);			
			
			self.Power = power;
			self.Power.colorPower = true;
			self.Power.frequentUpdates = true;
			self.PostUpdatePower = PostUpdatePower;
		end
		do -- cast bar
			local cast = CreateFrame("StatusBar",nil,self);
			cast:SetWidth(136); cast:SetHeight(16);
			cast:SetStatusBarTexture(bar_texture);
			cast:SetPoint("TOPRIGHT",self.Power,"BOTTOMRIGHT",0,-1);
			
			cast.Text = cast:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			cast.Text:SetWidth(120); cast.Text:SetHeight(12);
			cast.Text:SetJustifyH("LEFT"); cast.Text:SetJustifyV("TOP");
			cast.Text:SetPoint("RIGHT",cast,"RIGHT",-2,0);
			
			cast.Time = cast:CreateFontString(nil, "OVERLAY", "SUI_FontOutline10");
			cast.Time:SetWidth(40); cast.Time:SetHeight(12);
			cast.Time:SetJustifyH("LEFT"); cast.Time:SetJustifyV("TOP");
			cast.Time:SetPoint("LEFT",cast,"RIGHT",2,0);
			
			self.Castbar = cast;
			self.PostCastStart = PostCastStart;
			self.PostChannelStart = PostChannelStart;
		end
	end
	do -- setup text and icons
		local overlay = CreateFrame("Frame",nil,self);
		overlay:SetAllPoints(self); overlay:SetFrameStrata("MEDIUM");
		
		overlay.ring = overlay:CreateTexture(nil,"BACKGROUND");
		overlay.ring:SetPoint("CENTER",self.Portrait,"CENTER",-2,-2);
		overlay.ring:SetTexture(base_ring);		
		
		self.Name = overlay:CreateFontString(nil, "BORDER","SUI_FontOutline11");
		self.Name:SetWidth(150); self.Name:SetHeight(13);
		self.Name:SetPoint("TOPRIGHT",self,"TOPRIGHT",-20,-10);
		self.Name:SetJustifyH("LEFT"); self.Name:SetJustifyV("BOTTOM");
		self:Tag(self.Name, "[name]");
			
		self.Level = overlay:CreateFontString(nil,"BORDER","SUI_FontOutline11");
		self.Level:SetWidth(40); self.Level:SetHeight(13);
		self.Level:SetJustifyH("CENTER"); self.Level:SetJustifyV("BOTTOM");
		self.Level:SetPoint("CENTER",self.Portrait,"CENTER",-27,27);
		self:Tag(self.Level, "[level]");
		
		self.ClassIcon = overlay:CreateTexture(nil,"BORDER");
		self.ClassIcon:SetWidth(20); self.ClassIcon:SetHeight(20);
		self.ClassIcon:SetPoint("CENTER",self.Portrait,"CENTER",23,24);

		self.Leader = overlay:CreateTexture(nil,"BORDER");
		self.Leader:SetWidth(24); self.Leader:SetHeight(24);
		self.Leader:SetPoint("CENTER",self.Portrait,"TOP",-1,6);
		--self.Leader.Hide = function() return; end; self.Leader:Show();
		
		self.MasterLooter = overlay:CreateTexture(nil,"BORDER");
		self.MasterLooter:SetWidth(20); self.MasterLooter:SetHeight(20);
		self.MasterLooter:SetPoint("CENTER",self.Portrait,"LEFT",-10,4);
		-- self.MasterLooter.Hide = function() return; end; self.MasterLooter:Show();

		self.PvP = overlay:CreateTexture(nil,"ARTWORK");
		self.PvP:SetWidth(50); self.PvP:SetHeight(50);
		self.PvP:SetPoint("CENTER",self.Portrait,"BOTTOMLEFT",5,-10);
			
		self.RaidIcon = overlay:CreateTexture(nil,"ARTWORK");
		self.RaidIcon:SetAllPoints(self.Portrait);

		self.StatusText = overlay:CreateFontString(nil, "OVERLAY", "SUI_FontOutline18");			
		self.StatusText:SetPoint("CENTER",self.Portrait,"CENTER");
		self.StatusText:SetJustifyH("CENTER");
		self:Tag(self.StatusText, "[afkdnd]");
	end
	do -- setup buffs and debuffs
		self.Auras = CreateFrame("Frame",nil,self);
		self.Auras:SetWidth(20*6); self.Auras:SetHeight(20*3);
		self.Auras:SetPoint("LEFT",self,"RIGHT",10,0);
		-- settings
		self.Auras.size = 20;
		self.Auras.spacing = 1;
		self.Auras.initialAnchor = "TOPLEFT";
		self.Auras.gap = false; -- adds an empty spacer between buffs and debuffs
		self.Auras.numBuffs = 12;
		self.Auras.numDebuffs = 6;	
		
		self.PreUpdateAura = PreUpdateAura;
	end
	return self;
end
local CreatePetFrame = function(self,unit)
	local base_plate = [[Interface\AddOns\SpartanUI_PartyFrames\media\base_plate2]]
	local base_ring = [[Interface\AddOns\SpartanUI_PartyFrames\media\base_ring2]]
	do -- create the base frame
		self:SetWidth(173); self:SetHeight(46);
		self:SetScript("OnEnter", UnitFrame_OnEnter)
		self:SetScript("OnLeave", UnitFrame_OnLeave)
		self:RegisterForClicks("anyup")
		
		self.colors = colors;
	end
	do -- setup base artwork
		local artwork = CreateFrame("Frame",nil,self);
		artwork:SetFrameStrata("BACKGROUND");
		artwork:SetAllPoints(self);
		
		self.Portrait = artwork:CreateTexture(nil,"BORDER");
		self.Portrait:SetWidth(32); self.Portrait:SetHeight(32);
		
		artwork.bg = artwork:CreateTexture(nil,"BACKGROUND");
		artwork.bg:SetPoint("CENTER"); artwork.bg:SetTexture(base_plate);
		self.Portrait:SetPoint("LEFT",self,"LEFT",6,0);
		
		local overlay = CreateFrame("Frame",nil,self);
		overlay:SetAllPoints(self); overlay:SetFrameStrata("MEDIUM");			
		overlay.ring = overlay:CreateTexture(nil,"BACKGROUND");
		overlay.ring:SetPoint("CENTER",self.Portrait,"CENTER");
		overlay.ring:SetTexture(base_ring);
		self.overlay = overlay;
	end
	do -- setup status bars
		do -- health bar
			local health = CreateFrame("StatusBar",nil,self);
			health:SetFrameStrata("LOW");
			health:SetWidth(97); health:SetHeight(11);
			health:SetStatusBarTexture(bar_texture);
			health:SetPoint("TOPRIGHT",self,"TOPRIGHT",-38,-18);
			
			health.value = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline9");
			health.value:SetWidth(80); health.value:SetHeight(11);
			health.value:SetJustifyH("LEFT"); health.value:SetJustifyV("TOP");
			health.value:SetPoint("RIGHT",health,"RIGHT",-2,0);
			
			health.ratio = health:CreateFontString(nil, "OVERLAY", "SUI_FontOutline9");
			health.ratio:SetWidth(40); health.ratio:SetHeight(11);
			health.ratio:SetJustifyH("LEFT"); health.ratio:SetJustifyV("TOP");
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
			power:SetFrameStrata("LOW");
			power:SetWidth(97); power:SetHeight(11);
			power:SetStatusBarTexture(bar_texture);
			power:SetPoint("TOPRIGHT",self.Health,"BOTTOMRIGHT",0,-2);
			
			power.value = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline9");
			power.value:SetWidth(80); power.value:SetHeight(11);
			power.value:SetJustifyH("LEFT"); power.value:SetJustifyV("TOP");
			power.value:SetPoint("RIGHT",power,"RIGHT",-2,0);
			
			power.ratio = power:CreateFontString(nil, "OVERLAY", "SUI_FontOutline9");
			power.ratio:SetWidth(40); power.ratio:SetHeight(11);
			power.ratio:SetJustifyH("LEFT"); power.ratio:SetJustifyV("TOP");
			power.ratio:SetPoint("LEFT",power,"RIGHT",2,0);			
			
			self.Power = power;
			self.Power.colorPower = true;
			self.Power.frequentUpdates = true;
			self.PostUpdatePower = PostUpdatePower;
		end
	end
	do -- setup text and icons
		local overlay = self.overlay;
		
		self.Name = overlay:CreateFontString(nil, "BORDER","SUI_FontOutline10");
		self.Name:SetWidth(110); self.Name:SetHeight(12);
		self.Name:SetPoint("TOPRIGHT",self,"TOPRIGHT",-12,-4);
		self.Name:SetJustifyH("LEFT");
		self:Tag(self.Name, "[name]");
			
		self.Level = overlay:CreateFontString(nil,"BORDER","SUI_FontOutline8");
		self.Level:SetWidth(30); self.Level:SetJustifyH("CENTER");
		self.Level:SetPoint("CENTER",self.Portrait,"CENTER",22,-8);
		self:Tag(self.Level, "[level]");
		
		self.RaidIcon = overlay:CreateTexture(nil,"ARTWORK");
		self.RaidIcon:SetAllPoints(self.Portrait);
	end
	do -- setup buffs and debuffs
		self.Auras = CreateFrame("Frame",nil,self);
		self.Auras:SetWidth(18*12); self.Auras:SetHeight(18*2);
		self.Auras:SetPoint("LEFT",self,"RIGHT");
		-- settings
		self.Auras.size = 18;
		self.Auras.spacing = 1;
		self.Auras.initialAnchor = "TOPLEFT";
		self.Auras.gap = true; -- adds an empty spacer between buffs and debuffs
		self.Auras.numBuffs = 11;
		self.Auras.numDebuffs = 12;
		
		self.PreUpdateAura = PreUpdateAura;
	end
	return self;
end
local CreateUnitFrames = function(self,unit)
	return (self:GetAttribute"unitsuffix" == "pet" and CreatePetFrame(self,unit)) or CreatePartyFrame(self,unit);
end
---------------------------------------------------------------------------
oUF:RegisterStyle("Spartan_PartyFrames", CreateUnitFrames);
oUF:SetActiveStyle("Spartan_PartyFrames");

local party = oUF:Spawn("header","SUI_PartyFrameHeader");
party:SetParent("SpartanUI");
party:SetClampedToScreen(true);
party:SetManyAttributes(
	"showSolo",						true,
	"showPlayer",					true,
	"showParty",						true,
	"yOffset",							-4,
	"xOffset",							0,
	"columnAnchorPoint",	"TOPLEFT",
	"initial-anchor",				"TOPLEFT",
	"template",						"SUI_PartyMemberTemplate");
PartyMemberBackground.Show = function() return; end
PartyMemberBackground:Hide();

function addon:UpdatePartyPosition()
	if suiChar.PartyFrames.partyMoved then
		party:SetMovable(true);
	else
		party:SetMovable(false);
		if LibStub("SpartanUI_PlayerFrames",true) then
			party:SetPoint("TOPLEFT",UIParent,"TOPLEFT",10,-20);
		else
			party:SetPoint("TOPLEFT",UIParent,"TOPLEFT",10,-140);
		end
	end
end

do -- create movable party scripts
	party.bg = party:CreateTexture(nil,"ARTWORK");
	party.bg:SetWidth(250); party.bg:SetHeight(332);
	party.bg:SetPoint("TOPLEFT");
	
	party.mover = CreateFrame("Frame");
	party.mover:SetAllPoints(party.bg);
	party.mover:EnableMouse(true);
	party.mover:SetScript("OnMouseDown",function()
		if IsAltKeyDown() then
			party.isMoving = true;
			suiChar.PartyFrames.partyMoved = true;
			party:SetMovable(true);
			party:StartMoving();
		end
	end);
	party.mover:SetScript("OnMouseUp",function()
		if party.isMoving then
			party.isMoving = nil;
			party:StopMovingOrSizing();
		end
	end);
	party.mover:SetScript("OnShow",function()
		party.bg:SetTexture(1,1,1,0.5);
	end);
	party.mover:SetScript("OnHide",function()
		party.bg:SetTexture(1,1,1,0);
		party.isMoving = nil;
		party:StopMovingOrSizing();
	end);
	party.mover:SetScript("OnEvent",function()
		-- fired when player enters combat
		party.mover:Hide();
	end);
	party.mover:Hide();
	
	addon:UpdatePartyPosition();
end
do -- handle party frame in raid hiding
	local partyWatch = CreateFrame("Frame");
	partyWatch:RegisterEvent('PLAYER_LOGIN');
	partyWatch:RegisterEvent('RAID_ROSTER_UPDATE');
	partyWatch:RegisterEvent('PARTY_LEADER_CHANGED');
	partyWatch:RegisterEvent('PARTY_MEMBERS_CHANGED');
	partyWatch:RegisterEvent('CVAR_UPDATE');
	partyWatch:SetScript('OnEvent', function(self)
		if InCombatLockdown() then self:RegisterEvent('PLAYER_REGEN_ENABLED'); return; end
		if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent('PLAYER_REGEN_ENABLED'); end
		-- we aren't in combat
		if (tonumber(GetCVar("hidePartyInRaid")) == 1) and (GetNumRaidMembers() > 0) then
			-- we are in a raid, and the hidePartyInRaid option is enabled
			party:Hide();
		else
			party:Show();
		end
	end);
end
