#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

private _existing = missionNamespace getVariable ["A3A_commandStructures", objNull];
if (_existing isEqualType createHashMap) exitWith { _existing };

private _structures = createHashMap;

private _defaultSides = [
    teamPlayer,
    Occupants,
    Invaders,
    west,
    east,
    independent,
    resistance,
    civilian,
    sideUnknown
];

{
    private _key = [_x] call A3A_fnc_sideToKey;
    if (!(_structures getOrDefault [_key, objNull] isEqualType createHashMap)) then {
        _structures set [_key, [_x] call A3A_fnc_createCommandStructure];
    };
} forEach _defaultSides;

missionNamespace setVariable ["A3A_commandStructures", _structures, true];

_structures
