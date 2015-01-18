/*
	Dynamic Town Invasion Mission by Vampire
*/
private ["_canTown","_nearPlyr","_grpCnt","_housePos","_sqdPos","_msg","_alert","_winMsg","_crate","_cratePos","_wait"];

if (!isNil "VEMFTownInvaded") exitWith {
	// Town Already Under Occupation
};

VEMFTownInvaded = true;

diag_log text format ["[VEMF]: Running Dynamic Town Invasion Mission."];

// Find A Town to Invade
while {true} do {
	_canTown = call VEMFFindTown;
	_nearPlyr = {isPlayer _x} count ((_canTown select 1) nearEntities [["Epoch_Male_F", "Epoch_Female_F"], 800]) > 0;
	
	if (!_nearPlyr) exitWith {
		// No Players Near Else Loop Again
	};
	
	uiSleep 30;
};

// Group Count
_grpCnt = VEMFGroupCnt;

// We Found a Town with No Players. Let's Invade.
// Format: [POS, HouseCount]
_housePos = [(_canTown select 1), _grpCnt] call VEMFHousePositions;

_sqdPos = [];
{
	// 4 Units to a Squad. One Squad Leader.
	if (!(count _x <= 4)) then {
		_x resize 4;
		_sqdPos = _sqdPos + _x;
	} else {
		_sqdPos = _sqdPos + _x;
	};
} forEach _housePos;


// Now we have Unit Positions, We Announce the Mission and Wait
_msg = format ["Hostile Fireteams seen in %1", (_canTown select 0)];
_msg = [_msg,"Locals Promise Supplies for any Armed Aid."];
_alert = [_msg] call VEMFBroadcast;

if (!_alert) exitWith {
	// No Players have a Radio Equipped. Maybe we can try later?
	diag_log text format ["[VEMF]: DynTownInv: Mission Ended for No Active Radios."];
	VEMFTownInvaded = nil;
};

// Usage: COORDS, Radius
_wait = [(_canTown select 1),1000] call VEMFNearWait;

if (!_wait) exitWith {
	diag_log text format ["[VEMF]: DynTownInv: Mission Ended for Timeout."];
	VEMFTownInvaded = nil;
};

// Player is Near, so Spawn the Units
[(_canTown select 1),_sqdPos,false,1,"VEMFDynInv"] ExecVM VEMFSpawnAI;

waitUntil{!isNil "VEMFDynInv"};

// Wait for Mission Completion
[(_canTown select 1),"VEMFDynInv"] call VEMFWaitMissComp;

// Rewards
_winMsg = format ["%1 Liberated!", (_canTown select 0)];
_winMsg = [_winMsg,"Locals have left Supplies in town for the Liberators."];
VEMFChatMsg = _winMsg;
if (VEMFMissEndAnn > 0) then {
	{
		if ((isPlayer _x) && {((_x distance (_canTown select 1)) <= VEMFMissEndAnn)}) then {
			(owner (vehicle _x)) publicVariableClient "VEMFChatMsg";
		};
	} forEach playableUnits;
} else {
	if (!(isNil "VEMFDynInvKiller")) then {
		(owner (vehicle VEMFDynInvKiller)) publicVariableClient "VEMFChatMsg";
	};
};
VEMFDynKiller = nil;
	
_crate = createVehicle ["Box_IND_AmmoVeh_F",(_canTown select 1),[],0,"CAN_COLLIDE"];
_crate setObjectTextureGlobal [0, "#(argb,8,8,3)color(0,0,0,0.8)"];
_crate setObjectTextureGlobal [1, "#(argb,8,8,3)color(0.82,0.42,0.02,0.3)"];
_crate setVariable ["VEMFScenery", true];
_cratePos = (_canTown select 1) findEmptyPosition [0,50,(typeOf _crate)];
if ((count _cratePos) > 0) then {
	_crate setPos _cratePos;
};
[_crate] call VEMFLoadLoot;
diag_log text format ["[VEMF]: DynTownInv: Crate Spawned At: %1 / Grid: %2", (getPosATL _crate), mapGridPosition (getPosATL _crate)];

VEMFDynInv = nil;
VEMFTownInvaded = nil;