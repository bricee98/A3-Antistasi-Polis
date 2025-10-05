#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
params [
    ["_side", sideUnknown, [sideUnknown, grpNull, objNull, "", 0]]
];

private _sideKey = [_side] call A3A_fnc_sideToKey;

private _structure = createHashMap;
_structure set ["sideKey", _sideKey];
if (_side isEqualType sideUnknown) then {
    _structure set ["side", _side];
};
_structure set ["commander", objNull];
_structure set ["hqObjects", []];
_structure set ["hqPosition", [0,0,0]];
_structure set ["hqMarker", ""];
_structure set ["resources", 0];
_structure set ["hr", 0];
_structure set ["storage", createHashMap];
_structure set ["unlocks", createHashMap];
_structure set ["logisticsQueue", []];
_structure set ["metadata", createHashMap];

_structure
