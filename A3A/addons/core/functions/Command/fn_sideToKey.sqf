/*
Author: ChatGPT
Description:
    Converts various input types to the Antistasi faction key format.

Arguments:
0. <ANY> Supported types are SIDE, GROUP, OBJECT, STRING and SCALAR.

Return Value:
<STRING> Lowercase faction key (occ, inv, reb, civ, all) when recognised, otherwise an empty string.
*/
#include "..\..\script_component.hpp"
params ["_value"];

switch (typeName _value) do {
    case "SCALAR": {
        private _keys = ["occ", "inv", "reb", "civ", "all"];
        if (_value < 0 || {_value >= count _keys}) exitWith { "" };
        exitWith { _keys select _value };
    };
    case "STRING": {
        exitWith { toLower _value };
    };
    case "SIDE": {
        private _sideLookup = createHashMapFromArray [
            [teamPlayer, "reb"],
            [resistance, "reb"],
            [Occupants, "occ"],
            [west, "occ"],
            [Invaders, "inv"],
            [east, "inv"],
            [civilian, "civ"],
            [sideLogic, "logic"],
            [sideEnemy, "enemy"],
            [sideFriendly, "friendly"],
            [sideAmbientLife, "ambient"],
            [sideEmpty, "empty"],
            [sideUnknown, ""]
        ];
        exitWith { _sideLookup getOrDefault [_value, toLower str _value] };
    };
    case "GROUP": {
        if (isNull _value) exitWith { "" };
        exitWith { [side _value] call A3A_fnc_sideToKey };
    };
    case "OBJECT": {
        if (isNull _value) exitWith { "" };
        private _side = if (_value isKindOf "Man") then { side group _value } else { side _value };
        exitWith { [_side] call A3A_fnc_sideToKey };
    };
    default {
        exitWith { "" };
    };
};
""
