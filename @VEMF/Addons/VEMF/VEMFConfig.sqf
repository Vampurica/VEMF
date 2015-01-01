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

///////////////////////////////////////////////////////////////////
// Blacklist Zone Array -- missions will not spawn in these areas
// format: [[x,y,z],radius]
// Ex: [[06325,07807,0],300] //Starry Sobor
VEMFBlacklistZones = [
	[[0,0,0],50]
];

// Blacklisted Weapons
VEMFWepBlack = [
	"ChainSaw",
	"Hatchet",
	"speargun_epoch"
];

/* ======== Do Not Modify Below ======== */
VEMFVersion = "1.0 DEV";