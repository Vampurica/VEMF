/*
	VEMF Spawn AI by Vampire
	
	This code is under a Non-Commercial ShareAlike License.
	Make sure to read the LICENSE before using this code elsewhere.
	
	Description:
		Spawns AI to the target location
		Player must be within 800m or they get Cached after spawning
		(Write your code to spawn them after player is near)
		
	Usage: [_positionArray, True, SkillLvl, GroupCount] call VEMFSpawnAI;
		
	Variables:
		0: Position Array (1 Unit Per Position)
		1: BOOLEAN - (True) Strict or (False) Rough Group Leader Assignments?
			Strict will keep groups to your specifications,
			Rough will spawn a unit at each position and group them more passively.
			- Use Strict For Spawning En-Mass, and Rough for Fine Positioning
		2: Skill Level Max (1-4)
		3: Group Name
		4: Group Count (Optional) required if 1 is True.
			The amount of groups you want.
			If you supply a group count, and 1 is True, you will get one group spawned at each position.
*/
private ["_posArr","_SorR","_skill","_arrName","_grpCount","_sldrClass","_unitsPerGrp","_owner","_grp","_newPos",
"_grpArr","_unit","_pos","_waypoints","_wp","_cyc"];

_posArr   = _this select 0;
_SorR     = _this select 1;
_skill    = _this select 2;
_arrName  = _this select 3;
_grpCount = _this select 4;

if (isNil "_grpCount") then {_grpCount = 0;};

if (VEMFDebugAI) then {
	diag_log text format ["[VEMF]: AI Spawn Vars: %1 / %2 / %3 / %4 / %5", str _posArr, _SorR, _skill, _arrName, _grpCount];
};
	
_sldrClass = "I_Soldier_EPOCH";
_unitsPerGrp = 4;

// We need to do this two very different ways depending on Strict or Rough Distribution
if (_SorR) then
{
	// Strict Distribution

	if (count _posArr > 1) then {
		// We have multiple positions. Spawn a group at each one.
		
		// Check for Nested Array
		if (typeName (_posArr select 0) == "SCALAR") exitWith {
			diag_log text format ["[VEMF]: Warning: AI Spawn: Strict Distribution Not a Nested Array!"];
		};
		
		// Find the Owner
		//_owner = owner (((_posArr select 0) nearEntities [["Epoch_Male_F", "Epoch_Female_F"], 800]) select 0);
		
		// Create the Group
		_grp = createGroup RESISTANCE;
		_grp setBehaviour "AWARE";
		_grp setCombatMode "RED";
		
		{
			for "_i" from 1 to (_grpCount*_unitsPerGrp) do
			{
				// Find Nearby Position (Radius 25m)
				_newPos = [_x,0,25,60,0,20,0] call BIS_fnc_findSafePos;
				
				if (count (units _grp) == _unitsPerGrp) then {
					// Fireteam is Full, Create a New Group
					_grpArr = [];
					_grpArr = _grpArr + [_grp];
					_grp = grpNull;
					_grp = createGroup RESISTANCE;
					_grp setBehaviour "AWARE";
					_grp setCombatMode "RED";
				};
				
				// Create Unit There
				_unit = _grp createUnit [_sldrClass, _newPos, [], 0, "FORM"];
				
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
				//_unit addEventHandler ["Local",{ [(_this select 0), (_this select 1)] ExecVM VEMFLocalHandler; }];
				_unit addEventHandler ["Killed",{ [(_this select 0), (_this select 1)] ExecVM VEMFAIKilled; }];
				_unit setVariable ["VEMFUArray", _arrName];
				_unit setVariable ["VEMFAI", true];
				_unit setVariable ["LASTLOGOUT_EPOCH", (diag_tickTime + 14400)];
				
				// Leader Assignment
				if (count (units _grp) == _unitsPerGrp) then {
					_unit setSkill 1;
					_grp selectLeader _unit;
				};
				
				// Set Owner to Prevent Server Local Cleanup
				//_unit setOwner _owner;
			};
		} forEach _posArr;

		if (VEMFDebugAI) then {
			diag_log text format ["[VEMF]: AI Debug: Spawned %1 Units at Grid %2", (_grpCount*_unitsPerGrp), (mapGridPosition _pos)];
		};
		
	} else {
	
		// We have a single POS given.
		// Check for a nested array
		if (typeName (_posArr select 0) != "SCALAR") then {
			_pos = _posArr select 0;
		} else {
			_pos = _posArr;
		};
		
		// Find the Owner
		//_owner = owner ((_pos nearEntities [["Epoch_Male_F", "Epoch_Female_F"], 800]) select 0);
	
		// Create the Group
		_grp = createGroup RESISTANCE;
		_grp setBehaviour "AWARE";
		_grp setCombatMode "RED";
		
		// Spawn Groups near Position
		for "_i" from 1 to (_grpCount*_unitsPerGrp) do
		{
			// Find Nearby Position (Radius 25m)
			_newPos = [_pos,0,25,60,0,20,0] call BIS_fnc_findSafePos;
			
			if (count (units _grp) == _unitsPerGrp) then {
				// Fireteam is Full, Create a New Group
				_grpArr = [];
				_grpArr = _grpArr + [_grp];
				_grp = grpNull;
				_grp = createGroup RESISTANCE;
				_grp setBehaviour "AWARE";
				_grp setCombatMode "RED";
			};
			
			// Create Unit There
			_unit = _grp createUnit [_sldrClass, _newPos, [], 0, "FORM"];
			
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
			//_unit addEventHandler ["Local",{ [(_this select 0), (_this select 1)] ExecVM VEMFLocalHandler; }];
			_unit addEventHandler ["Killed",{ [(_this select 0), (_this select 1)] ExecVM VEMFAIKilled; }];
			_unit setVariable ["VEMFUArray", _arrName];
			_unit setVariable ["VEMFAI", true];
			_unit setVariable ["LASTLOGOUT_EPOCH", (diag_tickTime + 14400)];
			
			// Leader Assignment
			if (count (units _grp) == _unitsPerGrp) then {
				_unit setSkill 1;
				_grp selectLeader _unit;
			};
			
			// Set Owner to Prevent Server Local Cleanup
			//_unit setOwner _owner;
		};
		
		if (VEMFDebugAI) then {
			diag_log text format ["[VEMF]: AI Debug: Spawned %1 Units at Grid %2", (_grpCount*_unitsPerGrp), (mapGridPosition _pos)];
		};
	};

} else {

	// Rough Distribution

	if (typeName (_posArr select 0) == "SCALAR") exitWith {
		diag_log text format ["[VEMF]: Warning: AI Spawn: Rough Distribution Requires Multiple Positions!"];
	};
	
	// Only used for the log
	_pos = _posArr select 0;
	
	// Find the Owner
	//_owner = owner ((_pos nearEntities [["Epoch_Male_F", "Epoch_Female_F"], 800]) select 0);
	
	// Create the Group
	_grp = createGroup RESISTANCE;
	_grp setBehaviour "AWARE";
	_grp setCombatMode "RED";

	{
		// Create Unit
		_unit = _grp createUnit [_sldrClass, _x, [], 0, "FORM"];
		
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
		//_unit addEventHandler ["Local",{ [(_this select 0), (_this select 1)] ExecVM VEMFLocalHandler; }];
		_unit addEventHandler ["Killed",{ [(_this select 0), (_this select 1)] ExecVM VEMFAIKilled; }];
		_unit setVariable ["VEMFUArray", _arrName];
		_unit setVariable ["VEMFAI", true];
		_unit setVariable ["LASTLOGOUT_EPOCH", (diag_tickTime + 14400)];
		
		// Separate Groups via Location Distance
		// Logic is that group positions come in via houses
		// Therefore separate them to one group per house
		if (_forEachIndex != 0) then {
			if ((_x distance (_posArr select (_forEachIndex-1))) > 25) then {
				// Too Far, Need New Group
				_unit setSkill 1;
				_grp selectLeader _unit;
				_grpArr = [];
				_grpArr = _grpArr + [_grp];
				_grp = grpNull;
				_grp = createGroup RESISTANCE;
				_grp setBehaviour "AWARE";
				_grp setCombatMode "RED";
			};
		};
		
		// Set Owner to Prevent Server Local Cleanup
		//_unit setOwner (owner _owner);
	} forEach _posArr;
	
	if (VEMFDebugAI) then {
		diag_log text format ["[VEMF]: AI Debug: Spawned %1 Units near Grid %2", (count _posArr), (mapGridPosition _pos)];
	};
};

if (isNil "_grpArr") exitWith {};

// Waypoints
_waypoints = [
	[(_pos select 0), (_pos select 1)+100, 0],
	[(_pos select 0)+100, (_pos select 1), 0],
	[(_pos select 0), (_pos select 1)-100, 0],
	[(_pos select 0)-100, (_pos select 1), 0]
];

// Make them Patrol
{
	for "_z" from 0 to ((count _waypoints)-1) do {
		_wp = _x addWaypoint [(_waypoints select _z), 10];
		_wp setWaypointType "SAD";
		_wp setWaypointCompletionRadius 20;
	};
	
	_cyc = _x addWaypoint [_pos,10];
	_cyc setWaypointType "CYCLE";
	_cyc setWaypointCompletionRadius 20;
} forEach _grpArr;

// Add the Units to a Mission Var to track completion.
call compile format["
	if (isNil '%1') then {%1 = [];};
	{
		%1 = %1 + (units _x);
	} forEach _grpArr;
", _arrName];