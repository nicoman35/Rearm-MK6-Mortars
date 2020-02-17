class CfgPatches {
	class NIC_MK6_mortar {
		units[]				= {};
		weapons[]= {};
		requiredVersion		= 1;
		requiredAddons[]	= {};
		magazines[]= {};
	};
};
class CfgFunctions {
	class NIC {
		class base {
			class InitRearmMK6 {
				preInit = 1;
				file	= "\NIC_rearm_MK6\scripts\init.sqf";
			};
		};
	};
};
class Extended_PreInit_EventHandlers {
	class NIC_MK6_mortar {
		init = "call compile preprocessFileLineNumbers '\NIC_rearm_MK6\scripts\XEH_preInit.sqf'"; // CBA_a3 integration
	};
};
class Extended_GetIn_Eventhandlers {
    class Mortar_01_base_F {
		getin = "_this execVM '\NIC_rearm_MK6\scripts\getin.sqf'";
    };
};
