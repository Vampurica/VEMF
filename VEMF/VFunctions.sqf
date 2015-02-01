/*
	VEMF System Functions
	by Vampire
*/

diag_log text "[VEMF]: Loading ExecVM Functions.";

VEMFSpawnAI       = "\VEMF\Scripts\VSpawnAI.sqf";
VEMFSpawnSingleAI = "\VEMF\Scripts\VSpawnSingleAI.sqf";
VEMFAIKilled      = "\VEMF\Scripts\VAIKilled.sqf";
VEMFLocalHandler  = "\VEMF\Scripts\VLocalEventhandler.sqf";
VEMFGenRanWeps    = "\VEMF\Scripts\VGenWeapons.sqf";
VEMFLoadAddons    = "\VEMF\Scripts\VAddonLoader.sqf";
VEMFMissWatchdog  = "\VEMF\Scripts\VAIWatchdog.sqf";
VEMFMissTimer     = "\VEMF\Scripts\VMissionTimer.sqf";

diag_log text "[VEMF]: Loading Compiled Functions.";

// Gets the Map's Hardcoded CenterPOS and Radius
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
		case "altis":{_centerPos = [15440, 15342, 0];_mapRadii = 17000;};
		case "stratis":{_centerPos = [4042, 4093, 0];_mapRadii = 4100;};
		case "bornholm":{_centerPos = [11240, 11292, 0];_mapRadii = 14400;};

		/* Arma 2 Maps (May Need Updating) */
		case "chernarus":{_centerPos = [7100, 7750, 0];_mapRadii = 5500;};
		case "chernarus_summer":{_centerPos = [7100, 7750, 0];_mapRadii = 5500;};
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
		default {_centerPos = (epoch_centerMarkerPosition);_mapRadii = 5500;};
	};
	
	if (VEMFDebugLocs) then {
		diag_log text format ["[VEMF]: MISSDEBUG: Map:%1 / CenterPos:%2 / Radius:%3", _mapName, str(_centerPos), _mapRadii];
	};
	
	if ((_centerPos select 0) == 0) then {
		diag_log text format ["[VEMF]: POSFinder: %1 is not a Known Map. Please Inform Vampire.", _mapName];
	};
	
	// Return our results, or the default
	_fin = [_centerPos,_mapRadii];
	_fin
};

// Finds a Random Map Location for a Mission
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
		
		_plyrNear = {isPlayer _x} count (_testPos nearEntities [["Epoch_Male_F", "Epoch_Female_F"], 500]) > 0;
		
		// Let's Compare all our Requirements
		if ((_posX != _hardX) AND (_posY != _hardY) AND _noWater AND _okDis AND !_isBlack AND !_plyrNear) then {
			_findRun = false;
        };
		
		if (VEMFDebugLocs) then {
			diag_log text format ["[VEMF]: MISSDEBUG: Pos:[%1,%2] / noWater?:%3 / okDistance?:%4 / isBlackListed:%5 / isPlayerNear:%6", _posX, _posY, _noWater, _okDis, _isBlack, _plyrNear];
		};
        
		uiSleep 2;
	};
	
	_fin = [(_testPos select 0), (_testPos select 1), 0];
    _fin
};

// Finds a Random Town on the Map
VEMFFindTown = {
	private ["_cntr","_townArr","_sRandomTown","_townPos","_townName","_nearP","_ret"];
	
	_cntr = (epoch_centerMarkerPosition);

	// Get a list of towns
	_townArr = nearestLocations [_cntr, VEMFLocationTypes, 30000];
	
	while {true} do {
		// Pick a random town
		_sRandomTown = _townArr call BIS_fnc_selectRandom;
		
		// Return Name and POS
		_townPos = [((locationPosition _sRandomTown) select 0), ((locationPosition _sRandomTown) select 1), 0];
		_townName = (text _sRandomTown);
		
		// Check Town or Loop
		_nearP = {isPlayer _x} count (_townPos nearEntities [["Epoch_Male_F", "Epoch_Female_F"], 800]) > 0;
		{
			_isBlack = false;
            if ((_townPos distance (_x select 0)) <= (_x select 1)) exitWith
			{
				// Position is too close to a Blacklisted Location
				_isBlack = true;
			};
        } forEach VEMFBlacklistZones;
		if (!_nearP && !_isBlack) exitWith {};
		
		uiSleep 30;
	};

	_ret = [_townName, _townPos];
	_ret
};

// Finds House Positions for Units
VEMFHousePositions = {
	private ["_pos","_cnt","_houseArr","_fin","_loop","_bNum","_tmpArr","_bPos"];
	
	// CenterPOS and House Count
	_pos = _this select 0;
	_cnt = _this select 1;
	
	// Get Nearby Houses in Array
	_houseArr = nearestObjects [_pos, ["house"], 200];
	
	{
		if (str(getPos _x) == "[0,0,0]") then {
			// Not a Valid House
			_houseArr = _houseArr - [_x];
		};
		if (str(_x buildingPos 0) == "[0,0,0]") then {
			_houseArr = _houseArr - [_x];
		};
		if ((typeOf _x) in ["Land_Panelak","Land_Panelak2"]) then {
			_houseArr = _houseArr - [_x];
		};
	} forEach _houseArr;
	
	// Randomize Valid Houses
	if (count _houseArr > 20) then { _houseArr resize 20; };
	_houseArr = _houseArr call BIS_fnc_arrayShuffle;
	
	// Only return the amount of houses we wanted
	_houseArr resize _cnt;
	
	_fin = [];
	
	{
		// Keep locations separated by house for unit groups
		_loop = true;
		_bNum = 0;
		_tmpArr = [];
		while {_loop} do {
			_bPos = _x buildingPos _bNum;
			if (str _bPos == "[0,0,0]") then {
				// All Positions Found
				_loop = false;
			} else {
				_tmpArr = _tmpArr + [_bPos];
				_bNum = _bNum + 1;
			};
		};
		
		_fin = _fin + [_tmpArr];
	} forEach _houseArr;
	
	if (VEMFDebugFunc) then {
		diag_log text format ["[VEMF]: HousePos: %1", str(_fin)];
	};
	
	// Returns in the following format
	// Nested Array = [[HousePos1,Pos2,Pos3],[Pos1,Pos2],[Pos1,Pos2]];
	_fin
};

// Vehicle Setup
VEMFSetupVic = {
	private ["_vehicle","_temp","_ranFuel","_config","_textureSelectionIndex","_selections","_colors","_textures","_color","_count"];
	
	_vehicle = _this select 0;
	_temp    = _this select 1;
	
	waitUntil {(!isNull _vehicle)};
	
	// Set Variables
	_vehicle setVariable ["LASTLOGOUT_EPOCH", (diag_tickTime + 604800)];
	_vehicle setVariable ["LAST_CHECK", (diag_tickTime + 604800)];
	
	// Add to A3 Cleanup
	addToRemainsCollector [_vehicle];
	
	// Disable Thermal/NV for Vehicle
	_vehicle disableTIEquipment true;
	
	// Empty Vehicle
	clearWeaponCargoGlobal _vehicle;
	clearMagazineCargoGlobal _vehicle;
	clearBackpackCargoGlobal  _vehicle;
	clearItemCargoGlobal _vehicle;
	
	// Set Vehicle Slot
	EPOCH_VehicleSlotsLimit = EPOCH_VehicleSlotsLimit + 1;
	EPOCH_VehicleSlots pushBack (str EPOCH_VehicleSlotsLimit);
	_vehicle setVariable ["VEHICLE_SLOT",(EPOCH_VehicleSlots select 0),true];
	EPOCH_VehicleSlots = EPOCH_VehicleSlots - [(EPOCH_VehicleSlots select 0)];
	EPOCH_VehicleSlotCount = count EPOCH_VehicleSlots;
	
	// Set vToken
	_vehicle call EPOCH_server_setVToken;
	
	// Pick a Random Color if Available
	_config = configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "availableColors";
	if (isArray(_config)) then {
		_textureSelectionIndex = configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "textureSelectionIndex";
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
		
		_vehicle setVariable ["VEHICLE_TEXTURE", _color];
	};
	
	// Set Vehicle Init
	if (_temp) then {
		_vehicle addEventHandler ["GetIn",{
			VEMFWarnMessage = "Vehicle Will Disappear on Restart!";
			(owner (_this select 2)) publicVariableClient "VEMFWarnMessage";
		}];
	} else {
		_vehicle call EPOCH_server_vehicleInit;
	};

	true
};

// Fills a Vehicle with AI
VEMFFillVeh = {
	private ["_vehicle","_addCargo","_safePos","_driver","_gunner","_cargo","_grp"];
	
	_vehicle = _this select 0;
	_addCargo = _this select 1;
	_safePos = (getpos _vehicle) findEmptyPosition [0,30,"I_Soldier_EPOCH"];
	
	// Add Driver
	_driver = [_safePos] call VEMFSpawnSingleAI;
	_driver moveInDriver _vehicle;
	
	// Add Gunner(s)
	for "_i" from 1 to (_vehicle emptyPositions "Gunner") do {
		_gunner = [_safePos] call VEMFSpawnSingleAI;
		_gunner moveInGunner _vehicle;
	};
	
	// Add Cargo Crew
	if (_addCargo) then {
		for "_i" from 1 to (_vehicle emptyPositions "Cargo") do {
			_cargo = [_safePos] call VEMFSpawnSingleAI;
			_cargo moveInCargo _vehicle;
		};
	};
	
	// Group Units in Vehicle
	_grp = createGroup RESISTANCE;
	_grp setBehaviour "SAFE";
	_grp setCombatMode "YELLOW";
	
	{
		[_x] joinSilent _grp;
	} forEach (crew _vehicle);
	
	// Make Driver Leader
	_driver setSkill 1;
	_grp selectLeader _driver;
	
	// Return Group
	_grp
};

// Random Fuel
VEMFRanFuel = {
	private ["_vehicle"];
	
	_vehicle = _this select 0;
	
	if (local _vehicle) then {
		_ranFuel = random 1;
		if (_ranFuel < 0.1) then {_ranFuel = 0.1;};
		_vehicle setFuel _ranFuel;
		_vehicle setVelocity [0,0,1];
		_vehicle setDir (round(random 360));
		
		true
	} else {
		false
	};
};

// Levels an Object to the Terrain (Mostly)
// Code from KK
VEMFLevel = {
	private ["_vic"];

	_vic = _this select 0;
	
	if (local _vic) then {
		_sn = surfaceNormal visiblePositionASL _vic;
		_k = abs (_sn vectorDotProduct vectorDirVisual _vic);
		_vic setVectorUp (
			(_sn vectorMultiply _k) vectorAdd (
				[0,0,1] vectorMultiply (
					sqrt (1 - (_sn vectorDotProduct [0,0,1]) ^ 2) - _k
				)
			)
		);
	};
};

// Loads a New AI Full of Gear
VEMFLoadAIGear = {
	private ["_suppressor","_muzzle","_unit","_fin","_prim","_seco","_pAmmo","_hAmmo","_attachment"];
	
	_unit = _this select 0;
	_fin = false;
	
	if (!isNull _unit) then {
		// Strip Unit
		removeAllWeapons _unit;
		{_unit removeMagazine _x;} foreach (magazines _unit);
		removeAllItems _unit;
		removeUniform _unit;
		removeVest _unit;
		removeBackpack _unit;
		removeGoggles _unit;
		removeHeadGear _unit;
		
		// Add Uniform
		_unit forceAddUniform (VEMFUniformList call BIS_fnc_selectRandom);
		
		// Add Headgear
		_unit addHeadGear (VEMFHeadgearList call BIS_fnc_selectRandom);
		// All hats - race helmets
		//_unit addHeadgear Format ["H_%1_EPOCH", floor(random 91) + 1];
		
		// Add NVG so AI can at night
		if (sunOrMoon != 1) then {
			_unit linkItem "NVG_Epoch";
		};
		
		// Add Vest (Random 40 Vests)
		/* _vVar = (floor(random 41));
		if (_vVar == 0) then { _vVar = 1; };
		_unit addVest ("V_" + str(_vVar) + "_EPOCH"); */
		_unit addVest (VEMFVestList call BIS_fnc_selectRandom);
		
		// Add Backpack (Future?)
		
		// Add Food/Drink
		// 33% Chance
		if ((floor(random(2))) == 1) then {
			_unit addMagazine (((getArray (configFile >> "CfgLootTable" >> "Food" >> "items")) call BIS_fnc_selectRandom) select 0);
		};
		
		// Add Weapons & Ammo
		_prim = VEMFRiflesList call BIS_fnc_selectRandom;
		_seco = VEMFPistolsList call BIS_fnc_selectRandom;
		
		// Add's weapon and Mags, between 2/6 Mags
		_muzzle = [_unit, _prim, (floor(random 5) + 2)] call BIS_fnc_addWeapon;
		_unit selectWeapon _prim;
		_muzzle = [_unit, _seco, (floor(random 2) + 2)] call BIS_fnc_addWeapon;
		
		// give them unlimited ammo / not fully testede
		_unit addeventhandler ["fired", {(_this select 0) setvehicleammo 1;}];
		
		// Add Grenades for GL Units
		if ((count(getArray (configFile >> "cfgWeapons" >> _prim >> "muzzles"))) > 1) then {
			_unit addMagazine "1Rnd_HE_Grenade_shell";
		};
		
		// 20% Chance Hand Grenade
		// Random Returns 0,1,2,3,4
		if ((floor(random(5))) == 2) then {
			_unit addMagazine "HandGrenade";
		};
		
		// 10% Scope Attachment Chance
		if ((floor(random(10))) == 5) then {
			_attachment = (getArray (configFile >> "cfgLootTable" >> "Scopes" >> "items")) call BIS_fnc_selectRandom;
			_unit addPrimaryWeaponItem (_attachment select 0);
		};
		
		// 20% chance for accessories
		if(floor(random 100) < 20) then {
			_unit addPrimaryWeaponItem (["acc_pointer_IR","acc_flashlight"] call BIS_fnc_selectRandom);
		};
		
		// 10% chance for accessories
		if(floor(random 100) < 10) then {
			_suppressor = _prim call find_suitable_suppressor;
			if(_suppressor != "") then {
				_unit addPrimaryWeaponItem _suppressor;
			};
			
		};
		
		// if AI spawns on water make them ready for it
		if (surfaceIsWater (position _unit)) then {
			removeHeadgear _unit;
			_unit forceAddUniform "U_O_Wetsuit" ;
			_unit addVest "V_20";
			_unit addGoggles "G_Diving";
			_muzzle = [_unit, "arifle_SDAR_F", 3, "20Rnd_556x45_UW_mag"] call BIS_fnc_addWeapon;

		};
		
		if (VEMFDebugFunc) then {
			diag_log text format ["[VEMF]: LoadGear: Uniform: %1 / Vest: %2 / Hat: %3 / Weps: %4 / Mags: %5", (uniform _unit), (vest _unit), (headgear _unit), (weapons _unit), (magazines _unit)];
		};
		
		_fin = true;
	};
	
	_fin
};

VEMFLoadLoot = {
	private ["_crate","_delay","_var","_tmp","_kindOf","_report","_cAmmo"];
	
	_crate = _this select 0;
	_delay = _this select 1;
	
	if (_delay) then {
		// Delay Cleanup
		_crate setVariable ["LAST_CHECK", (diag_tickTime + 1800)];
	};
	
	// Empty Crate
	clearWeaponCargoGlobal _crate;
	clearMagazineCargoGlobal _crate;
	clearBackpackCargoGlobal  _crate;
	clearItemCargoGlobal _crate;
	
	if (VEMFDynCrate) then {
		VEMFLootList = [];
		
		// Generate Loot
		{
			_tmp = (getArray(_x >> 'items'));
			for "_z" from 0 to ((count(_tmp))-1) do {
				VEMFLootList = VEMFLootList + [((_tmp select _z) select 0)];
			};
		} forEach ("configName _x != 'Uniforms' && configName _x != 'Headgear'" configClasses (configFile >> "CfgLootTable"));
		
		if (VEMFDebugFunc) then {
			diag_log text format ["[VEMF]: LoadLootArray: %1", str(VEMFLootList)];
		};
	};
	
	_report = [];
	// Load Random Loot Amount
	for "_i" from 1 to ((floor(random 10)) + 10) do {
		_var = (VEMFLootList call BIS_fnc_selectRandom);
		
		if (!(_var in VEMFCrateBlacklist)) then {
			switch (true) do
			{
				case (isClass (configFile >> "CfgWeapons" >> _var)): {
					_kindOf = [(configFile >> "CfgWeapons" >> _var),true] call BIS_fnc_returnParents;
					if ("ItemCore" in _kindOf) then {
						_crate addItemCargoGlobal [_var,1];
					} else {
						_crate addWeaponCargoGlobal [_var,1];
						
						_cAmmo = [] + getArray (configFile >> "cfgWeapons" >> _var >> "magazines");
						{
							if (isClass(configFile >> "CfgPricing" >> _x)) exitWith {
								_crate addMagazineCargoGlobal [_x,2];
							};
						} forEach _cAmmo;
					};
				};
				case (isClass (configFile >> "cfgMagazines" >> _var)): {
					_crate addMagazineCargoGlobal [_var,1];
				};
				case ((getText(configFile >> "cfgVehicles" >> _var >>  "vehicleClass")) == "Backpacks"): {
					_crate addBackpackCargoGlobal [_var,1];
				};
				default {
					_report = _report + [_var];
				};
			};
		};
	};
	
	if ((count _report) > 0) then {
		diag_log text format ["[VEMF]: LoadLoot: <Unknown> %1", str _report];
	};
	
	if (VEMFDebugFunc) then {
		diag_log text format ["[VEMF]: LoadLoot: Weps: %1 / Mags: %2 / Items: %3 / Bags: %4", (weaponCargo _crate), (magazineCargo _crate), (itemCargo _crate), (backpackCargo _crate)];
	};
};

// Alerts Players With a Random Radio Type
VEMFBroadcast = {
	private ["_msg","_eRads","_sent","_allUnits","_curRad","_send"];
	_msg = _this select 0;
	_eRads = ["EpochRadio0","EpochRadio1","EpochRadio2","EpochRadio3","EpochRadio4","EpochRadio5","EpochRadio6","EpochRadio7","EpochRadio8","EpochRadio9"];
	_eRads = _eRads call BIS_fnc_arrayShuffle;
	
	// Broadcast to Each Player
	_sent = false;
	_allUnits = allUnits;
	
	// Remove Non-Players
	{ if !(isPlayer _x) then {_allUnits = _allUnits - [_x];}; } forEach _allUnits;
	
	_curRad = 0;
	_send = false;
	// Find a Radio to Broadcast To
	while {true} do {
		{
			if ((_eRads select _curRad) in (assignedItems _x)) exitWith {
				_send = true;
			};
			if (_forEachIndex == ((count _allUnits)-1)) then {
				_curRad = _curRad + 1;
			};
		} forEach _allUnits;
		
		if (_send) exitWith {};
		if (_curRad > ((count _eRads)-1)) exitWith
		{
			/* No Radios */
		};
	};
	
	if (_send) then {
		{
			if ((_eRads select _curRad) in (assignedItems _x)) then {
				VEMFChatMsg = _msg;
				(owner (vehicle _x)) publicVariableClient "VEMFChatMsg";
				_sent = true;
			};
		} forEach _allUnits;
	} else {
		_sent = false;
	};
	
	// Return if Message was Received by Someone
	// If FALSE, Nobody has a Radio Equipped
	_sent
};

// Removes Duplicate Array Entries (Doesn't Save Order)
VEMFRemoveDups = {
	private ["_array","_tmpArr"];
	
	_array = _this select 0;
	_tmpArr = _this select 0;
	
	{
		_array = _array - [_x];
		_array = _array + [_x];
	} forEach _tmpArr;
	
	_array
};

// Waits for players to be within the radius of the position
VEMFNearWait = {
	private ["_pos","_rad","_time"];
	
	_pos = _this select 0;
	_rad = _this select 1;
	_time = diag_tickTime;
	
	while {true} do {
		if ((count(_pos nearEntities [["Epoch_Male_F", "Epoch_Female_F"], _rad])) > 0) exitWith {true};
		if (VEMFTimeout && {(diag_tickTime - _time) > (VEMFTimeoutTime * 60)}) exitWith {false};
		uiSleep 5;
	};
};

// Waits for the Mission to be Completed
VEMFWaitMissComp = {
    private ["_objective","_unitArrayName","_numSpawned","_numKillReq","_missDone","_reason"];
	
    _objective = _this select 0;
    _unitArrayName = _this select 1;
	_target = _this select 2;
	_destination = _this select 3;
	
	if (isNil "_target") then {

		call compile format["_numSpawned = count %1;",_unitArrayName];
		_numKillReq = ceil(VEMFRequiredKillPercent * _numSpawned);
		
		diag_log text format["[VEMF]: (%3) Waiting for %1/%2 Units or Less to be Alive and a Player to be Near the Objective.", (_numSpawned - _numKillReq), _numSpawned, _unitArrayName];
		
		_missDone = false;
		call compile format["
			while {true} do {
				if (count %1 <= (_numSpawned - _numKillReq)) then {
					if ((count(_objective nearEntities [['Epoch_Male_F', 'Epoch_Female_F'], 150])) > 0) then {
						_missDone = true;
					};
				};
				if (_missDone) exitWith {};
				uiSleep 5;
			};
		", _unitArrayName];
		
		diag_log text format ["[VEMF]: WaitMissComp: Waiting Over. %1 Completed.", _unitArrayName];
	
	} else {
	
		call compile format["_numSpawned = count %1;",_unitArrayName];
		_numKillReq = ceil(VEMFRequiredKillPercent * _numSpawned);
		
		diag_log text format["[VEMF]: (%3) Waiting for %1/%2 Units or Less to be Alive and a Player to be Near the Targets.", (_numSpawned - _numKillReq), _numSpawned, _unitArrayName];
		
		_missDone = false;
		call compile format["
			while {true} do {
				if (count %1 <= (_numSpawned - _numKillReq)) then {
					if ((count(_objective nearEntities [['Epoch_Male_F', 'Epoch_Female_F'], 150])) > 0) then {
						_missDone = true;
						_reason = "was Killed.";
						true
					};
				};
				if (((getpos _target) distance _destination) <= 150) then {
					_missDone = true;
					_reason = "Reached Destination.";
					false
				};
				if (_missDone) exitWith {};
				uiSleep 5;
			};
		", _unitArrayName];
		
		diag_log text format ["[VEMF]: WaitMissComp: Waiting Over. %1 %2", _unitArrayName, _reason];
		
	};
};
find_suitable_suppressor = {
	
	private["_weapon","_result","_ammoName"];

	_result 	= "";
	_weapon 	= _this;
	_ammoName	= getText  (configFile >> "cfgWeapons" >> _weapon >> "displayName");

	if(["5.56", _ammoName] call KK_fnc_inString) then {
		_result = "muzzle_snds_M";
	};
	if(["6.5", _ammoName] call KK_fnc_inString) then {
		_result = "muzzle_snds_H";
	};
	if(["7.62", _ammoName] call KK_fnc_inString) then {
		_result = "muzzle_snds_H";
	};
	
	_result
};
/*
Parameter(s):
    _this select 0: <string> string to be found
    _this select 1: <string> string to search in
*/
KK_fnc_inString = {

	private ["_needle","_haystack","_needleLen","_hay","_found"]; 

	_needle 	= [_this, 0, "", [""]] call BIS_fnc_param; 
	
	_haystack 	= toArray ([_this, 1, "", [""]] call BIS_fnc_param); 
	_needleLen 	= count toArray _needle;
	
	_hay 		= +_haystack; 
	_hay 		resize _needleLen;
	_found 		= false; 

	for "_i" from _needleLen to count _haystack do { 

		if (toString _hay == _needle) exitWith {_found = true};
		_hay set [_needleLen, _haystack select _i]; 
		_hay set [0, "x"]; _hay = _hay - ["x"]
	 }; 

	_found
};

/* ================================= End Of Functions ================================= */
diag_log text "[VEMF]: All Functions Loaded.";
