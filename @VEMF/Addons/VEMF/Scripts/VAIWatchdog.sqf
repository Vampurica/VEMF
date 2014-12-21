/*
	VEMF Caching Watchdog by Vampire
	
	Description:
		Epoch cleans up units that are local to the server.
		What this means is we need to make sure the units never become local to the server.
		This watches the AI and transfers ownership if needed, or Caches them if no one is near.
*/

[] spawn {
	private ["_grps","_cache","_nearP"];
	
	// Some Error Checks
	if (isNil "VEMFWatchAI") then { VEMFWatchAI = []; };
	if (isNil "_grps") then { _grps = []; };
	if (isNul "_cache") then { _cache = []; };
	
	// Check for New Units to Watch
	if (count VEMFWatchAI > 0) then {
		_grps = _grps + VEMFWatchAI;
		VEMFWatchAI = [];
	};
	
	// Check for Group Locality Change
	{
		if (local ((units group _x) select 0)) then {
			// Need to Cache Group or SetOwner
			_nearP = ((getPosATL _x) nearEntities [["Epoch_Male_F", "Epoch_Female_F"], 500]) select 0;
			
			if (isNil "_nearP") then {
				// Cache Group
				_cache = _cache + [(getPos leader group _x),(count units group _x)];
				for "_i" from 1 to (count units group _x) do {
					deleteVehicle ((units group _x) select 0);
				};
				deleteGroup _x;
			} else {
				// Set New Owner
				for "_i" from 1 to (count units group _x) do {
					((units group _x) select (_i-1)) setOwner (owner _nearP);
				};
			};
		};
	} forEach _grps;

	// Check if Units need Un-Cached
	{
		if (((_x select 0) nearEntities [["Epoch_Male_F", "Epoch_Female_F"], 800]) > 0) then {
			[(_x select 0),true,1,(_x select 1)] ExecVM VEMFSpawnAI;
		};
	} forEach _cache;
	
	uiSleep 10;
};