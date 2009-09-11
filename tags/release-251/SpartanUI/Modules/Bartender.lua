if not Bartender4 then return; end
local addon = LibStub:GetLibrary("SpartanUI")
if not addon then return; end
----------------------------------------------------------------------------------------------------
-- STEP1: Create our profile in Bartender4
	--[[ DBObject:RegisterNamespace(name [, defaults])
		* name (string) - The name of the new namespace
		* returns the databsae object
		* defaults (table) - A table of values to use as defaults

		Creates a new database namespace, directly tied to the database. Namespace is synonymous
		the term profile when referring to Bartender4, so this should be how we create our database
		entries, as this will work with the "Reset Profile" option among other things. ]]

-- STEP2: On first load, set our new profile as the current
	--[[ DBObject:SetProfile(name)
		* name (string) - The name of the profile to set as the current profile ]]
	-- use a savedvar that gets reset on new versions. This should be saved inside suiData so that
	-- version checks include it. Set it to true after we have forced the spartan profile, and after
	-- that the user has the option to use their own profile if they so choose (until a new version)

-- STEP3: If we are using our new profile, make the necessary tweaks, otherwise stop
	--[[ DBObject:GetCurrentProfile()
		* Returns the current profile name used by the database ]]
	-- need some type of OnUpdate or something similar to make sure this happens all the time.
	-- I noticed that Bartender4 actually fires some custom events for certain thigns such as
	-- profile changes. Might be possible to listen for those events and run our tweaks each time
	-- but only if using the spartan profile
