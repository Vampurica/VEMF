/*
	Localization Eventhandler by Vampire
	
	Description:
	Waits for the locality of a unit to change to the server, and reassigns or caches it.
	Units local to the server will be cleaned by the server. Locality changes when a player logs off.
*/
private ["_unit","_nearP"];

_unit = _this select 1;

if (isNil "VEMFForceCache") then {VEMFForceCache = [];};

if (!isNull _unit) then {
	if (_this select 1) then {
		//_nearP = ((getPosATL _unit) nearEntities [["Epoch_Male_F", "Epoch_Female_F"], 500]) select 0;
	
		// Disabled Until SetOwner is Fixed
		//if (isNil "_nearP" || isNull "_nearP") then {
			// Force AI Cache
			if (!(group _unit in VEMFForceCache)) then {
				VEMFForceCache = VEMFForceCache + [(group _unit)];
			};
		/* } else {
			// Set New Owner to Group
			{
				_x setOwner (owner _nearP);
			} forEach (units group _unit);
		}; */
	};
};