/*
	VEMF System Functions
	by Vampire
*/

diag_log text "[VEMF]: Loading ExecVM Functions.";

// Nothing Yet

diag_log text "[VEMF]: Loading Compiled Functions.";

VEMFMapCenter = {
	private ["_mapName","_centerPos","_mapRadii","_fin"];
	
	// Get the map name again to prevent interfering
	_mapName = toLower format ["%1", worldName];
	
	/*
		- Still based on code by Halv
	
			If the map does not have a _mapRadii,
		it has a guessed center that may not be accurate.
		You can contact me if you have issues with a
		"less supported" map, so I can fully support it.
	*/
	switch (_mapName) do {
		/* Arma 3 Maps */
		case "altis":{_centerPos = [15440, 15342, 0];_mapRadii = 17000;);
		case "stratis":{_centerPos = [4042, 4093, 0];_mapRadii = 4100;);

		/* Arma 2 Maps (May Need Updating) */
		case "chernarus":{_centerPos = [7100, 7750, 0];_mapRadii = 5500;};
		case "utes":{_centerPos = [3500, 3500, 0];_mapRadii = 3500;};
		case "zargabad":{_centerPos = [4096, 4096, 0];_mapRadii = 4096;};
		case "fallujah":{_centerPos = [3500, 3500, 0];_mapRadii = 3500;};
		case "takistan":{_centerPos = [5500, 6500, 0];_mapRadii = 5000;};
		case "tavi":{_centerPos = [10370, 11510, 0];_mapRadii = 14090;};
		case "lingor":{_centerPos = [4400, 4400, 0];_mapRadii = 4400;};
		case "namalsk":{_centerPos = [4352, 7348, 0]};
		case "napf":{_centerPos = [10240, 10240, 0];_mapRadii = 10240;};
		case "mbg_celle2":{_centerPos = [8765.27, 2075.58, 0]};
		case "oring":{_centerPos = [1577, 3429, 0]};
		case "panthera2":{_centerPos = [4400, 4400, 0];_mapRadii = 4400;};
		case "isladuala":{_centerPos = [4400, 4400, 0];_mapRadii = 4400;};
		case "smd_sahrani_a2":{_centerPos = [13200, 8850, 0]};
		case "sauerland":{_centerPos = [12800, 12800, 0];_mapRadii = 12800;};
		case "trinity":{_centerPos = [6400, 6400, 0];_mapRadii = 6400;};
		default {_centerPos = [0,0,0];_mapRadii = 5500;};
	};
	
	if ((_centerPos select 0) == 0) then {
		diag_log text format ["[VEMF]: POSFinder: %1 is not a Known Map. Please Inform Vampire.", _mapName];
	};
	
	// Return our results, or the default
	_fin = [_centerPos,_mapRadii];
	_fin
};

VEMFFindTown = {
	private ["_cntr","_townArr","_sRandomTown","_townPos"];
	
	// Map Incorrect Center (but center-ish)
	// Might be biased towards the center because of this (Needs Testing)
	_cntr = getArray(configFile >> "CfgWorlds" >> worldName >> "centerPosition")

	// Get a list of towns
	// Shouldn't cause lag because of the infrequency it runs (Needs Testing)
	_townArr = nearestLocations [_cntr, ["NameVillage","NameCity","NameCityCapital"], 30000];
	
	// Pick a random one, get the POS, return the POS (Coords)
	_sRandomTown = _townArr call BIS_fnc_selectRandom;
	_townPos = [((getposATL _sRandomTown) select 0), ((getposATL _sRandomTown) select 1), 0];
	
	_townPos
};

VEMFRandomPos = {
	private ["_centerLoc","_findRun","_testPos","_hardX","_hardY","_posX","_posY","_feel1","_feel2","_feel3","_feel4","_noWater","_okDis","_isBlack","_plyrNear","_fin"];
	
	// The DayZ "Novy Sobor" bug still exists in Arma 3.
	// This means we still need to input our map specific centers.
	_centerLoc = call VEMFMapCenter;
	
	// Now we run a loop to check the position against our requirements
	_findRun = true;
	while {_findRun} do
	{
		// Get our Candidate Position
		_testPos = [(_centerLoc select 0),0,(_centerLoc select 1),60,0,20,0] call BIS_fnc_findSafePos;

		// Get values to compare
		_hardX = ((_centerLoc select 0) select 0);
        _hardY = ((_centerLoc select 0) select 1);
        _posX = _testPos select 0;
        _posY = _testPos select 1;

        // Water Feelers. Checks for nearby water within 50meters.
        _feel1 = [_posX, _posY+50, 0]; // North
        _feel2 = [_posX+50, _posY, 0]; // East
        _feel3 = [_posX, _posY-50, 0]; // South
        _feel4 = [_posX-50, _posY, 0]; // West
		
		// Water Check
		_noWater = (!surfaceIsWater _testPos && !surfaceIsWater _feel1 && !surfaceIsWater _feel2 && !surfaceIsWater _feel3 && !surfaceIsWater _feel4);
	
		// Check for Mission Separation Distance
		{
			_okDis = true;
			if ((_testPos distance _x) < 1500) exitWith
			{
				// Another Mission is too close
				_okDis = false;
			};
		} forEach VEMFMissionLocs;
		
		// Blacklist Check
        {
			_isBlack = false;
            if ((_testPos distance (_x select 0)) <= (_x select 1)) exitWith
			{
				// Position is too close to a Blacklisted Location
				_isBlack = true;
			};
        } forEach VEMFBlacklistZones;
		
		_plyrNear = {isPlayer _x} count (_testPos nearEntities ["CAManBase", 500]) > 0;
		
		// Let's Compare all our Requirements
		if ((_posX != _hardX) AND (_posY != _hardY) AND _noWater AND _okDis AND !_isBlack AND !_plyrNear) then {
			_findRun = false;
        };
		
		//diag_log text format ["[VEMF]: MISSDEBUG: Pos:[%1,%2] / noWater?:%3 / okDistance?:%4 / isBlackListed:%5 / isPlayerNear:%6", _posX, _posY, _noWater, _okDis, _isBlack, _plyrNear];
        
		sleep 2;
	};
	
	_fin = [(_testPos select 0), (_testPos select 1), 0];
    _fin
};

VEMFSetupVic = {
	private ["_object","_ranFuel"];
	_vehicle = _this select 0;
	_vClass = (typeOf _vehicle);
	
	// Wait till we have a valid object
	waitUntil {(!isNull _vehicle)};
	
	// Set Vehicle Token
	_vehicle call EPOCH_server_setVToken;
	
	// Add to A3 Cleanup
	addToRemainsCollector [_vehicle];
	
	// Disable Thermal/NV for Vehicle
	_vehicle disableTIEquipment true;
	
	// Empty Vehicle
	clearWeaponCargoGlobal _vehicle;
	clearMagazineCargoGlobal _vehicle;
	clearBackpackCargoGlobal  _vehicle;
	clearItemCargoGlobal _vehicle;
	
	// Set the Vehicle Lock Time (0 Seconds)
	// Vehicle Will spawn Unlocked
	_vehicle lock true;
	_vehicle setVariable["LOCK_OWNER", "-1"];
	_vehicle setVariable["LOCKED_TILL", serverTime];
	
	// Pick a Random Color if Available
	_config = configFile >> "CfgVehicles" >> _vClass >> "availableColors";
	if (isArray(_config)) then {
		_textureSelectionIndex = configFile >> "CfgVehicles" >> _vClass >> "textureSelectionIndex";
		_selections = if (isArray(_textureSelectionIndex)) then {
			getArray(_textureSelectionIndex)
		} else {
			[0]
		};
		
		_colors = getArray(_config);
		_textures = _colors select 0;
		_color = floor(random(count _textures));
		_count = (count _colors)-1;
		{
			if (_count >=_forEachIndex) then {
				_textures = _colors select _forEachIndex;
			};
			_vehicle setObjectTextureGlobal [_x,(_textures select _color)];
		} forEach _selections;
		
		_vehicle setVariable["VEHICLE_TEXTURE", _color];
	};
	
	// Set Vehicle Init
	_vehicle call EPOCH_server_vehicleInit;
	
	// Set a Random Fuel Amount
	_ranFuel = random 1;
	if (_ranFuel < 0.1) then {_ranFuel = 0.1;};
	_vehicle setFuel _ranFuel;
	_vehicle setVelocity [0,0,1];
	_vehicle setDir (round(random 360));
	
	//If saving vehicles to the database is disabled, lets warn players it will disappear
	if (!(DZMSSaveVehicles)) then {
		_object addEventHandler ["GetIn",{
			_nil = [nil,(_this select 2),"loc",rTITLETEXT,"Warning: This vehicle will disappear on server restart!","PLAIN DOWN",5] call RE;
		}];
	};

	true
};























