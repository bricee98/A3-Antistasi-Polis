/*
 * Author: ChatGPT
 *
 * Description:
 *  Applies resource and HR deltas to the specified side economy and synchronises
 *  the result with clients. This helper keeps backwards compatibility with the
 *  legacy FIA variables when operating on the rebel side.
 *
 * Arguments:
 * 0: Side identifier <ANY>
 * 1: Resource delta <NUMBER> (default: 0)
 * 2: HR delta <NUMBER> (default: 0)
 * 3: Propagate <BOOL> (default: true)
 *
 * Return Value:
 * <ARRAY> [resources, hr]
 */
#include "..\..\script_component.hpp"
params ["_sideInput", ["_resourceDelta", 0], ["_hrDelta", 0], ["_propagate", true]];

private _structure = [_sideInput, true] call A3A_fnc_getCommandStructureForSide;
if (typeName _structure != "HASHMAP") exitWith { [0, 0] };

private _economy = [_sideInput, true] call A3A_fnc_getEconomyForSide;

private _resources = (_economy getOrDefault ["resources", 0]) + _resourceDelta;
private _hr = (_economy getOrDefault ["hr", 0]) + _hrDelta;
_resources = round (_resources max 0);
_hr = round (_hr max 0);

_economy set ["resources", _resources];
_economy set ["hr", _hr];
_structure set ["economy", _economy];
[_sideInput, _structure, _propagate] call A3A_fnc_setCommandStructureForSide;

private _sideKey = [_sideInput] call A3A_fnc_sideToKey;
if !(_sideKey isEqualTo "") then {
    private _resVar = format ["A3A_resources_%1", _sideKey];
    private _hrVar = format ["A3A_hr_%1", _sideKey];
    missionNamespace setVariable [_resVar, _resources];
    missionNamespace setVariable [_hrVar, _hr];
    if (_propagate && {isMultiplayer}) then {
        publicVariable _resVar;
        publicVariable _hrVar;
    };
};

if (_sideKey isEqualTo "reb") then {
    server setVariable ["resourcesFIA", _resources, _propagate];
    server setVariable ["hr", _hr, _propagate];
};

[_resources, _hr]
