/*
	VEMF AI Killed by Vampire
	
	Description:
	 - Alerts Nearby AI to an AI Death
*/
private [];

_unit = _this select 0;
_player = _this select 1;

// Remove From Mission Tracker
_tracker = _unit getVariable ["VEMFUArray", "VEMFNoUArr"];
call compile format["
	if (isNil '%1') then {%1 = [];};
	%1 = %1 - [_unit];
", _tracker];

// Punish Run-Overs
