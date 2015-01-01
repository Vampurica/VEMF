/*
	Generate Weapon Lists by Vampire
	
	Description:
	 - Dynamically Generates the Item Lists for Epoch.
*/
private ["_rifles","_pistols"];

_rifles = [];
_pistols = [];

// Get All Rifles for Sale
{
	if ((isClass(configFile >> "CfgWeapons" >> configName _x)) && ((getNumber(configFile >> "CfgWeapons" >> configName _x >> "type")) == 1)) then {
		if (!((configName _x) in VEMFWepBlack)) then {
			_rifles pushBack (configName _x);
		};
	};
} forEach ("getNumber(_x >> 'price') != -1" configClasses (configFile >> "CfgPricing"));

// Get All Pistols for Sale
{
	if ((isClass(configFile >> "CfgWeapons" >> configName _x)) && ((getNumber(configFile >> "CfgWeapons" >> configName _x >> "type")) == 2)) then {
		if (!((configName _x) in VEMFWepBlack)) then {
			_pistols pushBack (configName _x);
		};
	};
} forEach ("getNumber(_x >> 'price') != -1" configClasses (configFile >> "CfgPricing"));

VEMFRiflesList = _rifles;
VEMFPistolsList = _pistols;