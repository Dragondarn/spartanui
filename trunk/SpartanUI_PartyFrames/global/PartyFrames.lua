local spartan = LibStub("AceAddon-3.0"):GetAddon("SpartanUI");
local addon = spartan:GetModule("PartyFrames");
----------------------------------------------------------------------------------------------------
oUF:SetActiveStyle("Spartan_PartyFrames");

local party = oUF:Spawn("header","SUI_PartyFrameHeader");
do -- party header configuration
	party:SetParent("SpartanUI");
	party:SetClampedToScreen(true);
	party:SetManyAttributes(
		--"showSolo",						true,
		--"showPlayer",					true,
		"showParty",						true,
		"yOffset",							-4,
		"xOffset",							0,
		"columnAnchorPoint",	"TOPLEFT",
		"initial-anchor",				"TOPLEFT");
	PartyMemberBackground.Show = function() return; end
	PartyMemberBackground:Hide();
end
do -- scripts to make it movable
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
	
	function addon:UpdatePartyPosition()
		if suiChar.PartyFrames.partyMoved then
			party:SetMovable(true);
		else
			party:SetMovable(false);
			if spartan:GetModule("PlayerFrames",true) then
				party:SetPoint("TOPLEFT",UIParent,"TOPLEFT",10,-20);
			else
				party:SetPoint("TOPLEFT",UIParent,"TOPLEFT",10,-140);
			end
		end
	end	
	addon:UpdatePartyPosition();
end
do -- hide party frame in raid, if option enabled
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