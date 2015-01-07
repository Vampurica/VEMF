/*
	File: initServer.sqf
	
	Description:
	Starts the Initialization of the VEMF Server code.
*/
if (isServer) then {
	[] ExecVM "\VEMF\init.sqf";
};