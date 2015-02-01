/*
	A to B Delivery Mission by Vampire
*/
private ["_start","_end","_safePos","_transport","_msg","_msg2","_alert","_reason","_time"];

if (!isNil "VEMFABDelivery") exitWith {
	// Convoy Already Running
};
VEMFABDelivery = true;

diag_log text format ["[VEMF]: Running AtoB Delivery Mission."];

// Find a Starting Point
_start = call VEMFFindTown;

// Find an ending point
while {true} do {
	_end = call VEMFFindTown;
	
	if (((_start select 1) distance (_end select 1)) > 1500) exitWith {};
};

// Spawn Vehicle (Temporary)
_safePos = (start select 1);
_safePos = (_start select 1) findEmptyPosition [0,50,"B_Truck_01_box_F"];
_transport = createVehicle ["B_Truck_01_box_F",_safePos,[],0,"CAN_COLLIDE"];
[_transport, true] call VEMFSetupVic;

// Message Players
_msg = format ["Vehicle Needs Delivered to %1", (_start select 0)];
_msg2 = format ["You can find the Vehicle in %1. Don't Ask what's in the back.", (_end select 0)];
_msg = [_msg,_msg2];
_alert = [_msg] call VEMFBroadcast;

if (!_alert) exitWith {
	// No Players have a Radio Equipped. Maybe we can try later?
	diag_log text format ["[VEMF]: ABDelivery: Mission Ended for No Active Radios."];
	VEMFABDelivery = nil;
};

// Now We Wait
waitUntil { !isNull (driver _transport) };

// Waiting Over. Announce to Everyone the Route
_msg = format ["Player HEMMT Box Leaving %1", (_start select 0)];
_msg2 = format ["Wealthy Buyer Awaiting Vehicle in %1.", (_end select 0)];
VEMFChatMsg = [_msg,_msg2];

{
	if (isPlayer _x) then {
		(owner (vehicle _x)) publicVariableClient "VEMFChatMsg";
	};
} forEach (playableUnits - (driver _transport));

// Warn Driver
_msg2 = format ["You have one hour to reach %1. Make it quick.", (_end select 0)];
VEMFChatMsg = ["Watch for Roadblocks by Hostiles.",_msg2];
(owner (driver _transport)) publicVariableClient "VEMFChatMsg";

// Wait for the Vehicle to Die, Timeout, or Reach Destination
_reason = "none";
_time = diag_tickTime;
while {true} do {
	if (!(alive _transport)) exitWith {
		// Vehicle Dead
		_reason = "dead";
	};
	if (((_end select 1) distance _transport) <= 150) exitWith {
		// Goal Accomplished
		_reason = "goal";
	};
	if ((diag_tickTime - _time) > 3600) exitWith {
		// Goal Timeout
		_reason = "time";
	};
	
	uiSleep 5;
};

if (_reason == "none") exitWith {
	// No Idea What Happened
	VEMFABDelivery = nil;
};
if (_reason == "time") exitWith {
	// Time the Driver finds out what he's Transporting
	if (!(isNull (driver _transport))) then {
		VEMFChatMsg = ["You Hear the Slight Hum in the Back Stop","You wonder what that could mean. Didn't it say you had only an Hour?"];
		(owner (driver _transport)) publicVariableClient "VEMFChatMsg";
	};
	uiSleep 10;
	_transport setDamage 1;
	VEMFABDelivery = nil;
	
	VEMFChatMsg = ["HEMMT Box was Destroyed in Route","The Wealthy Buyer has Fled the Area."];

	{
		if (isPlayer _x) then {
			(owner (vehicle _x)) publicVariableClient "VEMFChatMsg";
		};
	} forEach playableUnits;
};
if (_reason == "dead") exitWith {
	// Vehicle was Killed. Nobody Wins.
	VEMFABDelivery = nil;
	
	VEMFChatMsg = ["HEMMT Box was Destroyed in Route","The Wealthy Buyer has Fled the Area."];

	{
		if (isPlayer _x) then {
			(owner (vehicle _x)) publicVariableClient "VEMFChatMsg";
		};
	} forEach playableUnits;
};
if (_reason == "goal") then {
	// Let players know it's over
	VEMFChatMsg = ["HEMMT Box Reached the Destination","The Wealthy Buyer has Given a Hefty Reward to the Driver."];

	{
		if (isPlayer _x) then {
			(owner (vehicle _x)) publicVariableClient "VEMFChatMsg";
		};
	} forEach playableUnits;
	
	// Reward Player
	if (!(isNull (driver _transport))) then {
		[['effectCrypto', "2000"], (owner (driver _transport))] call EPOCH_sendPublicVariableClient;
	};
	
	// Remove Vehicle
	if (!(isNull (driver _transport))) then {
		while { (speed _transport) > 1 } do {
			(driver _transport) action ["engineOff", _transport];
			uiSleep 1;
		};
		
		{ _x action ["getOut", _transport]; } forEach (crew _transport);
	};
	
	deleteVehicle _transport;
	
	VEMFABDelivery = nil;
};

VEMFABDelivery = nil;