if (Prat or ChatMOD_Loaded or ChatSync or Chatter or PhanxChatDB) then return; end
local addon = LibStub("AceAddon-3.0"):GetAddon("SpartanUI");
local module = addon:NewModule("ChatFrame");
---------------------------------------------------------------------------
function module:OnEnable()
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
	
			local button = _G["ChatFrame"..i.."UpButton"];
			button:ClearAllPoints(); button:SetScale(0.8);
			button:SetPoint("BOTTOMRIGHT",DEFAULT_CHAT_FRAME,"RIGHT",4,0);
			
			button = _G["ChatFrame"..i.."DownButton"];
			button:ClearAllPoints(); button:SetScale(0.8);
			button:SetPoint("TOPRIGHT",DEFAULT_CHAT_FRAME,"RIGHT",4,0);
	
			button = _G["ChatFrame"..i.."BottomButton"];
			button:ClearAllPoints(); button:SetScale(0.8);
			button:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 4, -10);
		end
		
		ChatFrameMenuButton:SetParent(DEFAULT_CHAT_FRAME);
		ChatFrameMenuButton:ClearAllPoints();
		ChatFrameMenuButton:SetScale(0.8);
		ChatFrameMenuButton:SetPoint("TOPLEFT",DEFAULT_CHAT_FRAME,"TOPRIGHT",-29,4);
		
		DEFAULT_CHAT_FRAME:HookScript("OnUpdate",function()
			if MouseIsOver(DEFAULT_CHAT_FRAME) then
				ChatFrame1UpButton:Show();
				ChatFrame1DownButton:Show();
				ChatFrameMenuButton:Show();
			else
				ChatFrame1UpButton:Hide();
				ChatFrame1DownButton:Hide();
				ChatFrameMenuButton:Hide();
			end
			if ChatFrame1:AtBottom() then
				ChatFrame1BottomButton:Hide();
			else
				ChatFrame1BottomButton:Show();
			end
		end);
		FCF_SetButtonSide = noop;		

		ChatFrameEditBox:ClearAllPoints();
		ChatFrameEditBox:SetPoint("BOTTOMLEFT",  ChatFrame1, "TOPLEFT", 0, 2);
		ChatFrameEditBox:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 0, 2);
	end
end
