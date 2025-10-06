/*
 * Author: ChatGPT
 *
 * Adds commander claim and abdicate actions to the provided HQ object.
 */
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params [
    ["_hqObject", objNull],
    ["_sideInput", teamPlayer],
    ["_label", ""]
];

if (isNull _hqObject) exitWith {};
if (!hasInterface) exitWith {};

private _structure = [_sideInput, false] call A3A_fnc_getCommandStructureForSide;
private _side = _structure getOrDefault ["side", _sideInput];
private _sideKey = _structure getOrDefault ["sideKey", [_sideInput] call A3A_fnc_sideToKey];

private _existingNames = (actionIDs _hqObject) apply { (_hqObject actionParams _x)#0 };

private _claimText = if (_label != "") then {
    format [localize "STR_A3A_commander_action_claim", _label]
} else {
    localize "STR_A3A_commander_action_claim_generic"
};

if !(_claimText in _existingNames) then {
    _hqObject addAction [
        _claimText,
        {
            params ["_target", "_caller", "_actionId", "_args"];
            _args params ["_side", "_label"];

            if (!isPlayer _caller) exitWith {};
            private _realCaller = _caller getVariable ["owner", _caller];
            if (isNull _realCaller) exitWith {};

            if (!(side group _realCaller isEqualTo _side)) exitWith {
                private _message = if (_label != "") then {
                    format [localize "STR_A3A_commander_action_wrong_side", _label]
                } else {
                    localize "STR_A3A_commander_action_wrong_side_generic"
                };
                [localize "STR_A3A_fn_orgp_tBTogEli_titel", _message] call A3A_fnc_customHint;
            };

            if !(_realCaller getVariable ["eligible", true]) exitWith {
                [localize "STR_A3A_fn_orgp_tBTogEli_titel", localize "STR_A3A_fn_orgp_tBTogEli_eligible_no"] call A3A_fnc_customHint;
            };

            [_realCaller, _side] remoteExecCall ["A3A_fnc_makePlayerBossIfEligible", 2];
        },
        [_side, _label],
        1.5,
        true,
        true,
        "",
        "isPlayer _this"
    ];
};

private _abdicateText = if (_label != "") then {
    format [localize "STR_A3A_commander_action_abdicate", _label]
} else {
    localize "STR_A3A_commander_action_abdicate_generic"
};

if !(_abdicateText in _existingNames) then {
    _hqObject addAction [
        _abdicateText,
        {
            params ["_target", "_caller", "_actionId", "_args"];
            _args params ["_side", "_label"];

            if (!isPlayer _caller) exitWith {};
            private _realCaller = _caller getVariable ["owner", _caller];
            if (isNull _realCaller) exitWith {};

            private _commander = [_side] call A3A_fnc_getCommanderForSide;
            if (_realCaller isNotEqualTo _commander) exitWith {
                [localize "STR_A3A_fn_orgp_tBTogEli_titel", localize "STR_A3A_commander_action_not_commander"] call A3A_fnc_customHint;
            };

            [_side, objNull] remoteExecCall ["A3A_fnc_theBossTransfer", 2];
        },
        [_side, _label],
        1.5,
        true,
        true,
        "",
        "isPlayer _this"
    ];
};

Debug(format ["Commander actions registered for %1 on %2 (%3)", _hqObject, _sideKey, typeOf _hqObject]);
