/*
	VEMF Spawn Single AI by Vampire
	
	This code is under a Non-Commercial ShareAlike License.
	Make sure to read the LICENSE before using this code elsewhere.
	
	Description:
		Spawns a Single AI to the target location
		
	Usage: [_pos] call VEMFSpawnSingleAI;
		
	Variables:
		0: Spawn Position
*/
private ["_pos","_sldrClass","_grp","_unit"];

_pos = _this select 0;

if ((isNil "_pos") || (count _pos < 3)) exitWith {};

if (VEMFDebugAI) then {
	diag_log text format ["[VEMF]: Single AI Spawn Vars: %1", _pos];
};

_sldrClass = "I_Soldier_EPOCH";

// Create the Group
_grp = createGroup RESISTANCE;
_grp setBehaviour "AWARE";
_grp setCombatMode "YELLOW";

// Create the Unit
_unit = _grp createUnit [_sldrClass, _pos, [], 0, "FORM"];

// Load the AI
[_unit] call VEMFLoadAIGear;

// Enable its AI
_unit setSkill 0.6;
_unit setRank "Private";
_unit enableAI "TARGET";
_unit enableAI "AUTOTARGET";
_unit enableAI "MOVE";
_unit enableAI "ANIM";
// Might write a custom FSM in the future
// Default Arma 3 Soldier FSM for now
_unit enableAI "FSM";

// Prepare for Cleanup or Caching
_unit addEventHandler ["Killed",{ [(_this select 0), (_this select 1)] ExecVM VEMFAIKilled; }];
_unit setVariable ["VEMFUArray", _arrName];
_unit setVariable ["VEMFAI", true];
_unit setVariable ["LASTLOGOUT_EPOCH", (diag_tickTime + 14400)];

// Return the Unit
_unit