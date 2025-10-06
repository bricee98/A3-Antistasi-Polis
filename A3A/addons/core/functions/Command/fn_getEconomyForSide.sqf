/*
 * Author: ChatGPT
 *
 * Description:
 *  Returns the economy hash map associated with the provided side. The hash map
 *  contains the keys "resources", "hr" and "storage".
 *
 * Arguments:
 * 0: Side identifier <ANY>
 * 1: Create structure if missing <BOOL> (default: true)
 *
 * Return Value:
 * <HASHMAP> Economy data hash map.
 */
#include "..\..\script_component.hpp"
params ["_sideInput", ["_createIfMissing", true]];

private _structure = [_sideInput, _createIfMissing] call A3A_fnc_getCommandStructureForSide;
if (typeName _structure != "HASHMAP") exitWith { createHashMap };

private _economy = _structure get "economy";
if (isNil "_economy") then {
    _economy = createHashMapFromArray [["resources", 0], ["hr", 0], ["storage", createHashMap]];
    _structure set ["economy", _economy];
    [_sideInput, _structure, false] call A3A_fnc_setCommandStructureForSide;
};

if (typeName _economy != "HASHMAP") then {
    _economy = createHashMapFromArray [["resources", 0], ["hr", 0], ["storage", createHashMap]];
    _structure set ["economy", _economy];
    [_sideInput, _structure, false] call A3A_fnc_setCommandStructureForSide;
};

_economy
