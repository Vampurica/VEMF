/*
	Vampire's Epoch Mission Framework Config by Vampire
	
	If you paid for this script, they are breaking the license terms.
	If you paid to have this installed, I suggest you get a refund.
	
	VEMF: https://github.com/SMVampire/VEMF
*/

///////////////////////////////////////////////////////////////////
// VEMF Debug Settings:
// Creates a lot of RPT Entries, turn off after debugging
VEMFDebugLocs = false;
VEMFDebugAI = false;
VEMFDebugFunc = false;

// Min & Max Mission Times (Will Be Made Better)
// Time is in Minutes
// Min Must Be Less Than Max
VEMFMinMissTime = 5;
VEMFMaxMissTime = 20;

// Mission Name Array
VEMFMissionArray = ["DynamicTownInvasion"];

// Custom Addon Array (Don't Touch Unless You're Positive)
// What is your addon script name?
// Example: Caves.sqf
VEMFAddon = [""];

// Punish Players who Run Over AI?
// Causes 10% Vehicle Damage per AI Runover
VEMFPunishRunover = true;

///////////////////////////////////////////////////////////////////
// Blacklist Zone Array -- missions will not spawn in these areas
// format: [[x,y,z],radius]
// Ex: [[06325,07807,0],300] //Starry Sobor
VEMFBlacklistZones = [
	[[0,0,0],50]
];

/* ======== Do Not Modify Below ======== */
VEMFVersion = "1.0.0-dev";