#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
params [
    ["_side", teamPlayer, [sideUnknown, grpNull, objNull, "", 0]]
];

private _structures = missionNamespace getVariable ["A3A_commandStructures", objNull];
if !(_structures isEqualType createHashMap) then {
    _structures = call A3A_fnc_initCommandStructures;
};

private _key = [_side] call A3A_fnc_sideToKey;
private _structure = _structures getOrDefault [_key, objNull];
if !(_structure isEqualType createHashMap) then {
    _structure = [_side] call A3A_fnc_createCommandStructure;
    _structures set [_key, _structure];
    missionNamespace setVariable ["A3A_commandStructures", _structures, true];
};

private _storage = _structure getOrDefault ["storage", createHashMap];
if !(_storage isEqualType createHashMap) then {
    _storage = createHashMap;
    _structure set ["storage", _storage];
    _structures set [_key, _structure];
    missionNamespace setVariable ["A3A_commandStructures", _structures, true];
};

[
    _structure getOrDefault ["hr", 0],
    _structure getOrDefault ["resources", 0],
    _storage
]
