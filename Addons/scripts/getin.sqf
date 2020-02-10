if (!isNull player && player == player && time > 1) then {
	if (NIC_MK6_REARM_ALLOWED) then {[_this select 0] call NIC_fn_ACTION_REARM_ON}
	else {[_this select 0] call NIC_fn_ACTION_REARM_OFF};
};