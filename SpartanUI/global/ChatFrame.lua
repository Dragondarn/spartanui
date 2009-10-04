local addon = LibStub("AceAddon-3.0"):GetAddon("SpartanUI");
local module = addon:NewModule("ChatFrame");
---------------------------------------------------------------------------
function module:OnEnable()
	if (Prat or ChatMOD_Loaded or ChatSync or Chatter or PhanxChatDB) then
		-- do nothing since an addon is doing it all; This is here for future expansion...
	else
		local NUM_SCROLL_LINES = 3;
		local noop = function() return; end;
		local hide = function(this) this:Hide(); end;
		local scroll = function(this, arg1)
			if arg1 > 0 then
				if IsShiftKeyDown() then
					this:ScrollToTop()
				elseif IsControlKeyDown() then
					this:PageUp()
				else
					for i = 1, NUM_SCROLL_LINES do
						this:ScrollUp()
					end
				end
			elseif arg1 < 0 then
				if IsShiftKeyDown() then
					this:ScrollToBottom()
				elseif IsControlKeyDown() then
					this:PageDown()
				else
					for i = 1, NUM_SCROLL_LINES do
						this:ScrollDown()
					end
				end
			end
		end;
		do -- modify chat frames
			for i = 1,7 do
				local frame = _G["ChatFrame"..i];				
				frame:SetMinResize(64,40); frame:SetFading(0);
				frame:EnableMouseWheel(true);
				frame:SetScript("OnMouseWheel",scroll);
			
				frame:SetFrameStrata("MEDIUM");
				frame:SetToplevel(false);
				frame:SetFrameLevel(2);
		
				local button = _G["ChatFrame"..i.."UpButton"]
				button:SetScript("OnShow", hide)
				button:Hide();
		
				button = _G["ChatFrame"..i.."DownButton"];
				button:SetScript("OnShow", hide);
				button:Hide();
				button = _G["ChatFrame"..i.."BottomButton"];
				button:ClearAllPoints();
				button:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", -32, -4);
				button:Hide();
			end
			
			ChatFrameMenuButton:SetParent(DEFAULT_CHAT_FRAME);
			ChatFrameMenuButton:ClearAllPoints(); ChatFrameMenuButton:SetScale(0.6);
			ChatFrameMenuButton:SetPoint("TOPLEFT",DEFAULT_CHAT_FRAME,"TOPRIGHT",-29,4);
			
			hooksecurefunc("ChatFrame_OnUpdate",function(frame,elapsed)
				local button = _G[frame:GetName().."BottomButton"];
				if button and frame:AtBottom() then
					button:Hide();
				elseif button then
				button:Show();
				end
			end);			
			FCF_SetButtonSide = noop;		
		
			ChatFrameEditBox:ClearAllPoints();
			ChatFrameEditBox:SetPoint("BOTTOMLEFT",  ChatFrame1, "TOPLEFT", 0, 2);
			ChatFrameEditBox:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 0, 2);
		end
	end
end