/*
	Supply Convoy by Vampire
*/
private ["_start","_end","_msg","_msg2","_alert","_safePos","_scoutVic","_scoutGrp","_troopTrans",
"_troopGrp","_cargoTrans","_cargoGrp","_hitterVic","_hitterGrp","_grp","_winMsg","_result"];

if (!isNil "VEMFSupplyConvoy") exitWith {
	// Convoy Already Running
};
VEMFSupplyConvoy = true;

diag_log text format ["[VEMF]: Running Supply Convoy Mission."];

// Find a starting point
_start = call VEMFFindTown;

// Find an ending point
while {true} do {
	_end = call VEMFFindTown;
	
	if (((_start select 1) distance (_end select 1)) > 1500) exitWith {};
};

// Message Players
_msg = format ["Supply Convoy Seen Leaving %1", (_start select 0)];
_msg2 = format ["Locals believe %1 to be the Destination.", (_end select 0)];
_msg = [_msg,_msg2];
_alert = [_msg] call VEMFBroadcast;

if (!_alert) exitWith {
	// No Players have a Radio Equipped. Maybe we can try later?
	diag_log text format ["[VEMF]: SupplyConvoy: Mission Ended for No Active Radios."];
	VEMFSupplyConvoy = nil;
};

// Now we spawn in the Convoy
// Has a Scout Vehicle, Troop Transport, Supply Truck, Defensive Vehicle
_safePos = (_start select 1) findEmptyPosition [0,50,"I_G_Offroad_01_F"];
_scoutVic = createVehicle ["I_G_Offroad_01_F",_safePos,[],0,"CAN_COLLIDE"];
[_scoutVic, true] call VEMFSetupVic;
_scoutGrp = [_scoutVic, false] call VEMFFillVic;

_safePos = (_start select 1) findEmptyPosition [0,50,"I_Truck_02_transport_F"];
_troopTrans = createVehicle ["I_Truck_02_transport_F",_safePos,[],0,"CAN_COLLIDE"];
[_troopTrans, true] call VEMFSetupVic;
_troopGrp = [_troopTrans, true] call VEMFFillVic;
[_troopTrans, false] call VEMFLoadLoot;

_safePos = (_start select 1) findEmptyPosition [0,50,"I_Truck_02_box_F"];
_cargoTrans = createVehicle ["I_Truck_02_box_F",_safePos,[],0,"CAN_COLLIDE"];
[_cargoTrans, true] call VEMFSetupVic;
_cargoGrp = [_cargoTrans, false] call VEMFFillVic;
[_cargoTrans, false] call VEMFLoadLoot;

_safePos = (_start select 1) findEmptyPosition [0,50,"I_G_Offroad_01_armed_F"];
_hitterVic = createVehicle ["I_G_Offroad_01_armed_F",_safePos,[],0,"CAN_COLLIDE"];
[_hitterVic, true] call VEMFSetupVic;
_hitterGrp = [_hitterVic, true] call VEMFFillVic;
[_hitterVic, false] call VEMFLoadLoot;

// Group the Groups
_grp = _scoutGrp;
{ [_x] joinSilent _grp; } forEach units _troopGrp;
{ [_x] joinSilent _grp; } forEach units _cargoGrp;
{ [_x] joinSilent _grp; } forEach units _hitterGrp;
_grp setFormation "COLUMN";

// Track Them
VEMFSuppConv = (units _grp);

// Get them Moving
_grp move (_end select 1);

// Wait for Mission Completion
_result = [_cargoTrans,"VEMFSuppConv",_cargoTrans,(_end select 1)] call VEMFWaitMissComp;

// Finish Up
if (_result) then {
	_winMsg = ["Supply Convoy Has Been Eliminated","The Bandits are Retreating from the Area."];
	VEMFChatMsg = _winMsg;
} else {
	_winMsg = ["Supply Convoy Has Reached Destination","The Bandits Grip has becomes Stronger in the Area."];
	VEMFChatMsg = _winMsg;
};

{
	if (isPlayer _x) then {
		(owner (vehicle _x)) publicVariableClient "VEMFChatMsg";
	};
} forEach playableUnits;

if (_result) then {
	diag_log text format ["[VEMF]: SupplyConvoy: Convoy Eliminated near %1. Mission Over.", mapGridPosition (getPosATL _cargoTrans)];
} else {
	diag_log text format ["[VEMF]: SupplyConvoy: Convoy Reached Destination near %1. Mission Over.", mapGridPosition (getPosATL _cargoTrans)];
};

if (!_result) then {
	{ deleteVehicle _x; } forEach VEMFSuppConv;
	{ deleteVehicle _x; } forEach [_scoutVic,_troopTrans,_cargoTrans,_hitterVic];
};

VEMFSuppConv = nil;
VEMFSupplyConvoy = nil;