/*
	File: VInit.sqf
	Author: Vampire ( http://github.com/SMVampire/VEMF )
	License: Attribution-NonCommercial-ShareAlike 4.0 International
	If you were sold this script it is against the license.
	If you paid to have this installed, I suggest you get your money back.
	
	Description:
	Starts all the files that need to run to start VEMF.
	All files branch out from here.
*/
private ["_mConfig"];

if (!isServer) exitWith {
	// Only the server should run this file, client will exit
	// If you remove this IF, may god help you with the errors
};

// Let's let any heavier scripts run first
sleep 60;

// Check if another version is running
if (!isnil("VEMFRunning")) exitWith { diag_log text format ["[VEMF]: <ERROR> VEMF is Installed Twice or Installed Incorrectly!"]; };

// Global variable so other scripts can check if VEMF is running
VEMFRunning = true;
publicVariable "VEMFRunning"; // For Clientside Scripts since globals are not public by default in A3

diag_log text format ["[VEMF]: Starting Vampire's Epoch Mission Framework."];

// Debug. Should be True / True / True
diag_log text format ["[VEMF]: isServer:%1 / isDedicated:%2 / isMultiplayer:%3", isServer, isDedicated, isMultiplayer];

// Let's set some relations up
diag_log text format ["[VEMF]: Setting VEMF Relations to make AI Hostile."];

createCenter INDEPENDENT;
CIVILIAN setFriend [INDEPENDENT,0];
INDEPENDENT setFriend [CIVILIAN,0];

diag_log text format ["[VEMF]: Looking for the Config. Ignore the associated File Not Found error."];

// Let's Load the Mission Configuration
// This code checks for a config file in the Mission Root before using the Addon Config
// A "File Not Found" Error is to be expected if it doesn't exist.
_mConfig = preprocessFileLineNumbers "VEMFConfig.sqf";
if (_mConfig != '') then {
	// Config is in the Mission
	_mConfig = nil; // Kill Var
	call compile preprocessFileLineNumbers "VEMFConfig.sqf";
} else {
	// Use the Config in the Addon
	_mConfig = nil; // Kill Var
	call compile preprocessFileLineNumbers "\VEMF\VEMFConfig.sqf";
};

// Report the version
diag_log text format ["[VEMF]: Currently Running Version: %1", VEMFVersion];

// Version Check
if (VEMFVersion != "1.0 DEV") then {
	diag_log text format ["[VEMF]: Outdated Configuration Detected! Please Update."];
};

diag_log text format ["[VEMF]: Configurations Loaded."];

// Lets get the map name in case we need it
VEMFWorldName = toLower format ["%1", worldName];
diag_log text format["[VEMF]: Server is Running Map: %1", VEMFWorldName];

// Lets load our functions
call compile preprocessFileLineNumbers "\VEMF\VFunctions.sqf";