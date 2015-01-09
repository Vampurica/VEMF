/*
	VEMF AI Killed by Vampire
	
	Description:
	 - Alerts Nearby AI to an AI Death
*/
private ["_unit","_killer","_tracker","_grpUnits"];

_unit = _this select 0;
_killer = _this select 1;
_tracker = _unit getVariable ["VEMFUArray", "VEMFNoUArr"];

// Player or Vehicle?
if (_killer isKindOf "Man") then {
	if (isPlayer _killer) then {
		// Killer was Player on Foot
		
		// Alert Nearby AI
		{
			if ((_x distance _killer) <= 500) then {
				_x reveal [_killer, 4.0];
			};
		} forEach (units group _unit);
		(group _unit) setFormDir ([(leader group _unit), _killer] call BIS_fnc_dirTo);
		
		// Report to Mission about Killer
		call compile format["
			if (isNil '%1') then {%1 = [];};
			if (count %1 == 1) then {
				%1Killer = _killer;
			};
		", _tracker];
	} else {
		// Killer was AI
	};
} else {
	if (isPlayer (driver _killer)) then {
		// Killer was Player in Vehicle
		
		// Alert Nearby AI
		{
			if ((_x distance _killer) <= 800) then {
				_x reveal [_killer, 4.0];
			};
		} forEach (units group _unit);
		(group _unit) setFormDir ([(leader group _unit), _killer] call BIS_fnc_dirTo);
		
		// Report to Mission about Killer
		call compile format["
			if (isNil '%1') then {%1 = [];};
			if (count %1 == 1) then {
				%1Killer = (crew _killer) select 0;
			};
		", _tracker];
		
		// Optional Vehicle Punish
		if (VEMFPunishRunover) then {
			_killer setDamage ((getDammage _killer) + 0.1);
		};
	} else {
		// Unknown Cause
	};
};

// Remove From Mission Tracker
call compile format["
	if (isNil '%1') then {%1 = [];};
	%1 = %1 - [_unit];
", _tracker];

// Promotion
if ((count (units group _unit)) > 1) then {
	if ((leader group _unit) == _unit) then {
		_grpUnits = units group _unit;
		_grpUnits = _grpUnits - [_unit];
		(group _unit) setLeader (_grpUnits call BIS_fnc_selectRandom;);
		(leader group _unit) setSkill 1;
	};
};

// Delete Empty Groups
if (count(units group _unit) <= 1) then {
	// Delete Empty or To-Be-Empty Group
	deleteGroup (group _unit);
};

// Remove From Group
[_unit] joinSilent grpNull;
