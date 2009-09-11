local addon = LibStub:GetLibrary("SpartanUI")
if not addon then return; end
---------------------------------------------------------------------------------------------------
local standard = "SpartanUI Standard"
local positions = {
	BT4Bar1 = {point = "CENTER",relTo = "SUI_Bar1",relPoint = "CENTER",x = 0,y = 0,scale = 0.8},
	BT4Bar2 = {point = "CENTER",relTo="SUI_Bar2",relPoint="CENTER",x = 0,y = 0,scale = 0.8},
	BT4Bar3 = {point = "CENTER",relTo="SUI_Bar3",relPoint="CENTER",x=0,y=0,scale = 0.8},
	BT4Bar4 = {point = "CENTER",relTo="SUI_Bar4",relPoint="CENTER",x=0,y=0,scale = 0.8},
	BT4Bar5 = {point = "CENTER",relTo="SUI_Bar5",relPoint="CENTER",x=0,y=0,scale = 0.8},
	BT4Bar6 = {point = "CENTER",relTo="SUI_Bar6",relPoint="CENTER",x=0,y=0,scale = 0.8},
	BT4BarMicroMenu = {point = "LEFT",relTo="SUI_Popup2",relPoint="LEFT",x=10,y=0,scale = 0.8},
	BT4BarBagBar = {point = "RIGHT",relTo="SUI_Popup2",relPoint="RIGHT",x=-12,y=4,scale = 0.7},
	BT4BarPetBar = {point = "LEFT",relTo="SUI_Popup1",relPoint="LEFT",x=12,y=0,scale = 0.8},
	BT4BarStanceBar = {point = "RIGHT",relTo="SUI_Popup1",relPoint="RIGHT",x=-16,y=0,scale = 0.8}
}
local settings = {
	ActionBars = {
		actionbars = { -- following settings are bare minimum, so that anything not defined is retained between resets
			{enabled = true,rows = 1,padding = 6,skin = {Zoom = true}}, -- 1
			{enabled = true,rows = 1,padding = 6,skin = {Zoom = true}}, -- 2
			{enabled = true,rows = 1,padding = 6,skin = {Zoom = true}}, -- 3
			{enabled = true,rows = 1,padding = 6,skin = {Zoom = true}}, -- 4
			{enabled = true,rows = 3,padding = 5,skin = {Zoom = true}}, -- 5
			{enabled = true,rows = 3,padding = 5,skin = {Zoom = true}}, -- 6
			{enabled = false}, -- 7
			{enabled = false}, -- 8
			{enabled = false}, -- 9
			{enabled = false} -- 10
		}
	},
	MicroMenu = {enabled = true,padding = -2},
	BagBar = {enabled = true,rows = 1,padding = 1,keyring = true},
	PetBar = {enabled = true,rows = 1,padding = 1,skin = {Zoom = true}},
	StanceBar = {enabled = true,rows = 1,padding = 1},
	RepBar = {enabled = false},
	XPBar = {enabled = false},
}

---------------------------------------------------------------------------------------------------
function addon:BartenderMerge(target, source)
	if type(target) ~= "table" then target = {} end
	for k,v in pairs(source) do
		if type(v) == "table" then
			target[k] = self:BartenderMerge(target[k], v)
		else
			target[k] = v
		end
	end
	return target
end
function addon:BartenderUpdate() -- hides or shows the backdrops based on a saved variable
	for i = 1,6 do -- for each BT4 Bar Backdrop
		suiChar["bar"..i] = suiChar["bar"..i] or 1; -- make sure the setting exists, enabled by default
		_G["SUI_Bar"..i]:SetAlpha(suiChar["bar"..i]); --  make it visible
	end
	for i = 1,2 do -- for each BT4 Popup Bar
		suiChar["popup"..i] = suiChar["popup"..i] or 1; -- make sure the setting exists, enabled by default
		_G["SUI_Popup"..i]:SetAlpha(suiChar["popup"..i]); -- make it visible
		if (suiChar["popup"..i] > 0) then
			_G["SUI_Popup"..i.."MaskBG"]:SetAlpha(1);
		else
			_G["SUI_Popup"..i.."MaskBG"]:SetAlpha(0);
		end
	end
end
function addon:BartenderProfile() -- reconfigures a custom BT4 profile for SpartanUI
	if not Bartender4 then return; end -- do nothing when BT4 isn't installed
	if suiChar.BT4Profile then return; end -- do nothing if the profile has already been configured
	Bartender4.db:SetProfile(standard)
	for k,v in LibStub("AceAddon-3.0"):IterateModulesOfAddon(Bartender4) do -- for each module (BagBar, ActionBars, etc..)
		if settings[k] and v.db.profile then
			v.db.profile = addon:BartenderMerge(v.db.profile,settings[k])
		end
	end
	Bartender4:UpdateModuleConfigs(); -- run ApplyConfig for all modules, so that the new settings are applied ]]
	suiChar.BT4Profile = true; -- set the profile switch so that we don't run this config again
end
function addon:BartenderPopup() -- candidate for direct insertion into the OnUpdate
	if suiData.popUps then -- if popups are enabled
		if (MouseIsOver(SUI_Popup1Mask)) then -- if the mouse is over the left popup bar
			if (SUI_Popup1MaskBG:IsVisible()) then SUI_Popup1MaskBG:Hide(); end -- hide the left overlay texture (optimized)
			if (not SUI_Popup2MaskBG:IsVisible()) then SUI_Popup2MaskBG:Show(); end -- show the right overlay texture (optimized)
		elseif (MouseIsOver(SUI_Popup2Mask)) then -- if the mouse is over the right popup bar
			if (SUI_Popup2MaskBG:IsVisible()) then SUI_Popup2MaskBG:Hide(); end -- hide the right overlay texture (optimized)
			if (not SUI_Popup1MaskBG:IsVisible()) then SUI_Popup1MaskBG:Show(); end -- show the left overlay texture (optimized)
		else
			if (not SUI_Popup1MaskBG:IsVisible()) then SUI_Popup1MaskBG:Show(); end -- show the left overlay texture (optimized)
			if (not SUI_Popup2MaskBG:IsVisible()) then SUI_Popup2MaskBG:Show(); end -- show the right overlay texture (optimized)
		end
	else -- if popups are not enabled
		if (SUI_Popup1MaskBG:IsVisible()) then SUI_Popup1MaskBG:Hide(); end -- hide the left overlay texture (optimized)
		if (SUI_Popup2MaskBG:IsVisible()) then SUI_Popup2MaskBG:Hide(); end -- hide the right overlay texture (optimized)
	end
end
function addon:BartenderLayout()
	if not Bartender4 then return; end -- do nothing when BT4 isn't installed
	if (Bartender4.db:GetCurrentProfile() ~= standard) then return; end -- do nothing if the SpartanUI BT4 profile isn't selected
	for bar,data in pairs(positions) do -- for each bar that needs to be repositioned
		if (_G[bar]) then -- if the bar exists
			local _,owner = _G[bar]:GetPoint();
			if (not owner) or (owner:GetName() ~= data.relTo) then
				_G[bar]:ClearSetPoint(data.point,data.relTo,data.relPoint,data.x,data.y); -- use the BT4 setpoint to reposition the bar
			end
			local barScale = data.scale*suiData.relScale; -- get the scale relative to SpartanUI
			if (_G[bar]:GetScale() ~= barScale) then -- if the scale of the bar doesn't match our calculated value
				_G[bar]:SetScale(barScale); -- rescale the bar to match
			end
		end
	end
end
----------------------------------------------------------------------------------------------------
SUI_BartenderPlate:RegisterEvent("PLAYER_ENTERING_WORLD");
SUI_BartenderPlate:SetScript("OnEvent",function()
	addon:BartenderProfile()
end);
SUI_BartenderPlate:SetScript("OnUpdate",function()
	addon:BartenderPopup() -- consider folding function code directly into this script
	addon:BartenderLayout()
	addon:BartenderUpdate()
end);
