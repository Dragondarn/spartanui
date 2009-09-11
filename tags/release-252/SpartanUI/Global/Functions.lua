local CurrentVersion = 20081120; -- 2.5.2
local addon = LibStub:NewLibrary("SpartanUI",CurrentVersion)
if not addon then return; end
---------------------------------------------------------------------------------------------------
addon.CurrentVersion = CurrentVersion;
do -- startup functions
	if (type(suiData)~="table") then suiData = {} end
	if (type(suiChar)~="table") then suiChar = {} end
	local defaults = {
		buffToggle = true,
		partyToggle = "on",
		relScale = 0.92,
		raidIcons = "Default",
		PartyInRaid = "off",
		autoFaction = true,
		popUps = true,
	}
	-- database versioning isn't really being used right now. All we need is inclusion of new vars:
	for k,v in pairs(defaults) do
		suiData[k] = suiData[k] or v
	end
	MainMenuBar:Hide()
	MultiBarBottomLeft:Hide()
	MultiBarBottomRight:Hide()
	MultiBarLeft:Hide()
	MultiBarRight:Hide()
end
----------------------------------------------------------------------------------------------------
-- this spot will be filled with the slash command handler
----------------------------------------------------------------------------------------------------
-- this spot will be filled with the OnEvent handler subsystem
----------------------------------------------------------------------------------------------------
-- this spot will be filled with the OnUpdate handler subsystem
----------------------------------------------------------------------------------------------------
local round = function(num,places)
	if places then
		return math.floor( (num*10^places)+0.5) / (10^places)
	else
		return math.floor(num+0.5)
	end
end;
SpartanUI:SetScript("OnUpdate",function()
	suiData.relScale = suiData.relScale or 0.92;
	local scale = SpartanUI:GetScale()
	if (round(scale,2) ~= suiData.relScale) then
		SpartanUI:SetScale(suiData.relScale);
--		DEFAULT_CHAT_FRAME:AddMessage("Setting the scale of SpartanUI to "..suiData.relScale.." from "..round(scale,2));
	end
end);
