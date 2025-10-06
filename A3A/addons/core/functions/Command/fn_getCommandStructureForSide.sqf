/*
 * Author: ChatGPT
 *
 * Description:
 *  Retrieves the command structure entry for the provided side. Optionally creates
 *  a default entry if one does not exist.
 *
 * Arguments:
 * 0: Side identifier <ANY> (SIDE, STRING, OBJECT, GROUP, SCALAR)
 * 1: Create if missing <BOOL> (default: false)
 *
 * Return Value:
 * <HASHMAP> Command structure hash map. Returns an empty hash map if none is available
 *           and creation is disabled.
 */
#include "..\..\script_component.hpp"
params ["_sideInput", ["_createIfMissing", false]];

private _structures = missionNamespace getVariable ["A3A_commandStructures", createHashMap];
private _sideKey = [_sideInput] call A3A_fnc_sideToKey;
if (_sideKey isEqualTo "") then {
    _sideKey = toLower str _sideInput;
};

private _structure = _structures get _sideKey;
if (isNil "_structure" && {_createIfMissing}) then {
    _structure = [_sideInput] call A3A_fnc_defaultCommandStructure;
    _structures set [_sideKey, _structure];
    missionNamespace setVariable ["A3A_commandStructures", _structures];
    if (isMultiplayer) then { publicVariable "A3A_commandStructures"; };
};

if (isNil "_structure") then {
    _structure = createHashMap;
};

_structure
