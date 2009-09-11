local addon = LibStub:GetLibrary("SpartanUI_PlayerFrames");
if (not addon) then return; end
---------------------------------------------------------------------------
local spartan = LibStub:GetLibrary("SpartanUI");
local default = {player = 1,target = 1,targettarget = 0,pet = 1};

suiChar.PlayerFrames = suiChar.PlayerFrames or {};
setmetatable(suiChar.PlayerFrames,{__index = default});
for k,v in pairs(default) do
	addon[k]:PostUpdateAura(nil,k);
end
---------------------------------------------------------------------------
spartan.options.args["auras"] = {
	name = "Unitframe Auras",
	desc = "unitframe aura settings",
	type = "group", args = {
		player = {name = "toggle player auras", type = "toggle", 
			get = function(info) return suiChar.PlayerFrames.player; end,
			set = function(info,val)
				if suiChar.PlayerFrames.player == 0 then
					suiChar.PlayerFrames.player = 1;
					spartan:print("Player Auras Enabled",true);
				else
					suiChar.PlayerFrames.player = 0;
					spartan:print("Player Auras Disabled",true);
				end
				addon.player:PostUpdateAura(nil,"player");
			end
		},
		target = {name = "toggle target auras", type = "toggle", 
			get = function(info) return suiChar.PlayerFrames.target; end,
			set = function(info,val)
				if suiChar.PlayerFrames.target == 0 then
					suiChar.PlayerFrames.target = 1;
					spartan:print("Target Auras Enabled",true);					
				else
					suiChar.PlayerFrames.target = 0;
					spartan:print("Target Auras Disabled",true);					
				end
				addon.target:PostUpdateAura(nil,"target");
			end
		},
		targettarget = {name = "toggle target of target auras", type = "toggle", 
			get = function(info) return suiChar.PlayerFrames.targettarget; end,
			set = function(info,val)
				if suiChar.PlayerFrames.targettarget == 0 then
					suiChar.PlayerFrames.targettarget = 1;
					spartan:print("Target of Target Auras Enabled",true);					
				else
					suiChar.PlayerFrames.targettarget = 0;
					spartan:print("Target of Target Auras Disabled",true);					
				end
				addon.targettarget:PostUpdateAura(nil,"targettarget");
			end
		},
		pet = {name = "toggle pet auras", type = "toggle", 
			get = function(info) return suiChar.PlayerFrames.pet; end,
			set = function(info,val)
				if suiChar.PlayerFrames.pet == 0 then
					suiChar.PlayerFrames.pet = 1;
					spartan:print("Pet Auras Enabled",true);					
				else
					suiChar.PlayerFrames.pet = 0;
					spartan:print("Pet Auras Disabled",true);					
				end
				addon.pet:PostUpdateAura(nil,"pet");
			end
		}
	}
};
