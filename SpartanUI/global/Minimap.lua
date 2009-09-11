local map = CreateFrame("Frame");

do -- default interface modifications
	MinimapBorderTop:Hide();
	MinimapToggleButton:Hide();
	MinimapZoomIn:Hide();
	MinimapZoomOut:Hide();
	MinimapBackdrop:ClearAllPoints();
	MinimapBackdrop:SetPoint("CENTER","MinimapCluster","CENTER",-10,-24);
	MinimapBorder:SetAlpha(0);
	Minimap:ClearAllPoints();
	Minimap:SetPoint("CENTER","MinimapCluster","CENTER",0,2);
	GameTimeFrame:SetScale(0.6);
	GameTimeFrame:ClearAllPoints();
	GameTimeFrame:SetPoint("TOPRIGHT","Minimap","TOPRIGHT",5,-5);
	MiniMapTracking:SetScale(0.8);
	MiniMapTracking:ClearAllPoints();
	MiniMapTracking:SetPoint("TOPLEFT",20,-36);
	MinimapZoneTextButton:ClearAllPoints();
	MinimapZoneTextButton:SetPoint("BOTTOM","SpartanUI","BOTTOM",0,24);
	
	map.overlay = Minimap:CreateTexture(nil,"OVERLAY");
	map.overlay:SetWidth(228); map.overlay:SetHeight(228); map.overlay:SetPoint("CENTER");
	map.overlay:SetTexture("Interface\\AddOns\\SpartanUI\\media\\map_overlay");
	map.overlay:SetBlendMode("ADD");
	
	map.coords = MinimapZoneTextButton:CreateFontString(nil,"BACKGROUND","GameFontNormalSmall");
	map.coords:SetWidth(128); map.coords:SetHeight(12);
	map.coords:SetPoint("TOP","MinimapZoneTextButton","BOTTOM");	
end
do -- scripts that drive special functions
	MinimapCluster:EnableMouseWheel(true);
	MinimapCluster:SetScript("OnMouseWheel",function()
		if (arg1 > 0) then Minimap_ZoomIn()
		else Minimap_ZoomOut() end
	end);
	
	map:SetScript("OnUpdate", function()
		local x,y = GetPlayerMapPosition("player");
		if (not x) or (not y) then return; end
		map.coords:SetText(format("%.1f, %.1f",x*100,y*100));
 	end);
	map:SetScript("OnEvent",function()
		if event == "PLAYER_ENTERING_WORLD" then
			MinimapCluster:ClearAllPoints();
			MinimapCluster:SetParent("SpartanUI");
			MinimapCluster:SetPoint("BOTTOM","SpartanUI","BOTTOM",0,20)
			MinimapCluster:SetScale(1.1);
			MinimapCluster:SetMovable(true);
			MinimapCluster:SetUserPlaced(true);
			
			TemporaryEnchantFrame:ClearAllPoints();
			TemporaryEnchantFrame:SetPoint("TOPRIGHT",UIParent,"TOPRIGHT",-10,-10);
		else
			if (not WorldMapFrame:IsVisible()) then return; end
			if IsInInstance() then map.coords:Hide() else map.coords:Show() end
			SetMapToCurrentZone();
		end
	end);
	map:RegisterEvent("PLAYER_ENTERING_WORLD");
	map:RegisterEvent("ZONE_CHANGED_INDOORS");
	map:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	map:RegisterEvent("ZONE_CHANGED");
	
	hooksecurefunc(WatchFrame,"SetPoint",function(_,_,parent)
		if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
			-- this only happens if the user isn't using the advanced quest watcher
			WatchFrame:ClearAllPoints();
			WatchFrame:SetPoint("TOPRIGHT","UIParent","TOPRIGHT",-4,-130);
			WatchFrame:SetPoint("BOTTOMRIGHT","UIParent","BOTTOMRIGHT",-4,160);
		end
	end);
	hooksecurefunc(DurabilityFrame,"SetPoint",function(self,_,parent)
		if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
			DurabilityFrame:ClearAllPoints();
			DurabilityFrame:SetPoint("RIGHT",UIParent,"RIGHT",-10,0);
		end
	end);
end
