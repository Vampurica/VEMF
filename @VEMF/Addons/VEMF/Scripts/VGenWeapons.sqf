/*
	Generate Weapon Lists by Vampire
	
	Description:
	 - Dynamically Generates the Weapon Lists for Epoch.
*/

// Only Runs if Dynamic Weapons = true
if (!(VEMFDynWeapons)) exitWith {};

VEMFRiflesList = [];
VEMFPistolsList = [];

// Get All Rifles for Sale
{
	if ((isClass(configFile >> "CfgWeapons" >> configName _x)) && ((getNumber(configFile >> "CfgWeapons" >> configName _x >> "type")) == 1)) then {
		if (!((configName _x) in VEMFWepBlack)) then {
			VEMFRiflesList pushBack (configName _x);
		};
	};
} forEach ("getNumber(_x >> 'price') > 0" configClasses (configFile >> "CfgPricing"));

// Get All Pistols for Sale
{
	if ((isClass(configFile >> "CfgWeapons" >> configName _x)) && ((getNumber(configFile >> "CfgWeapons" >> configName _x >> "type")) == 2)) then {
		if (!((configName _x) in VEMFWepBlack)) then {
			VEMFPistolsList pushBack (configName _x);
		};
	};
} forEach ("getNumber(_x >> 'price') > 0" configClasses (configFile >> "CfgPricing"));