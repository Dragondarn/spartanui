local addon = LibStub:NewLibrary("SpartanUI",20090608);
if (not addon) then return; end
---------------------------------------------------------------------------
local anchor, frame = SUI_AnchorFrame, SpartanUI;
local getSpartanScale, getSpartanOffset;

do -- variables and settings
	suiChar = suiChar or {};
	if suiData then
		if suiData.relScale then suiChar.scale = suiData.relScale; end
	end
	addon.options = {name = "SpartanUI", type = "group", args = {}};
end
do -- special functions and scripts
	function getSpartanScale()
		if (not suiChar.scale) then
			local width, height = string.match((({GetScreenResolutions()})[GetCurrentResolution()] or ""), "(%d+).-(%d+)");		
			if (tonumber(width) / tonumber(height) > 4/3) then suiChar.scale = 0.92;
			else suiChar.scale = 0.78; end
		end	
		return math.floor( (SpartanUI:GetScale()*10^2)+0.5) / (10^2); -- rounds the scale to 2 decimal places	
	end
	function getSpartanOffset()
		if suiChar.offset then 
			return max(suiChar.offset,1);
		else
			local fubar = 0;
			for i = 1,4 do
				if (_G["FuBarFrame"..i] and _G["FuBarFrame"..i]:IsVisible()) then
					local bar = _G["FuBarFrame"..i];
					local point = bar:GetPoint(1);
					if point == "BOTTOMLEFT" then
						fubar = fubar + bar:GetHeight();
					end
				end
			end
			return max(fubar,1);
		end
	end
	function addon:print(message,prefix)
		if prefix then
			message = "SpartanUI: "..message;
		end
		DEFAULT_CHAT_FRAME:AddMessage(message,0,0.8,1);
	end
	function addon:MergeData(target,source)
		if type(target) ~= "table" then target = {} end
		for k,v in pairs(source) do
			if type(v) == "table" then
				target[k] = self:MergeData(target[k], v);
			else
				target[k] = v;
			end
		end
		return target;
	end
	frame:SetScript("OnUpdate",function()
		if (InCombatLockdown()) then return; end		
		if (suiChar.scale ~= getSpartanScale()) then
			frame:SetScale(suiChar.scale);
		end
	end);
	anchor:SetScript("OnUpdate",function()
		if (InCombatLockdown()) then return; end
		local offset = getSpartanOffset();
		if (anchor:GetHeight() ~= offset) then
			anchor:SetHeight(offset);
		end
	end);
	frame:SetScript("OnEvent",function()
		LibStub("AceConfig-3.0"):RegisterOptionsTable("SpartanUI", addon.options, {"sui", "spartanui"});
	end);
	frame:RegisterEvent("PLAYER_ENTERING_WORLD");
end
do -- default interface modifications
	FramerateLabel:ClearAllPoints();
	FramerateLabel:SetPoint("TOP", "WorldFrame", "TOP", -15, -50);
	MainMenuBar:Hide();
	hooksecurefunc("updateContainerFrameAnchors",function() -- fix bag offsets
		local frame, xOffset, yOffset, screenHeight, freeScreenHeight, leftMostPoint, column
		local screenWidth = GetScreenWidth()
		local containerScale = 1
		local leftLimit = 0
		if ( BankFrame:IsShown() ) then
			leftLimit = BankFrame:GetRight() - 25
		end
		while ( containerScale > CONTAINER_SCALE ) do
			screenHeight = GetScreenHeight() / containerScale
			-- Adjust the start anchor for bags depending on the multibars
			xOffset = 1 / containerScale
			yOffset = 155
			-- freeScreenHeight determines when to start a new column of bags
			freeScreenHeight = screenHeight - yOffset
			leftMostPoint = screenWidth - xOffset
			column = 1
			local frameHeight
			for index, frameName in ipairs(ContainerFrame1.bags) do
				frameHeight = getglobal(frameName):GetHeight()
				if ( freeScreenHeight < frameHeight ) then
					-- Start a new column
					column = column + 1
					leftMostPoint = screenWidth - ( column * CONTAINER_WIDTH * containerScale ) - xOffset
					freeScreenHeight = screenHeight - yOffset
				end
				freeScreenHeight = freeScreenHeight - frameHeight - VISIBLE_CONTAINER_SPACING
			end
			if ( leftMostPoint < leftLimit ) then
				containerScale = containerScale - 0.01
			else
				break
			end
		end
		if ( containerScale < CONTAINER_SCALE ) then
			containerScale = CONTAINER_SCALE
		end
		screenHeight = GetScreenHeight() / containerScale
		-- Adjust the start anchor for bags depending on the multibars
		xOffset = 1 / containerScale
		yOffset = 220
		-- freeScreenHeight determines when to start a new column of bags
		freeScreenHeight = screenHeight - yOffset
		column = 0
		for index, frameName in ipairs(ContainerFrame1.bags) do
			frame = getglobal(frameName)
			frame:SetScale(containerScale)
			if ( index == 1 ) then
				-- First bag
				frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -xOffset, yOffset )
			elseif ( freeScreenHeight < frame:GetHeight() ) then
				-- Start a new column
				column = column + 1
				freeScreenHeight = screenHeight - yOffset
				frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -(column * CONTAINER_WIDTH) - xOffset, yOffset )
			else
				-- Anchor to the previous bag
				frame:SetPoint("BOTTOMRIGHT", ContainerFrame1.bags[index - 1], "TOPRIGHT", 0, CONTAINER_SPACING)
			end
			freeScreenHeight = freeScreenHeight - frame:GetHeight() - VISIBLE_CONTAINER_SPACING
		end
	end);
	hooksecurefunc(GameTooltip,"SetPoint",function(tooltip,point,parent,rpoint) -- fix GameTooltip offset
		if (point == "BOTTOMRIGHT" and parent == "UIParent" and rpoint == "BOTTOMRIGHT") then
			tooltip:ClearAllPoints();
			tooltip:SetPoint("BOTTOM","SpartanUI","TOP",0,80);
		end
	end);
end
do -- framestrata and framelevel verification
	anchor:SetFrameStrata("BACKGROUND"); anchor:SetFrameLevel(1);
	frame:SetFrameStrata("BACKGROUND"); frame:SetFrameLevel(1);
end
do -- slash commands
	addon.options.args["reset"] = {
		type = "execute",
		name = "Reset Options",
		desc = "resets all options to default",
		func = function()
			if (InCombatLockdown()) then 
				addon:print(ERR_NOT_IN_COMBAT,true);
			else
				suiChar = nil;
				ReloadUI();
			end
		end
	};
	addon.options.args["maxres"] = {
		type = "execute",
		name = "Toggle Default Scales",
		desc = "toggles between widescreen and standard scales",
		func = function()
			if (InCombatLockdown()) then 
				addon:print(ERR_NOT_IN_COMBAT,true);
			else
				if (suiChar.scale >= 0.92) or (suiChar.scale < 0.78) then
					suiChar.scale = 0.78;
				else
					suiChar.scale = 0.92;
				end
				addon:print("Relative Scale set to "..suiChar.scale,true);
			end
		end
	};
	addon.options.args["scale"] = {
		type = "range",
		name = "Configure Scale",
		desc = "sets a specific scale for SpartanUI between 0.5 and 1",
		min = 0.5, max = 1, step = 0.01, 
		set = function(info,val)
			if (InCombatLockdown()) then 
				addon:print(ERR_NOT_IN_COMBAT,true);
			else
				suiChar.scale = min(1,max(0.5,val));
				addon:print("Relative Scale set to "..suiChar.scale,true);
			end
		end,
		get = function(info) return suiChar.scale; end
	};
	addon.options.args["offset"] = {
		type = "input",
		name = "Configure Offset",
		desc = "offsets the bottom bar automatically, or a set value",
		set = function(info,val)
			if (InCombatLockdown()) then 
				addon:print(ERR_NOT_IN_COMBAT,true);
			else
				if (val == "") or (val == "auto") then
					suiChar.offset = nil;
					addon:print("Panel Offset set to AUTO",true);
				else
					val = tonumber(val);
					if (type(val) == "number") then
						suiChar.offset = max(val+1,1);					
						addon:print("Panel Offset set to "..val,true);
					end
				end
			end
		end,
		get = function(info) return suiChar.offset; end
	};
end
