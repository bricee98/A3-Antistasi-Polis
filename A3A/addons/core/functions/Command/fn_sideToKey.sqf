#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
params [
    ["_input", sideUnknown, [sideUnknown, grpNull, objNull, "", 0]]
];

private _side = _input;

switch (typeName _side) do {
    case "GROUP": {
        _side = if (isNull _side) then { sideUnknown } else { side _side };
    };
    case "OBJECT": {
        if (isNull _side) then {
            _side = sideUnknown;
        } else {
            _side = side group _side;
        };
    };
    case "SCALAR": {
        // Allow passing raw sideID values, mostly for debugging helpers.
        private _sideFromId = [west, east, independent, civilian, resistance] select {_x call BIS_fnc_sideID == _side};
        if (_sideFromId isNotEqualTo []) then {
            _side = _sideFromId#0;
        } else {
            // Unknown scalar, just stringise it.
            private _result = str _side;
            _result = toLower _result;
            _result = _result select [0, min [count _result, 64]];
            _result = [_result, "unknown"] select (_result isEqualTo "");
            return _result;
        };
    };
    case "STRING": {
        private _result = toLower _side;
        switch (_result) do {
            case "west": { _result = "west"; };
            case "blu": { _result = "west"; };
            case "blufor": { _result = "west"; };
            case "east": { _result = "east"; };
            case "opfor": { _result = "east"; };
            case "independent": { _result = "guer"; };
            case "indy": { _result = "guer"; };
            case "guer": { _result = "guer"; };
            case "resistance": { _result = "guer"; };
            case "civilian": { _result = "civ"; };
            case "civ": { _result = "civ"; };
            default {
                if (_result isEqualTo "") then { _result = "unknown"; };
            };
        };
        return _result;
    };
};

if (!(_side isEqualType sideUnknown)) exitWith {
    // Fallback for unsupported types.
    private _result = toLower str _side;
    if (_result isEqualTo "") then { _result = "unknown"; };
    _result
};

private _result = toLower str _side;
if (_result isEqualTo "independent") then { _result = "guer"; };
if (_result isEqualTo "resistance") then { _result = "guer"; };
if (_result isEqualTo "civilian") then { _result = "civ"; };
if (_result isEqualTo "") then { _result = "unknown"; };

_result
