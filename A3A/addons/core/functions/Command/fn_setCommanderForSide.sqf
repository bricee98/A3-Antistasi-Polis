/*
 * Author: ChatGPT
 *
 * Description:
 *  Registers a commander for the provided side and synchronises the change.
 *
 * Arguments:
 * 0: Side identifier <ANY>
 * 1: Commander <OBJECT> (objNull to clear)
 * 2: Propagate to clients <BOOL> (default: true)
 *
 * Return Value:
 * <BOOL> True when the change was applied.
 */
#include "..\..\script_component.hpp"
params ["_sideInput", "_commander", ["_propagate", true]];

if (!isNull _commander && {!alive _commander}) then {
    Warning("Attempted to assign a dead commander, clearing slot instead");
    _commander = objNull;
};

private _structure = [_sideInput, true] call A3A_fnc_getCommandStructureForSide;
if (typeName _structure != "HASHMAP") exitWith { false };

private _currentCommander = _structure getOrDefault ["commander", objNull];
if (_currentCommander isEqualTo _commander) exitWith { true };

_structure set ["commander", _commander];
[_sideInput, _structure, _propagate] call A3A_fnc_setCommandStructureForSide
