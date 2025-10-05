#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
params [
    ["_side", teamPlayer, [sideUnknown, grpNull, objNull, "", 0]],
    ["_commander", objNull, [objNull]]
];

if (!isServer) exitWith {
    [_side, _commander] remoteExecCall ["A3A_fnc_setCommanderForSide", 2];
};

private _structures = missionNamespace getVariable ["A3A_commandStructures", objNull];
if !(_structures isEqualType createHashMap) then {
    _structures = call A3A_fnc_initCommandStructures;
};

private _key = [_side] call A3A_fnc_sideToKey;
private _structure = _structures getOrDefault [_key, objNull];
if !(_structure isEqualType createHashMap) then {
    _structure = [_side] call A3A_fnc_createCommandStructure;
};

_structure set ["commander", _commander];
if (_side isEqualType sideUnknown) then {
    _structure set ["side", _side];
};
_structure set ["sideKey", _key];

_structures set [_key, _structure];
missionNamespace setVariable ["A3A_commandStructures", _structures, true];
