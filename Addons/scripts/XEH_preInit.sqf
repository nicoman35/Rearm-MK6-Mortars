[
	"NIC_MK6_REARM_ALLOWED", 																		// internal setting name, should always contain a tag! This will be the global variable which takes the value of the setting.
    "CHECKBOX",																						// setting type
	[format[localize "STR_NIC_MK6_REARM_STATIC"], format[localize "STR_NIC_MK6_REARM_STATIC_TIP"]],	// [setting name, tooltip]
	format[localize "STR_NIC_MK6_TITLE"], 															// pretty name of the category where the setting can be found. Can be stringtable entry.
	true,																							// data for this setting: [min, max, default, number of shown trailing decimals]
    true																							// "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
	// {
		// if (NIC_MK6_REARM_ALLOWED) exitWith {_this call NIC_fn_ACTION_REARM_ON};
		// _this call NIC_fn_ACTION_REARM_OFF;
	// }																							// code executed on setting change
] call CBA_fnc_addSetting;

[
	"NIC_MK6_REARM_SEARCH_RANGE",																	// internal setting name, should always contain a tag! This will be the global variable which takes the value of the setting.
	"SLIDER",   																					// setting type
	[format[localize "STR_NIC_MK6_SEARCH_RANGE"], format[localize "STR_NIC_MK6_SEARCH_RANGE_TIP"]], // [setting name, tooltip]
	format[localize "STR_NIC_MK6_TITLE"], 															// pretty name of the category where the setting can be found. Can be stringtable entry.
	[2, 25, 5, 0]																					// [_min, _max, _default, _trailingDecimals]
] call CBA_fnc_addSetting;

[
	"NIC_MK6_REARM_TIME_PER_ROUND_AND_METER",														// internal setting name, should always contain a tag! This will be the global variable which takes the value of the setting.
	"SLIDER",   																					// setting type
	[format[localize "STR_NIC_MK6_TIME_PER"], format[localize "STR_NIC_MK6_TIME_PER_TIP"]],			// [setting name, tooltip]
	format[localize "STR_NIC_MK6_TITLE"], 															// pretty name of the category where the setting can be found. Can be stringtable entry.
	[0.01, 1, 0.1, 2]																				// [_min, _max, _default, _trailingDecimals]
] call CBA_fnc_addSetting;