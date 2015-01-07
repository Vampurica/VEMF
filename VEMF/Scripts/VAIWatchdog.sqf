/*
	VEMF Caching Watchdog by Vampire
	
	Description:
		This script checks VEMFAI to see if they need cached or unCached.
*/

diag_log text format ["[VEMF]: AI Watchdog Running."];

[] spawn {
	private ["_cache","_cGrp","_pos"];
	
	if (isNil "_cache") then { _cache = []; };
	if (isNil "VEMFForceCache") then { VEMFForceCache = []; };
	
	// Force Caching Chunk
	if (count VEMFForceCache > 0) then {
		while {count VEMFForceCache > 0} do {
			_cGrp = VEMFForceCache select 0;
			
			// We have Units to Force Cache
			_cache = _cache + [(getPos leader _cGrp),(count units _cGrp),((leader _cGrp) getVariable ["VEMFUArray", "VEMFNoUArr"])];
			{
				deleteVehicle _x;
			} forEach (units _cGrp);
			
			VEMFForceCache = VEMFForceCache - [_cGrp];
			deleteGroup _cGrp;
			_cGrp = grpNull;
		};
	};
	
	// No Nearby Players Caching Chunk
	{
		if (_x getVariable ["VEMFAI", false]) then {
			if !(count ((getposATL leader group _x) nearEntities [["Epoch_Male_F", "Epoch_Female_F"], 1000]) > 0) then {
				// We need to Cache the Group
				_cGrp = (group _x);
			
				_cache = _cache + [(getPos leader _cGrp),(count units _cGrp),((leader _cGrp) getVariable ["VEMFUArray", "VEMFNoUArr"])];
				{
					deleteVehicle _x;
				} forEach (units _cGrp);
				
				deleteGroup _cGrp;
				_cGrp = grpNull;
			};
		};
	} forEach allUnits;
	
	// UnCaching Chunk
	{
		_pos = (_x select 0);
		if (count(_pos nearEntities [["Epoch_Male_F", "Epoch_Female_F"], 600]) > 0) then {
			// UnCache Group
			call compile format ["
				if (isNil '%1') then { %1 = []; };
				if (count %1 < 1) then {
					[_pos,true,1,'VEMFNoUArr',(_x select 1)] ExecVM VEMFSpawnAI;
				} else {
					[_pos,true,1,'%1',(_x select 1)] ExecVM VEMFSpawnAI;
				};
			", (_x select 2)];
			
			_cache = _cache - [_x];
		};
	} forEach _cache;
	
	// Sleep 10 Minutes
	uiSleep 600;
};