do -- experience bar (now fully localized!)
	SUI_ExperienceBar:SetPoint("BOTTOMRIGHT","SpartanUI","BOTTOM",-80,0);
	SUI_ExperienceBar:EnableMouse(true);
	for __,event in pairs({"PLAYER_ENTERING_WORLD","PLAYER_XP_UPDATE"}) do SUI_ExperienceBar:RegisterEvent(event); end
	SUI_ExperienceBarFill:SetVertexColor(0,0.6,1,0.7);
	SUI_ExperienceBarFillGlow:SetVertexColor(0,0.6,1,0.5);
	SUI_ExperienceBarLead:SetVertexColor(0,0.6,1,0.7);	
	SUI_ExperienceBarLeadGlow:SetVertexColor(0,0.6,1,0.5);
	local exptip1 = string.gsub(EXHAUST_TOOLTIP1,"\n"," "); -- %s %d%% of normal experience gained from monsters. (replaced single breaks with space)
	local exptip2 = string.gsub(EXHAUST_TOOLTIP3,"\n\n",""); -- In this condition, you can get\n%d more monster experience\nbefore the next rest state. (removed double break)
		exptip2 = string.gsub(exptip2,"\n"," "); -- In this condition, you can get %d more monster experience before the next rest state. (replaced single breaks with space)
	local exphead = ITEM_LEVEL.." (%d / %d) %d%% "..COMBAT_XP_GAIN; -- Level %d (%d / %d) %d%% Experience
	local exprest = TUTORIAL_TITLE26.." (%d%%) -"; -- Rested (%d%%) -

	SUI_ExperienceBar:SetScript("OnEvent",function()
		local level,rested,now,goal = UnitLevel("player"),GetXPExhaustion() or 0,UnitXP("player"),UnitXPMax("player");
		if now == 0 then now = 0.1; end
		local ratio = now/goal
		SUI_ExperienceBarFill:SetWidth(ratio*400)
	end);
	SUI_ExperienceBar:SetScript("OnEnter",function()
		SUI_StatusTooltip:ClearAllPoints()
		SUI_StatusTooltip:SetPoint("BOTTOM",SUI_ExperienceBar,"BOTTOM",7,-2);
		SUI_StatusTooltipHeader:SetText(format(exphead,UnitLevel("player"),UnitXP("player"),UnitXPMax("player"),(UnitXP("player")/UnitXPMax("player")*100))); -- Level 78 (165546 / 16554565) 1% Experience
		local rested,text = GetXPExhaustion() or 0;
		if (rested > 0) then
			text = format(exptip1,format(exprest,(rested/UnitXPMax("player"))*100),200); -- Rested (15%) - 200% of normal experience gained from monsters.
			SUI_StatusTooltipText:SetText(format("%s "..exptip2,text,rested)); -- Rested (15%) - 200% of normal experience gained from monsters. In this condition, you can get 4587 more monster experience before the next rest state.
		else
			SUI_StatusTooltipText:SetText(format(exptip1,EXHAUST_TOOLTIP2,100)); -- You should rest at an Inn. 100% of normal experience gained from monsters.
		end
		SUI_StatusTooltip:Show();
	end);
	SUI_ExperienceBar:SetScript("OnLeave",function() SUI_StatusTooltip:Hide(); end);
	SUI_ExperienceBar:Show();
end
---------------------------------------------------------------------------------------------------
do -- reputation bar (now fully localized)
	SUI_ReputationBar:SetPoint("BOTTOMLEFT","SpartanUI","BOTTOM",78,0);
	SUI_ReputationBar:EnableMouse(true);
	for __,event in pairs({"PLAYER_LEVEL_UP","UPDATE_FACTION","CVAR_UPDATE"}) do SUI_ReputationBar:RegisterEvent(event); end
	SUI_ReputationBarFill:SetVertexColor(0,1,0,0.7);
	SUI_ReputationBarFillGlow:SetVertexColor(0,1,0,0.2);
	SUI_ReputationBarLead:SetVertexColor(0,1,0,0.7);
	SUI_ReputationBarLeadGlow:SetVertexColor(0,1,0,0.2);

	local GetFactionDetails = function(name)
		if (not name) then return; end
		local description
		for i = 1,GetNumFactions() do
			if name == GetFactionInfo(i) then
				_,description = GetFactionInfo(i)
				return description
			end
		end
	end
	SUI_ReputationBar:SetScript("OnEvent",function()
		local name,_,low,high,current = GetWatchedFactionInfo()
		local ratio = 0.1
		if name then
			ratio = (current-low)/(high-low)
			if ratio == 0 then ratio = 0.1 end
		end
		SUI_ReputationBarFill:SetWidth(ratio*400)
	end);
	SUI_ReputationBar:SetScript("OnEnter",function()
		SUI_StatusTooltip:ClearAllPoints()
		SUI_StatusTooltip:SetPoint("BOTTOM",SUI_ReputationBar,"BOTTOM",-2,-2);
		local name,react,low,high,current,text,ratio = GetWatchedFactionInfo()
		if name then
			text = GetFactionDetails(name)
			ratio = (current-low)/(high-low)
			SUI_StatusTooltipHeader:SetText(format("%s (%d / %d) %d%% %s",name,current-low,high-low,ratio*100,_G["FACTION_STANDING_LABEL"..react]));
			SUI_StatusTooltipText:SetText("|cffffd200"..text.."|r")
		else
			SUI_StatusTooltipHeader:SetText(REPUTATION);
			SUI_StatusTooltipText:SetText(REPUTATION_STANDING_DESCRIPTION)
		end
		SUI_StatusTooltip:Show();
	end);
	SUI_ReputationBar:SetScript("OnLeave",function() SUI_StatusTooltip:Hide(); end);
	SUI_ReputationBar:Show();
end
