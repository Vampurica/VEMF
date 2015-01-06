/*
	VEMF Addon Loader by Vampire
	Runs addon scripts.
	
	If you're fancy enough you can include folder names Dev's.
	You have to keep your addons looping if required, this script doesn't keep them running.
	
	Examples:
		Caves.sqf
		\VEMF\Addons\Caves\init.sqf
*/

if (VEMFLock == true) exitWith {};

// Time Lock
if (round(serverTime/60) > 5) exitWith {
	diag_log text format ["[VEMF]: Warning: Addon Loader Ran Twice!"];
	VEMFLock = true;
	VEMFAddon = nil;
};

{
	if (_x != "") then {
		// Let's run the addon
		[] execVM format ["\VEMF\Addons\%1", _x];
	};
} forEach VEMFAddon;

VEMFLock = true;
VEMFAddon = nil;