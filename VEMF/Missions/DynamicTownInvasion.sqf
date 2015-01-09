/*
	Dynamic Town Invasion Mission by Vampire
*/
private ["_canTown","_nearPlyr","_grpCnt","_housePos","_sqdPos","_msg","_alert","_winMsg","_crate"];

if (!isNil "VEMFTownInvaded") exitWith {
	// Town Already Under Occupation
};

VEMFTownInvaded = true;

diag_log text format ["[VEMF]: Running Dynamic Town Invasion Mission."];

// Find A Town to Invade
while {true} do {
	_canTown = call VEMFFindTown;
	_nearPlyr = {isPlayer _x} count ((_canTown select 1) nearEntities[["Epoch_Male_F", "Epoch_Female_F"], 800]) > 0;
	
	if (!_nearPlyr) exitWith {
		// No Players Near Else Loop Again
	};
	
	uiSleep 30;
};

// Group Count
_grpCnt = 5;

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
_msg = format ["We have spotted hostile fireteams in %1! We'll give you some supplies if you can liberate the town.", (_canTown select 0)];
_alert = [_msg] call VEMFBroadcast;

if (!_alert) exitWith {
	// No Players have a Radio Equipped. Maybe we can try later?
	diag_log text format ["[VEMF]: DynTownInv: Mission Ended for No Active Radios."];
	VEMFTownInvaded = nil;
};

// Usage: COORDS, Radius
[(_canTown select 1),1000] call VEMFNearWait;

// Player is Near, so Spawn the Units
[_sqdPos,false,1,"VEMFDynInv"] ExecVM VEMFSpawnAI;

waitUntil{!isNil "VEMFDynInv"};

// Wait for Mission Completion
[(_canTown select 1),"VEMFDynInv"] call VEMFWaitMissComp;

// Rewards
if (!(isNil "VEMFDynInvKiller")) then {
	_winMsg = format ["%1 has been cleared! You can find your reward at the town center.", (_canTown select 0)];
	VEMFChatMsg = [_winMsg];
	(owner (vehicle VEMFDynInvKiller)) publicVariableClient "VEMFChatMsg";
	VEMFDynKiller = nil;
	
	_crate = createVehicle ["Land_PaperBox_C_EPOCH",(_canTown select 1),[],0,"CAN_COLLIDE"];
	_crate setVariable ["VEMFScenery", true];
	[_crate] call VEMFLoadLoot;
};

// Clean Up Remaining AI
if (count VEMFDynInv > 0) then {
	{ deleteVehicle _x } forEach VEMFDynInv;
};

VEMFTownInvaded = nil;