/*
	Vampire's Epoch Mission Framework Config by Vampire
	
	If you paid for this script, they are breaking the license terms.
	If you paid to have this installed, I suggest you get a refund.
	
	VEMF: https://github.com/SMVampire/VEMF
*/

/////////////////////////////////////////////////////////////////////////////////
// What is the minimum time a player must wait before they get another mission?
// They cannot get a mission assignment earlier than this. Default 10mins.
VEMFMinTime = 600;

///////////////////////////////////////////////////////////////////
// Blacklist Zone Array -- missions will not spawn in these areas
// format: [[x,y,z],radius]
// Ex: [[06325,07807,0],300] //Starry Sobor
VEMFBlacklistZones = [
	[[0,0,0],50]
];

=============================================
VEMFVersion = "1.0 DEV";