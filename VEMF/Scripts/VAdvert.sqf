/*
	VEMF Advert by Vampire
	
	Description:
	- Alerts the player that the server is running VEMF so they know what to expect.
*/
private ["_msg1","_msg2","_msg","_allUnits","_told"];

if (!VEMFAdvert) exitWith {};

_msg1 = "Vampire's Epoch Mission Framework Running";
_msg2 = "If you enjoy the missions, please consider funding Vampire on Patreon.";
_msg = [_msg1,_msg2];

while {true} do {
	_allUnits = playableUnits;
	
	if (isNil "_told") then { _told = []; };
	
	_allUnits = _allUnits call VEMFRemoveDups;
	
	{
		if (!(isPlayer _x)) then {
			_allUnits = _allUnits - [_x];
		};
	} forEach _allUnits;
	
	{
		if (!((getPlayerUID _x) in _told)) then {
			"VEMFChatMsg" = _msg;
			(owner (vehicle _x)) publicVariableClient "VEMFChatMsg";
			_told = _told + [(getPlayerUID _x)];
		};
	} forEach _allUnits;
	
	uiSleep 300;
};