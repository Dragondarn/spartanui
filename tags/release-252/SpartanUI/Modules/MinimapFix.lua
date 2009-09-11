if Minimap:IsUserPlaced() then return; end
---------------------------------------------------------------------------------------------------
local UpdateCaptureBar = function(id,val,percent) -- is this correct? multiple capture bars might be stacked on top of each other?
	local bar = getglobal("WorldStateCaptureBar"..id)
	if not bar then return; end
	bar:ClearAllPoints()
	bar:SetPoint("BOTTOMRIGHT","AchievementWatchFrame","TOPRIGHT", 0, 20)
end
local UpdateFramePositions = function() --might need to add positioning fixes for buff frames, in case the custom buff module is disabled?
	if ( NUM_EXTENDED_UI_FRAMES ) then
		for i = 1, NUM_EXTENDED_UI_FRAMES do UpdateCaptureBar(i) end
	end
end
do -- placement
	AchievementWatchFrame:ClearAllPoints()
	AchievementWatchFrame:SetPoint("TOPLEFT","UIParent","TOPLEFT",10,-10)
	AchievementWatchFrame.SetPoint = function() end -- prevents this frame from moving again

	QuestWatchFrame:ClearAllPoints()
	QuestWatchFrame:SetPoint("TOPLEFT","AchievementWatchFrame","BOTTOMLEFT",0,-20)
	QuestWatchFrame.SetPoint = function() end -- prevents this frame from moving again

	QuestTimerFrame:ClearAllPoints()
	QuestTimerFrame:SetPoint("TOP","UIParent","TOP")
	QuestTimerFrame.SetPoint = function() end -- prevents this frame from moving again

	DurabilityFrame:ClearAllPoints()
	DurabilityFrame:SetPoint("BOTTOM","SpartanUI","TOP")
	DurabilityFrame.SetPoint = function() end -- prevents this frame from moving again

	MinimapBorderTop:Hide()
	MinimapToggleButton:Hide()
	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()

	MinimapBackdrop:ClearAllPoints()
	MinimapBackdrop:SetPoint("CENTER","MinimapCluster","CENTER",-10,-24)
	MinimapBorder:SetAlpha(0) -- dont actually hide it, since some buttons attach to it

	Minimap:ClearAllPoints()
	Minimap:SetPoint("CENTER","MinimapCluster","CENTER",0,2)

	GameTimeFrame:SetScale(0.7)
	GameTimeFrame:ClearAllPoints()
	GameTimeFrame:SetPoint("TOPRIGHT","Minimap","TOPRIGHT",14,-8)
	GameTimeFrame:SetFrameStrata("HIGH")

	MiniMapTracking:SetScale(0.8)
	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetPoint("TOPLEFT",20,-36)

	MinimapZoneTextButton:ClearAllPoints()
	MinimapZoneTextButton:SetPoint("BOTTOM","SpartanUI","BOTTOM",0,24)

	local overlay = Minimap:CreateTexture(nil,"OVERLAY")
	overlay:SetWidth(228); overlay:SetHeight(228); overlay:SetPoint("CENTER");
	overlay:SetTexture("Interface\\AddOns\\SpartanUI\\Media\\Object_Minimap_Overlay")
	overlay:SetBlendMode("ADD")

	hooksecurefunc("CaptureBar_Update", UpdateCaptureBar)
	hooksecurefunc("UIParent_ManageFramePositions", UpdateFramePositions)
	UpdateFramePositions()
	if ( BattlefieldMinimapTab and not BattlefieldMinimapTab:IsUserPlaced() ) then
		BattlefieldMinimapTab:ClearAllPoints()
		BattlefieldMinimapTab:SetPoint("TOP", "UIParent", "TOP", 0, 0)
	end
end
do -- enhancements
	-- minimap mousewheel zooming
	MinimapCluster:EnableMouseWheel(true);
	MinimapCluster:SetScript("OnMouseWheel",function()
		if (arg1 > 0) then Minimap_ZoomIn()
		else Minimap_ZoomOut() end
	end)
	-- create coordinates frame to show minimap coordinates
	local coords = MinimapZoneTextButton:CreateFontString(nil,"BACKGROUND","GameFontNormalSmall")
	coords:SetWidth(128); coords:SetHeight(12);
	coords:SetPoint("TOP","MinimapZoneTextButton","BOTTOM");
	MinimapZoneTextButton:SetScript("OnUpdate", function(self, elapsed)
		local x,y = GetPlayerMapPosition("player")
		if (not x) or (not y) then return; end
		coords:SetText(format("%.1f, %.1f",x*100,y*100))
 	end)
 	MinimapZoneTextButton:RegisterEvent("PLAYER_ENTERING_WORLD");
 	MinimapZoneTextButton:RegisterEvent("ZONE_CHANGED");
 	MinimapZoneTextButton:SetScript("OnEvent",function()
		if (event == "PLAYER_ENTERING_WORLD") then
			MinimapCluster:ClearAllPoints()
			MinimapCluster:SetParent("SpartanUI")
			MinimapCluster:SetPoint("BOTTOM","SpartanUI","BOTTOM",0,20)
			MinimapCluster:SetScale(1.1)
			MinimapCluster:SetMovable(true)
			MinimapCluster:SetUserPlaced(true)
			--MinimapCluster:SetFrameStrata("MEDIUM")
		end
 		if (not WorldMapFrame:IsVisible()) then return; end
 		if IsInInstance() then coords:Hide() else coords:Show() end
 		SetMapToCurrentZone()
	end);
end
