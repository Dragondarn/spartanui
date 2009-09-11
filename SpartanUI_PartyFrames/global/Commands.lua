local addon = LibStub:GetLibrary("SpartanUI_PartyFrames");
if (not addon) then return; end
---------------------------------------------------------------------------
local spartan = LibStub:GetLibrary("SpartanUI");
function addon:UpdateAuraVisibility()
	for i = 1,4 do
		local pet = _G["SUI_PartyFrameHeaderUnitButton"..i.."Pet"];
		local unit = _G["SUI_PartyFrameHeaderUnitButton"..i];
		if pet and pet.Auras then pet:PostUpdateAura(); end
		if unit and unit.Auras then unit:PostUpdateAura(); end
	end
end
---------------------------------------------------------------------------
if not spartan.options.args.auras then
	spartan.options.args["auras"] = {
		name = "Unitframe Auras",
		desc = "unitframe aura settings",
		type = "group", args = {}
	};
end
spartan.options.args.auras.args.party = {
	name = "toggle party auras", type = "toggle", 
	get = function(info) return suiChar.PartyFrames.showAuras; end,
	set = function(info,val)
		if suiChar.PartyFrames.showAuras == 0 then
			suiChar.PartyFrames.showAuras = 1;
			spartan:print("Party Auras Enabled",true);
		else
			suiChar.PartyFrames.showAuras = 0;
			spartan:print("Party Auras Disabled",true);
		end
		addon:UpdateAuraVisibility();
	end
};
spartan.options.args["party"] = {
	type = "input",
	name = "lock, unlock or reset party frame positioning",
	set = function(info,val)
		if (InCombatLockdown()) then 
			addon:print(ERR_NOT_IN_COMBAT,true);
		else
			if (val == "" and suiChar.PartyFrames.partyLock == 1) or (val == "unlock") then
				suiChar.PartyFrames.partyLock = 0;
				SUI_PartyFrameHeader.mover:Show();
			elseif (val == "" and suiChar.PartyFrames.partyLock == 0) or (val == "lock") then
				suiChar.PartyFrames.partyLock = 1;
				SUI_PartyFrameHeader.mover:Hide();
			elseif val == "reset" then
				suiChar.PartyFrames.partyMoved = nil;
				addon:UpdatePartyPosition();
			end
		end
	end,
	get = function(info) return suiChar and suiChar.PartyFrames and suiChar.PartyFrames.partyLock; end
};
