class CfgPatches 
{
	class VEMF
	{
		units[] = {"C_man_1"};
		weapons[] = {};
		requiredAddons[] = {"A3_Data_F","A3_Soft_F","A3_Soft_F_Offroad_01","A3_Characters_F"};
		fileName = "VEMF.pbo";
		author[]= {"Vampire"}; 
	};
};
class CfgFunctions {
    class Mission1 {
        class main {
            file = "\VEMF";
            class init {
                postInit = 1;
            };
        };
    };
};
