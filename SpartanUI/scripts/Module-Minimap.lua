local addon = LibStub("AceAddon-3.0"):GetAddon("SpartanUI");
local module = addon:NewModule("Minimap");
---------------------------------------------------------------------------
local checkThirdParty, frame = function()
	local point, relativeTo, relativePoint, x, y = MinimapCluster:GetPoint();
	if (relativeTo ~= UIParent) then return true; end -- a third party minimap manager is involved
end;
local updateButtons = function()
	if (not MouseIsOver(Minimap)) and (suiChar.MapButtons) then
		GameTimeFrame:Hide();
		MiniMapTracking:Hide();
		MinimapZoomIn:Hide();
		MinimapZoomOut:Hide();
		MiniMapWorldMapButton:Hide();
	else
		GameTimeFrame:Show();
		MiniMapTracking:Show();
		MiniMapWorldMapButton:Show();
	end
end
local modifyMinimapLayout = function()
	frame = CreateFrame("Frame",nil,SpartanUI);
	frame:SetWidth(158); frame:SetHeight(158);
	frame:SetPoint("CENTER",0,54);
	
	Minimap:SetParent(frame); Minimap:SetWidth(158); Minimap:SetHeight(158);
	Minimap:ClearAllPoints(); Minimap:SetPoint("CENTER");
	
	MinimapBackdrop:ClearAllPoints(); MinimapBackdrop:SetPoint("CENTER",frame,"CENTER",-10,-24);
	MinimapZoneTextButton:SetParent(frame); MinimapZoneTextButton:ClearAllPoints(); MinimapZoneTextButton:SetPoint("TOP",frame,"BOTTOM",0,-6);
	MinimapBorderTop:Hide(); MinimapBorder:SetAlpha(0);		
	MinimapZoomIn:Hide(); MinimapZoomOut:Hide();	
	Minimap.overlay = Minimap:CreateTexture(nil,"OVERLAY");
	Minimap.overlay:SetWidth(250); Minimap.overlay:SetHeight(250); 
	Minimap.overlay:SetTexture("Interface\\AddOns\\SpartanUI\\media\\map-overlay");
	Minimap.overlay:SetPoint("CENTER"); Minimap.overlay:SetBlendMode("ADD");	
	
	frame:EnableMouse(true);
	frame:EnableMouseWheel(true);	
	frame:SetScript("OnMouseWheel",function()
		if (arg1 > 0) then Minimap_ZoomIn()
		else Minimap_ZoomOut() end
	end);
end;
local createMinimapCoords = function()
	local map = CreateFrame("Frame",nil,SpartanUI);
	map.coords = map:CreateFontString(nil,"BACKGROUND","GameFontNormalSmall");
	map.coords:SetWidth(128); map.coords:SetHeight(12);
	map.coords:SetPoint("TOP","MinimapZoneTextButton","BOTTOM",0,-6);
	map:HookScript("OnUpdate", function()
		updateButtons();
		do -- update minimap coordinates
			local x,y = GetPlayerMapPosition("player");
			if (not x) or (not y) then return; end
			map.coords:SetText(format("%.1f, %.1f",x*100,y*100));
		end
	end);
	map:HookScript("OnEvent",function()
		if (event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA") then
			if IsInInstance() then map.coords:Hide() else map.coords:Show() end
			if (WorldMapFrame:IsVisible()) then SetMapToCurrentZone(); end
		elseif (event == "ADDON_LOADED") then
			print(arg1);			
		end
		local LastFrame = UIErrorsFrame;
		for i = 1, NUM_EXTENDED_UI_FRAMES do
			local bar = _G["WorldStateCaptureBar"..i];
			if (bar and bar:IsShown()) then 			
				bar:ClearAllPoints();
				bar:SetPoint("TOP",LastFrame,"BOTTOM");			
				LastFrame = self;
			end
		end
	end);
	map:RegisterEvent("ZONE_CHANGED");
	map:RegisterEvent("ZONE_CHANGED_INDOORS");
	map:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	map:RegisterEvent("UPDATE_WORLD_STATES");	
	map:RegisterEvent("UPDATE_BATTLEFIELD_SCORE");	
	map:RegisterEvent("PLAYER_ENTERING_WORLD");
	map:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND");
	map:RegisterEvent("WORLD_STATE_UI_TIMER_UPDATE");	
end
---------------------------------------------------------------------------
function module:OnInitialize()
	addon.options.args["minimap"] = {
		name = "toggle Minimap Button Hiding", type="input",
		get = function(info) return suiChar and suiChar.MapButtons; end,
		set = function(info,val)
			if (val == "" and suiChar.MapButtons == true) or (val == "off") then
				suiChar.MapButtons = nil;
				addon:Print("Minimap Button Hiding Disabled");
			elseif (val == "" and not suiChar.MapButtons) or (val == "on") then
				suiChar.MapButtons = true;
				addon:Print("Minimap Button Hiding Enabled");
			end
		end
	};
end
function module:OnEnable()
	if (checkThirdParty()) then return; end
	modifyMinimapLayout();
	createMinimapCoords();
	LFDSearchStatus:ClearAllPoints();
	LFDSearchStatus:SetPoint("BOTTOM",SpartanUI,"TOP",0,100);
	ConsolidatedBuffs:ClearAllPoints();
	ConsolidatedBuffs:SetPoint("TOPRIGHT",-13,-13);	
end
