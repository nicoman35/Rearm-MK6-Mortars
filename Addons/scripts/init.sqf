NIC_fn_ACTION_REARM_ON = {
	params ["_mortarMK6"];
	if !(isNil{_mortarMK6 getVariable "NIC_actionID_rearm_MK6"}) exitWith {};
	private _actionID_MK = _mortarMK6 addAction [									// Add 'Rearm Mortar' action to mortar gunners
		localize "STR_NIC_MK6_TITLE",												// Title
		{_this call NIC_fn_Rearm_MK6;},												// Script
		nil,																		// Arguments
		0,																			// Priority
		false,																		// showWindow
		true,																		// hideOnUse
		"",																			// Shortcut
		"gunner _target == _this"													// Condition, action menu only available for gunners of mortars
	];
	_mortarMK6 setVariable ["NIC_actionID_rearm_MK6", _actionID_MK, false];
	// diag_log formatText ["%1%2%3%4%5", time, "s  (NIC_fn_Rearm_MK6_ON) _this: ", _this, ", _mortarMK6: ", _mortarMK6];
};
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

NIC_fn_ACTION_REARM_OFF = {								// Remove gunner action 
	params ["_mortarMK6"];
	if (isNil{_mortarMK6 getVariable "NIC_actionID_rearm_MK6"}) exitWith {};
	private _actionID_MK = _mortarMK6 getVariable "NIC_actionID_rearm_MK6";
	_mortarMK6 removeAction _actionID_MK;
	_mortarMK6 setVariable ["NIC_actionID_rearm_MK6", nil, false];
	// diag_log formatText ["%1%2%3%4%5", time, "s  (NIC_fn_Rearm_MK6_OFF) _this: ", _this, ", _mortarMK6: ", _mortarMK6];
};
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

NIC_fn_Rearm_MK6 = {
	params ["_mortarMK6"];
	// diag_log formatText ["%1%2%3%4%5", time, "s  (NIC_fn_Rearm_MK6) _mortarMK6: ", _mortarMK6, ", _this: ", _this];
	if !(NIC_MK6_REARM_ALLOWED) exitWith {[_mortarMK6] call NIC_fn_ACTION_REARM_OFF};
	private _weapArray = [];
	{
		private _cfgTurret = _x;
		{
			_weapArray pushBack [getArray (_cfgTurret >> "magazines")]
		} forEach (getArray (_cfgTurret >> "weapons"));	
    } forEach ([_mortarMK6] call BIS_fnc_getTurrets);
	_weapArray = _weapArray select 1 select 0;
	private _defaultHEmags = {_x == "8Rnd_82mm_Mo_shells"} count _weapArray;
	private _defaultIllumMags = {_x == "8Rnd_82mm_Mo_Flare_white"} count _weapArray;
	private _defaultSmokeMags = {_x == "8Rnd_82mm_Mo_Smoke_white"} count _weapArray;
	private _defaultHEammo		= _defaultHEmags * 8;													// default HE ammo count of MK 6 (8 rounds per magazine)
	private _defaultIllumAmmo 	= _defaultIllumMags * 8;												// default Flare ammo count of MK 6 (8 rounds per magazine)
	private _defaultSmokeAmmo 	= _defaultSmokeMags * 8;												// default Smoke ammo count of MK 6 (8 rounds per magazine)
	// diag_log formatText ["%1%2%3%4%5%6%7", time, "s  (NIC_fn_Rearm_MK6) _defaultHEammo: ", _defaultHEammo, ", _defaultIllumAmmo: ", _defaultIllumAmmo, ", _defaultSmokeAmmo: ", _defaultSmokeAmmo];
	private _mortarHEammoCount = 0;
	private _mortarIllumAmmoCount = 0;
	private _mortarSmokeAmmoCount = 0;
	private _allMagazines = magazinesAmmoFull _mortarMK6;												// get current magazines detailed info of mortar
	// diag_log formatText ["%1%2%3%4%5%6%7", time, "s  (NIC_fn_Rearm_MK6) _allMagazines: ", _allMagazines];
	{
		if (_x select 0 == "8Rnd_82mm_Mo_shells") then {												// current magazine is a HE magazine type
			_mortarHEammoCount = _mortarHEammoCount + (_x select 1);									// add current HE magazine count to mortar HE ammo count
		};
		if (_x select 0 == "8Rnd_82mm_Mo_Flare_white") then {											// current magazine is a HE magazine type
			_mortarIllumAmmoCount = _mortarIllumAmmoCount + (_x select 1);								// add current flare magazine count to mortar flare ammo count
		};
		if (_x select 0 == "8Rnd_82mm_Mo_Smoke_white") then {											// current magazine is a HE magazine type
			_mortarSmokeAmmoCount = _mortarSmokeAmmoCount + (_x select 1);								// add current smoke magazine count to mortar smoke ammo count
		};
	} forEach _allMagazines;
	// diag_log formatText ["%1%2%3%4%5%6%7", time, "s  (NIC_fn_Rearm_MK6) mortar HE ammo: ", _mortarHEammoCount, ", Illum ammo: ", _mortarIllumAmmoCount, ", Smoke ammo: ", _mortarSmokeAmmoCount];
	
	private _wantedHEammo = _defaultHEammo - _mortarHEammoCount;
	private _wantedIllumAmmo = _defaultIllumAmmo - _mortarIllumAmmoCount;
	private _wantedSmokeAmmo = _defaultSmokeAmmo - _mortarSmokeAmmoCount;
	if (_wantedHEammo == 0 && _wantedIllumAmmo == 0 && _wantedSmokeAmmo == 0) exitWith {				// leave routine, if no ammo is needed
		if (gunner _mortarMK6 == player) then {	hint format[localize "STR_NIC_MK6_NO_AMMO_NEEDED"]} 
		else {_mortarMK6 groupChat format[localize "STR_NIC_MK6_NO_AMMO_NEEDED"]};
	};
	// diag_log formatText ["%1%2%3%4%5%6%7", time, "s  (NIC_fn_Rearm_MK6) _wantedHEammo: ", _wantedHEammo, ", _wantedIllumAmmo: ", _wantedIllumAmmo, ", _wantedSmokeAmmo: ", _wantedSmokeAmmo];

	if !(isNil{FOB_typename}) then {
		if (NIC_MK6_REARM_SOURCES find FOB_typename < 0) then {NIC_MK6_REARM_SOURCES pushBack FOB_typename}; // if KP Liberation is played, add FOB type name to resupply sources
	};
	private _ammoSources = (_mortarMK6 nearObjects (round NIC_MK6_REARM_SEARCH_RANGE)) select {(typeof _x) in NIC_MK6_REARM_SOURCES};  // Search for all available ammo crates within given range
	// diag_log formatText ["%1%2%3%4%5%6%7", time, "s  (NIC_fn_Rearm_MK6) _ammoSources: ", _ammoSources, ", NIC_MK6_REARM_SOURCES: ", NIC_MK6_REARM_SOURCES, ", FOB_typename: ", FOB_typename];
	
	if (count _ammoSources > 0) exitWith {																// if some ammo source is in range, rearm mortar from this source, leaving the routine
		_ammoSources = _ammoSources apply {[_x distance _mortarMK6, _x]};
		_ammoSources sort true;
		private _TotalRearmTime = ceil (((_wantedHEammo + _wantedIllumAmmo + _wantedSmokeAmmo) * ceil(_mortarMK6 distance (_ammoSources select 0 select 1)) * NIC_MK6_REARM_TIME_PER_ROUND_AND_METER) / 2);		
		// diag_log formatText ["%1%2%3%4%5%6%7%8%9", time, "s  (NIC_fn_Rearm_MK6) _TotalRearmTime: ", _TotalRearmTime, ", dist to ammo source: ", ceil(_ammoSources select 0 select 0), " m, source: ", _ammoSources select 0 select 1, ", search range: ", round NIC_MK6_REARM_SEARCH_RANGE];
		[_mortarMK6, _TotalRearmTime] call NIC_fn_Rearmed_MK6_message;
		private _defAmmoArray = [["8Rnd_82mm_Mo_shells", _defaultHEmags], ["8Rnd_82mm_Mo_Flare_white", _defaultIllumMags], ["8Rnd_82mm_Mo_Smoke_white", _defaultSmokeMags]];
		{
			_mortarMK6 removeMagazinesTurret [_x select 0,[0]];
			for "_i" from 1 to (_x select 1) do { 
				_mortarMK6 addMagazineTurret [_x select 0,[0]];
				// diag_log formatText ["%1%2%3%4%5%6%7%8%9", time, "s  (NIC_fn_Rearm_MK6) added ", _x select 0];
			};
		} forEach (_defAmmoArray);
		if (gunner _mortarMK6 == player) then {hint format[localize "STR_NIC_MK6_MORTAR_REARMED"]} 
		else {_mortarMK6 groupChat format[localize "STR_NIC_MK6_MORTAR_REARMED"]};
	}; 

	private _crates = (_mortarMK6 nearObjects (round NIC_MK6_REARM_SEARCH_RANGE)) select {(typeof _x) in NIC_MK6_ACE_CRATES};  // Search for all available ammo crates within given range
	if (count _crates == 0) exitWith {																	// leave routine, if no ammo crates are in range
		if (gunner _mortarMK6 == player) then {	hint format[localize "STR_NIC_MK6_NO_AMMO_CRATES"]} 
		else {_mortarMK6 groupChat format[localize "STR_NIC_MK6_NO_AMMO_CRATES"]};
	}; 
	// diag_log formatText ["%1%2%3%4%5", time, "s  (NIC_fn_Rearm_MK6) _crates: ", _crates, ", search range: ", NIC_MK6_REARM_SEARCH_RANGE];
	
	private _wantedAmmoTypes = [];																		// array for mortars needed ammo types
	private _wantedAmmoCounts = [];																		// array for mortars needed ammo counts
	if (_wantedHEammo > 0) then {
		_wantedAmmoTypes pushBack "ACE_1Rnd_82mm_Mo_HE";												// add HE ammo type to wanted types array
		_wantedAmmoCounts pushBack _wantedHEammo;														// add HE ammo count to ammo counts array
	};
	if (_wantedIllumAmmo > 0) then {
		_wantedAmmoTypes pushBack "ACE_1Rnd_82mm_Mo_Illum";												// add flare ammo type to wanted types array
		_wantedAmmoCounts pushBack _wantedIllumAmmo;													// add flare ammo count to ammo counts array
	};	
	if (_wantedSmokeAmmo > 0) then {	
		_wantedAmmoTypes pushBack "ACE_1Rnd_82mm_Mo_Smoke";												// add flare smoke type to wanted types array
		_wantedAmmoCounts pushBack _wantedSmokeAmmo;													// add flare smoke count to ammo counts array
	};
	private _wantedAmmoCountsMemory = +_wantedAmmoCounts;												// clone wanted ammo counts array for later comparison with the reloaded counts array
	// diag_log formatText ["%1%2%3%4%5", time, "s  (NIC_fn_Rearm_MK6) _wantedAmmoTypes: ", _wantedAmmoTypes, ", _wantedAmmoCounts: ", _wantedAmmoCounts];
	
	// search crates for wanted ammo
	private _TotalRearmTime = 0;
	private _rearmAmmoTypes = [];																		// array of found ammo types for rearming the mortar 
	private _rearmAmmoCounts = [];																		// array of found ammo counts for rearming the mortar
	{
		private _rearmTime = 0;																			// time cycles rearm will take
		private _crate = _x;
		private _crateAmmo = magazinesAmmo _crate;														// get array of magazines from crate
		private _RearmTimePerRoundAndMeter = ceil(_mortarMK6 distance _crate) * NIC_MK6_REARM_TIME_PER_ROUND_AND_METER;											// get distance in meters from crate to morar
		// diag_log formatText ["%1%2%3%4%5%6%7", time, "s  (NIC_fn_Rearm_MK6) _RearmTimePerRoundAndMeter: ", _RearmTimePerRoundAndMeter];
		{	
			private _wantedAmmoCount = _wantedAmmoCounts select _forEachIndex;							// get count of wanted ammo type
			// diag_log formatText ["%1%2%3%4%5%6%7", time, "s  (NIC_fn_Rearm_MK6) _x: ", _x, ", _wantedAmmoCount: ", _wantedAmmoCount];
			if (_wantedAmmoCount > 0) then {
				private _wantedAmmoType = _x;															// get wanted ammo type name
				private _crateAmmoCount = {_x select 0 == _wantedAmmoType} count _CrateAmmo;			// get amount of wanted ammo type inside crate
				if (_crateAmmoCount > 0) then {															// crate has ammo of wanted type
					private _taking = 0;																// amount of taken ammo from crate
					if (_wantedAmmoCount >= _crateAmmoCount) then {										// if wanted ammo count is higher or equal to crate amount
						_taking = _crateAmmoCount;														// taken amount equals crate amount
					};
					if (_wantedAmmoCount < _crateAmmoCount) then {										// if wanted ammo count is lower then crate amount
						_taking = _wantedAmmoCount;														// taken amount equals wanted amount
					};
					// diag_log formatText ["%1%2%3%4%5%6%7", time, "s  (NIC_fn_Rearm_MK6) _crateAmmoCount: ", _crateAmmoCount, ", _taking: ", _taking];
					_wantedAmmoCounts set [_forEachIndex, (_wantedAmmoCount - _taking)];
					_rearmTime = _rearmTime + (_taking * _RearmTimePerRoundAndMeter);													// raise rearm time interval
					for "_i" from 1 to _taking do {  													// delete taken magazines from crate array
						private _index = _crateAmmo find [_wantedAmmoType, 1];
						if (_index == -1) exitwith {};
						_crateAmmo deleteAt _index;
					};
					private _index = _rearmAmmoTypes find _wantedAmmoType;								// get index of ammo type in rearm array
					if (_index < 0) then {																// if ammo type was not found, create new element
						_rearmAmmoTypes pushBack _wantedAmmoType;
						_rearmAmmoCounts pushBack _taking;
					} else {																			// if ammo type was found, update rearm count
						_rearmAmmoCounts set [_index, (_rearmAmmoCounts select _index) + _taking];
					};
				};
			};
		} forEach (_wantedAmmoTypes);
		// diag_log formatText ["%1%2%3%4%5%6%7", time, "s  (NIC_fn_Rearm_MK6) _rearmAmmoTypes: ", _rearmAmmoTypes, ", _rearmAmmoCounts: ", _rearmAmmoCounts, ", _TotalRearmTime: ", _TotalRearmTime];

		if (_rearmTime > 0) then {
			_TotalRearmTime = _TotalRearmTime + _rearmTime;
			clearMagazineCargoGlobal _crate;															// delete all magazines from crate
			{
				_crate addItemCargoGlobal [_x select 0, 1];												// refill the crate with updated magazine array
			} forEach (_crateAmmo);
		};
	} forEach (_crates);
	
	if (_TotalRearmTime == 0) exitWith {																// if no wanted ammo was found, leave with suitable message
		private _str_crate = format[localize "STR_NIC_MK6_CRATE"];
		if (count _crates > 1) then {_str_crate = format[localize "STR_NIC_MK6_CRATES"]};
		if (gunner _mortarMK6 == player) then {hint format[localize "STR_NIC_MK6_NO_SUITABLE_AMMO", _str_crate]} 
		else {_mortarMK6 groupChat format[localize "STR_NIC_MK6_NO_SUITABLE_AMMO", _str_crate]};
	};
	_TotalRearmTime = ceil _TotalRearmTime;
	// diag_log formatText ["%1%2%3%4%5%6%7", time, "s  (NIC_fn_Rearm_MK6) _TotalRearmTime: ", _TotalRearmTime];

	[_mortarMK6, _TotalRearmTime] call NIC_fn_Rearmed_MK6_message;

	{
		private _rearmMagazineType = "8Rnd_82mm_Mo_shells";												// define reload magazine type
		private _rearmAmmoCount = (_rearmAmmoCounts select _forEachIndex) + _mortarHEammoCount;			// total reload ammo count is count of ammo inside mortar plus the rearm ammo count
		switch (_x) do {
			case "ACE_1Rnd_82mm_Mo_Illum": {
				_rearmMagazineType = "8Rnd_82mm_Mo_Flare_white";
				_rearmAmmoCount = (_rearmAmmoCounts select _forEachIndex) + _mortarIllumAmmoCount;
			};
			case "ACE_1Rnd_82mm_Mo_Smoke": {
				_rearmMagazineType = "8Rnd_82mm_Mo_Smoke_white";
				_rearmAmmoCount = (_rearmAmmoCounts select _forEachIndex) + _mortarSmokeAmmoCount;
			};
		};
		private _fullMagazinesCount = floor (_rearmAmmoCount / 8);
		private _reducedMagazineCount = _rearmAmmoCount mod 8;
		// diag_log formatText ["%1%2%3%4%5%6%7%8%9", time, "s  (NIC_fn_Rearm_MK6) _rearmMagazineType: ", _rearmMagazineType, ", _rearmAmmoCount: ", _rearmAmmoCount, ", _fullMagazinesCount: ", _fullMagazinesCount, ", _reducedMagazineCount: ", _reducedMagazineCount];
		_mortarMK6 removeMagazinesTurret [_rearmMagazineType,[0]];
		for "_i" from 1 to _fullMagazinesCount do { 
			_mortarMK6 addMagazineTurret [_rearmMagazineType,[0]];
			// diag_log formatText ["%1%2%3%4%5%6%7%8%9", time, "s  (NIC_fn_Rearm_MK6) added full ", _rearmMagazineType];
		};
		if (_reducedMagazineCount > 0) then {															// for the mortar to be able to load magazines less than 8 rounds, we need to change the main mortar weapon
			_mortarMK6 addMagazineTurret [_rearmMagazineType,[0],_reducedMagazineCount];
			// diag_log formatText ["%1%2%3%4%5%6%7%8%9", time, "s  (NIC_fn_Rearm_MK6) added reduced ", _rearmMagazineType, " (", _reducedMagazineCount, ")"];
		};
	} forEach (_rearmAmmoTypes);		
	if (_wantedAmmoCountsMemory isEqualTo _rearmAmmoCounts) then {
		if (gunner _mortarMK6 == player) then {hint format[localize "STR_NIC_MK6_MORTAR_REARMED"]} 
		else {_mortarMK6 groupChat format[localize "STR_NIC_MK6_MORTAR_REARMED"]};
	} else {
		if (gunner _mortarMK6 == player) then {hint format[localize "STR_NIC_MK6_MORTAR_PAR_REARMED"]} 
		else {_mortarMK6 groupChat format[localize "STR_NIC_MK6_MORTAR_PAR_REARMED"]};
	};
};
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

NIC_fn_Rearmed_MK6_message = {					// rearm mortar message
	params ["_mortarMK6", "_TotalRearmTime"];
	// _TotalRearmTime = _TotalRearmTime + 1;
	if (gunner _mortarMK6 == player) then {
		private _str = format[localize "STR_NIC_MK6_REARMING"];
		for "_i" from _TotalRearmTime to 0 step -1 do {
			if (gunner _mortarMK6 == player) then {hint formatText ["%1%2%3%4", _str, "  ", _i, " s"]};
			sleep 1;
		};
	} else {
		_mortarMK6 groupChat format[localize "STR_NIC_MK6_REARMING"];
		sleep _TotalRearmTime;
	};
};
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	
if (isNil{NIC_MK6_REARM_ALLOWED}) then {NIC_MK6_REARM_ALLOWED = true};									// on/off switch for rearm mortars
if (isNil{NIC_MK6_REARM_SEARCH_RANGE}) then {NIC_MK6_REARM_SEARCH_RANGE = 5};							// search range for ammo crates in meters around mortar
if (isNil{NIC_MK6_REARM_TIME_PER_ROUND_AND_METER}) then {NIC_MK6_REARM_TIME_PER_ROUND_AND_METER = 0.1};	// rearm time per round and meter distance from mortar to ammo source
// diag_log formatText ["%1%2%3%4%5", time, "s  (init MK6) NIC_MK6_REARM_ALLOWED: ", NIC_MK6_REARM_ALLOWED, ", NIC_MK6_REARM_SEARCH_RANGE: ", NIC_MK6_REARM_SEARCH_RANGE];

NIC_MK6_REARM_SOURCES = [																				// sources of infinite ammo resupply for mortars
	"B_Slingload_01_Ammo_F",
	"B_Truck_01_ammo_F",
	"B_T_Truck_01_ammo_F",
	"O_Truck_02_Ammo_F",
	"O_Truck_03_ammo_F",
	"O_T_Truck_03_ammo_ghex_F",
	"O_T_Truck_02_Ammo_F",
	"I_Truck_02_ammo_F",
	"I_E_Truck_02_Ammo_F"
];

NIC_MK6_ACE_CRATES = [																					// sources of ammo for mortars; 
	"ACE_Box_82mm_Mo_HE",
	"ACE_Box_82mm_Mo_Illum",
	"ACE_Box_82mm_Mo_Smoke",
	"ACE_Box_82mm_Mo_Combo"
];

["StaticMortar", "init", {_this call NIC_fn_ACTION_REARM_ON}, true] call CBA_fnc_addClassEventHandler;	// adds init event to all static mortars; has to be run preinit!