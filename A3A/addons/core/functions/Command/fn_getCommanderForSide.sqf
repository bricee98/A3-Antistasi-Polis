/*
 * Author: ChatGPT
 *
 * Description:
 *  Returns the commander unit registered for the provided faction side.
 *
 * Arguments:
 * 0: Side identifier <ANY>
 *
 * Return Value:
 * <OBJECT> Commander unit or objNull.
 */
#include "..\..\script_component.hpp"
params ["_sideInput"];

private _structure = [_sideInput, false] call A3A_fnc_getCommandStructureForSide;
if (typeName _structure != "HASHMAP") exitWith { objNull };

_structure getOrDefault ["commander", objNull]
