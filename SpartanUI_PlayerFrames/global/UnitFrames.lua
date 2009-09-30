local spartan = LibStub("AceAddon-3.0"):GetAddon("SpartanUI");
local addon = spartan:NewModule("PlayerFrames");
----------------------------------------------------------------------------------------------------
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
do -- Level Skull as an oUF module
	local Update = function(self,event,unit)
		if (self.LevelSkull) then
			local level = UnitLevel(unit);
			self.LevelSkull:SetTexture[[Interface\TargetingFrame\UI-TargetingFrame-Skull]]
			if level < 0 then
				self.LevelSkull:SetTexCoord(0,1,0,1);
				if self.Level then self.Level:SetText"" end
			else
				self.LevelSkull:SetTexCoord(0,0.01,0,0.01);
			end
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
		if (self.RareElite) then
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
	end
	local Enable = function(self)
		if (self.RareElite) then return true; end
	end
	local Disable = function(self) return; end
	oUF:AddElement('RareElite', Update,Enable,Disable);
end


