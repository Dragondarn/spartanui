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
