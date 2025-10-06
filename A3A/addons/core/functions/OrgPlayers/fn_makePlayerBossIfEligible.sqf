#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
params ["_player", ["_sideInput", teamPlayer]];

if (isNull _player) exitWith {
    Error("Attempted to promote a null player to commander");
    false
};

private _structure = [_sideInput, true] call A3A_fnc_getCommandStructureForSide;
if (typeName _structure != "HASHMAP") exitWith { false };

private _side = _structure getOrDefault ["side", _sideInput];
private _sideKey = _structure getOrDefault ["sideKey", [_sideInput] call A3A_fnc_sideToKey];

private _eligibilityVar = _structure getOrDefault ["commanderEligibilityVar", "eligible"];
private _defaultEligibility = if (_side isEqualTo teamPlayer) then { false } else { true };
private _isEligible = _player getVariable [_eligibilityVar, _player getVariable ["eligible", _defaultEligibility]];
if (!_isEligible) exitWith {
    Error(format ["Attempted commander transfer for %1 on %2 without eligibility", name _player, _sideKey]);
    false
};

// Only enforce guest restrictions for the rebel commander to maintain backwards compatibility.
if (_side isEqualTo teamPlayer) then {
    if (!A3A_guestCommander && !(_player call A3A_fnc_isMember)) exitWith {
        Error(format ["Attempted to transfer rebel command to guest player %1", name _player]);
        false
    };
};

private _realSide = side group _player;
if (!(_realSide isEqualTo _side)) exitWith {
    Error(format ["Attempted commander transfer for %1 on %2 but player is on %3", name _player, _sideKey, _realSide]);
    false
};

Info_2("Player %1 eligible for commander of %2", name _player, _sideKey);
[_sideInput, _player] call A3A_fnc_theBossTransfer;
true
