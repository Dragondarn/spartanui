local spartan = LibStub("AceAddon-3.0"):GetAddon("SpartanUI");
local addon = spartan:GetModule("PlayerFrames");
----------------------------------------------------------------------------------------------------
oUF:SetActiveStyle("Spartan_PlayerFrames");

local focus = oUF:Spawn("focus","SUI_FocusFrame");
addon.focus = focus; addon.focus:SetPoint("CENTER",UIParent,"CENTER");

do -- scripts to make it movable
	focus.mover = CreateFrame("Frame");	
	focus.mover:SetWidth(200); focus.mover:SetHeight(80);
	focus.mover:SetPoint("CENTER",focus,"CENTER");	
	focus.mover:EnableMouse(true);
	
	focus.bg = focus.mover:CreateTexture(nil,"BACKGROUND");
	focus.bg:SetAllPoints(focus.mover);
	focus.bg:SetTexture(1,1,1,0.5);
	
	focus.mover:SetScript("OnMouseDown",function()
		focus.isMoving = true;
		suiChar.PlayerFrames.focusMoved = true;
		focus:SetMovable(true);
		focus:StartMoving();
	end);
	focus.mover:SetScript("OnMouseUp",function()
		if focus.isMoving then
			focus.isMoving = nil;
			focus:StopMovingOrSizing();
		end
	end);
	focus.mover:SetScript("OnHide",function()
		focus.isMoving = nil;
		focus:StopMovingOrSizing();
	end);
	focus.mover:SetScript("OnEvent",function()
		addon.locked = 1;
		focus.mover:Hide();
	end);
	focus.mover:RegisterEvent("VARIABLES_LOADED");
	focus.mover:RegisterEvent("PLAYER_REGEN_DISABLED");
	
	function addon:UpdateFocusPosition()
		if suiChar.PlayerFrames.focusMoved then
			focus:SetMovable(true);
		else
			focus:SetMovable(false);
			focus:SetPoint("BOTTOMLEFT",SpartanUI,"TOP",200,200);
		end
	end	
	addon:UpdateFocusPosition();
end
