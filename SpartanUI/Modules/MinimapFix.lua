if Minimap:IsUserPlaced() then return; end
---------------------------------------------------------------------------------------------------
local UpdateFramePositions = function()
	QuestWatchFrame:ClearAllPoints()
	QuestWatchFrame:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -20, 200)
	QuestTimerFrame:ClearAllPoints()
	QuestTimerFrame:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 250)
	DurabilityFrame:ClearAllPoints()
	DurabilityFrame:SetPoint("BOTTOM", "SUI_MapOverlay", "TOP", 0, 0)
	if ( NUM_EXTENDED_UI_FRAMES ) then
		for i = 1, NUM_EXTENDED_UI_FRAMES do addon.UpdateCaptureBar(i) end
	end
end
local UpdateCaptureBar = function(id,val,percent)
	local bar = getglobal("WorldStateCaptureBar"..id)
	if not bar then return; end
	bar:ClearAllPoints()
	bar:SetPoint("BOTTOMRIGHT", "QuestWatchFrame", "TOPRIGHT", 0, 20)
end
do
	MinimapBorderTop:Hide()
	MinimapToggleButton:Hide()
	MinimapBorder:Hide()

	Minimap:ClearAllPoints()
	Minimap:SetParent(SpartanUI)
	Minimap:SetPoint("CENTER", "SUI_MapOverlay", "CENTER")
	Minimap:SetHeight(154)
	Minimap:SetWidth(154)

	MinimapCluster:SetMovable(true);
	MinimapCluster:SetUserPlaced(true);
	MinimapCluster:ClearAllPoints()
	MinimapCluster:SetPoint("CENTER", "SUI_MapOverlay", "CENTER", -10, -4)

	MinimapZoneText:ClearAllPoints()
	MinimapZoneText:SetParent(Minimap)
	MinimapZoneText:SetPoint("BOTTOM", "SUI_MapOverlay", "BOTTOM", 0, 24)

	MinimapZoneTextButton:ClearAllPoints()
	MinimapZoneTextButton:SetPoint("BOTTOM", "MinimapZoneText", "BOTTOM", 0, 0)

	MinimapZoomIn:SetParent(Minimap)
	MinimapZoomOut:SetParent(Minimap)
	MiniMapTracking:SetParent(Minimap)
	MiniMapWorldMapButton:SetParent(Minimap)

	SUI_MinimapCoords:SetWidth(100)	-- Limit the width of the coordinate textbox

	GameTimeFrame:SetScale(0.85)
	local point, __, relativePoint = GameTimeFrame:GetPoint()
	GameTimeFrame:SetParent(Minimap)
	GameTimeFrame:SetFrameLevel(5)
	GameTimeFrame:SetPoint(point, "Minimap", relativePoint)

	hooksecurefunc("CaptureBar_Update", UpdateCaptureBar)
	hooksecurefunc("UIParent_ManageFramePositions", UpdateFramePositions)

	UpdateFramePositions()
	if ( BattlefieldMinimapTab and not BattlefieldMinimapTab:IsUserPlaced() ) then
		BattlefieldMinimapTab:ClearAllPoints()
		BattlefieldMinimapTab:SetPoint("TOP", "UIParent", "TOP", 0, 0)
	end
end
---------------------------------------------------------------------------------------------------
local frame = CreateFrame("Frame","SUI_MinimapEventHandler",UIParent)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ZONE_CHANGED")
frame:SetScript("OnUpdate", function(self, elapsed) UpdateCoords(self, elapsed) end)
frame:SetScript("OnEvent",function()
	if IsInInstance() then
		SUI_MinimapCoords:Hide()
	elseif not WorldMapFrame:IsVisible() then
		SUI_MinimapCoords:Show()
		SetMapToCurrentZone()
	end
end)

local FrequentInterval, x, y = 0
function UpdateCoords(self, elapsed)
	FrequentInterval = FrequentInterval + elapsed
	if (FrequentInterval >= 0.36) and not IsInInstance() then
		x,y = GetPlayerMapPosition("player")
		if (not x) or (not y) then return; end
		SUI_MinimapCoords:SetText(format("%.1f, %.1f",x*100,y*100))
		FrequentInterval = 0
	end
end