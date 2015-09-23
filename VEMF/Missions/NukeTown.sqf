/*
	Town Nuke Mission by Vampire
*/
private ["_canTown","_grpCnt","_housePos","_sqdPos","_msg","_alert","_wait","_nuke","_nukePos","_laptop","_time"];

if (!isNil "VEMFNukeMission") exitWith {
	// Mission Already Running
};

VEMFNukeMission = true;

diag_log text format ["[VEMF]: Running Dynamic Town Nuke Mission."];

// Find A Town to Invade
_canTown = call VEMFFindTown;

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
_msg = [_msg,"They seem to have some Weird Device with them."];
_alert = [_msg] call VEMFBroadcast;

if (!_alert) exitWith {
	// No Players have a Radio Equipped. Maybe we can try later?
	diag_log text format ["[VEMF]: DynTownInv: Mission Ended for No Active Radios."];
	VEMFNukeMission = nil;
};

// Usage: COORDS, Radius
_wait = [(_canTown select 1),1000] call VEMFNearWait;

if (!_wait) exitWith {
	diag_log text format ["[VEMF]: DynTownInv: Mission Ended for Timeout."];
	VEMFNukeMission = nil;
};

// Player is Near, so Spawn the Units
[(_canTown select 1),_sqdPos,false,1,"VEMFNukeMiss"] ExecVM VEMFSpawnAI;

// Spawn the Nuke Device
_nuke = createVehicle ["Land_Device_assembled_F",(_canTown select 1),[],0,"CAN_COLLIDE"];
_nuke setVariable ["VEMFScenery", true];
_nukePos = (_canTown select 1) findEmptyPosition [0,50,(typeOf _nuke)];
if ((count _nukePos) > 0) then {
	_nuke setPos _nukePos;
};
_laptop = createVehicle ["Land_Laptop_device_F",(getpos _nuke),[],0,"CAN_COLLIDE"];
_laptop attachTo [_nuke,[0,-1.63,0.78]];
_laptop setDir 180;

waitUntil{!isNil "VEMFNukeMiss"};

// Wait for Mission Completion
[(_canTown select 1),"VEMFNukeMiss"] call VEMFWaitMissComp;

{
	if ((isPlayer _x) && {((_x distance (_canTown select 1)) <= 600)}) then {
		[["earthQuake",(_canTown select 1)],(owner _x)] call EPOCH_sendPublicVariableClient;
		
		VEMFChatMsg = ["The Device in Town is Activating!","You Must Defuse it or it will Destroy the Town!"];
		(owner _x) publicVariableClient "VEMFChatMsg";
	};
} forEach playableUnits;

// Wait for Defuse or Timeout
VEMFNukeEH = _nuke addEventHandler ["Hit", "(_this select 0) setDamage ((getDammage (_this select 0)) + 0.1); VEMFNukeSavior = (_this select 1);"];

_time = diag_tickTime;
while {true} do {
	if (!(alive _nuke)) exitWith {
		// Mission Complete
		
		if (!(isNil "VEMFNukeSavior")) then {
			[['effectCrypto', "2000"], (owner VEMFNukeSavior)] call EPOCH_sendPublicVariableClient;
			VEMFNukeSavior = nil;
		};
	};
	if ((diag_tickTime - _time) > 60) exitWith {
		// Nuke the Town
		_bomb = "Bo_GBU12_LGB" createVehicle (getpos _nuke);
		_bomb setVelocity [100,0,0];
		{
			_x setDamage 1;
		} forEach (_nuke nearObjects 400);
		
		deleteVehicle _nuke;
		deleteVehicle _laptop;
		
		{
			if (isPlayer _x) then {
				[["earthQuake",(_canTown select 1)],(owner _x)] call EPOCH_sendPublicVariableClient;
				
				VEMFChatMsg = [("Some Sort of Nuclear Device has Gone Off in " + (_canTown select 0)),"The area may be irradiated from the blast."];
				(owner _x) publicVariableClient "VEMFChatMsg";
			};
		} forEach playableUnits;
	};
};

// Remove from Missions
VEMFMissionArray = VEMFMissionArray - ["NukeTown"];