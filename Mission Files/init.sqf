if (!isDedicated) then {
	"VEMFChatMsg" addPublicVariableEventHandler {
		systemChat ((_this select 1) select 0);
		[
			[
				[((_this select 1) select 0),"color='#E50909' align='center' size='1' font='PuristaBold'"],
				["","<br/>"],
				[((_this select 1) select 1),"align='center' size='0.5'"]
			]
		] spawn BIS_fnc_typeText2;
		VEMFChatMsg = nil;
	};
	"VEMFWarnMessage" addPublicVariableEventHandler {
		[
			[
				[(_this select 1),"color='#E50909' align='center' size='0.3'"]
			]
		] spawn BIS_fnc_typeText2;
		VEMFWarnMessage = nil;
	};
};