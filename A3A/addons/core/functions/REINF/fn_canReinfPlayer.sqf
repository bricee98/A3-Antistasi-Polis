params ["_typeUnit"];

if !([player] call A3A_fnc_isMember) exitWith {localize "STR_A3A_fn_reinf_reinfPlayer_no_member"};

if (recruitCooldown > time) exitWith {format [localize "STR_A3A_fn_reinf_reinfPlayer_no_wait",round (recruitCooldown - time)]};

if (player != player getVariable ["owner",player]) exitWith {localize "STR_A3A_fn_reinf_reinfPlayer_no_controlling"};

if ([getPosATL player] call A3A_fnc_enemyNearCheck) exitWith {localize "STR_A3A_fn_reinf_reinfPlayer_no_enemy"};

if (player != leader group player) exitWith {localize "STR_A3A_fn_reinf_reinfPlayer_no_lead"};

if ((count units group player) + (count units stragglers) > 9) exitWith {localize "STR_A3A_fn_reinf_reinfPlayer_no_full"};

private _hasWeapons = [_typeUnit] call A3A_fnc_hasWeapons;
if !(_hasWeapons) exitWith {localize "STR_A3A_fn_reinf_reinfPlayer_no_weapons"};

private _economy = [teamPlayer, true] call A3A_fnc_getEconomyForSide;
private _hr = _economy getOrDefault ["hr", 0];
if (_hr < 1) exitWith {localize "STR_A3A_fn_reinf_reinfPlayer_no_hr"};

private _costs = server getVariable _typeUnit;
private _resources = _economy getOrDefault ["resources", 0];
if (_costs > _resources) exitWith {format [localize "STR_A3A_fn_reinf_reinfPlayer_no_money",_costs]};

"";