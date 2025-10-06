/*
 * Author: ChatGPT
 *
 * Description:
 *  Stores a command structure hash map for the provided side key and optionally
 *  broadcasts the update to connected clients.
 *
 * Arguments:
 * 0: Side identifier <ANY>
 * 1: Command structure <HASHMAP>
 * 2: Propagate to clients <BOOL> (default: true)
 *
 * Return Value:
 * <BOOL> True when the update is accepted.
 */
#include "..\..\script_component.hpp"
params ["_sideInput", "_structure", ["_propagate", true]];

if !(typeName _structure isEqualTo "HASHMAP") exitWith {
    Error("Attempted to store a command structure with invalid type");
    false
};

private _structures = missionNamespace getVariable ["A3A_commandStructures", createHashMap];
private _sideKey = [_sideInput] call A3A_fnc_sideToKey;
if (_sideKey isEqualTo "") then {
    _sideKey = toLower str _sideInput;
};

_structure set ["lastUpdated", diag_tickTime];
_structures set [_sideKey, _structure];
missionNamespace setVariable ["A3A_commandStructures", _structures];

if (_propagate && {isMultiplayer}) then {
    publicVariable "A3A_commandStructures";
};

true
