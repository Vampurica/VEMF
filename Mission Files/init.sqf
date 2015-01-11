"VEMFChatMsg" addPublicVariableEventHandler {
	systemChat (_this select 1);
	if (isClass(configFile >> "CfgSounds" >> "tune")) then {
		playSound ["tune",true];
	} else {
		playSound ["hint",true];
	};
	VEMFChatMsg = nil;
};
