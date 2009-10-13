local spartan = LibStub("AceAddon-3.0"):GetAddon("SpartanUI");
local addon = spartan:GetModule("PlayerFrames");
----------------------------------------------------------------------------------------------------
oUF:SetActiveStyle("Spartan_PlayerFrames");

addon.pet = oUF:Spawn("pet","SUI_PetFrame");
addon.pet:SetPoint("BOTTOMRIGHT",SpartanUI,"TOP",-370,12);
