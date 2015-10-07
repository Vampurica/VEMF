/*
	VEMF Mission Timer by Vampire
	
	Description:
	 - Runs a Loop to Launch New Missions
	 - Will Be Made More Advanced in the Future
*/
private ["_timeDiff","_missVar"];

// Find the Min and Max time
_timeDiff = ((VEMFMaxMissTime*60) - (VEMFMinMissTime*60));

diag_log text format ["[VEMF]: Mission Timer Started."];

while {true} do {
	// Wait a Random Amount
	uiSleep ((floor(random(_timeDiff))) + (VEMFMinMissTime*60));
	
	// Pick A Mission
	if ((count VEMFMissionArray) == 0) exitWith {
		/* No Missions */
	};
	_missVar = VEMFMissionArray call BIS_fnc_selectRandom;
	
	// Run It
	[] execVM format ["\VEMF\Missions\%1.sqf",_missVar];
};