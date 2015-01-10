/*
	allowDamageFix by Face @ EpochMod.com
*/
if (!isNil "A3EAI_allowDamageFix_active") exitWith {};
A3EAI_allowDamageFix_active = true;

diag_log text format ["[VEMF]: AllowDamage Fix Running."];

while {true} do {
    private ["_playersModified"];
    _playersModified = {
        if ((_x getVariable ["noDamageAllowed",true]) && {!(_x isKindOf "VirtualMan_EPOCH")}) then {
            if (isPlayer _x) then {
                _x allowDamage true;
                _x setVariable ["noDamageAllowed",false];
				true
            } else {
				_x setVariable ["noDamageAllowed",false];
			};
        };
    } count playableUnits;
    if (_playersModified > 0) then {
		diag_log text format ["[VEMF]: AllowDamage Applied to %1 Units.", _playersModified];
	};
    uiSleep 10;
};