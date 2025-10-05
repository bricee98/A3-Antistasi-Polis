#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
params [
    ["_side", teamPlayer, [sideUnknown, grpNull, objNull, "", 0]]
];

private _structure = [_side] call A3A_fnc_getCommandStructureForSide;
_structure getOrDefault ["commander", objNull]
