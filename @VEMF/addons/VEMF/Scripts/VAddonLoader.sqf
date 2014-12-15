/*
	VEMF Addon Loader by Vampire
	Runs addon scripts.
*/
private ["_VEMFAddon"];

// What is your addon script name?
// If you're fancy enough you can include folder names.
// You have to keep you addons looping if required, this script doesn't loop.
// Example: Caves.sqf
_VEMFAddon = [""];

/*====================== Do Not Edit Below ======================*/
if (!isnil VEMFLock) exitWith {};

{
	if (_x != "") then {
		// Let's run the addon
		[] execVM format ["\VEMF\Addons\%1", _x];
	};
} forEach _VEMFAddon;

_VEMFAddon = nil;
VEMFLock = true;