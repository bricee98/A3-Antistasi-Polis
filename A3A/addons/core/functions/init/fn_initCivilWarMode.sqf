#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

/*
 * Author: ChatGPT
 * Initialises the shared state required for the Civil War PvP mode.
 */

params ["_saveData", ["_startType", "new"]];

Info("Initialising Civil War mode");

private _initialResources = missionNamespace getVariable ["initialFactionMoney", 0];
private _initialHr = missionNamespace getVariable ["initialHr", 0];
private _applyBaseline = toLower _startType == "new";

{
    private _side = _x#0;
    private _label = _x#1;
    private _structure = [_side, true] call A3A_fnc_getCommandStructureForSide;
    private _economy = _structure getOrDefault ["economy", createHashMapFromArray [["resources", 0], ["hr", 0], ["storage", createHashMap]]];

    private _currentResources = _economy getOrDefault ["resources", 0];
    private _currentHr = _economy getOrDefault ["hr", 0];
    private _targetResources = if (_applyBaseline) then {_initialResources} else {_currentResources};
    private _targetHr = if (_applyBaseline) then {_initialHr} else {_currentHr};

    private _deltaResources = _targetResources - _currentResources;
    private _deltaHr = _targetHr - _currentHr;

    [_side, _deltaResources, _deltaHr, true] call A3A_fnc_updateEconomyForSide;

    Info_5("Civil War economy baseline applied to %1: res %2 -> %3, hr %4 -> %5", _label, _currentResources, _targetResources, _currentHr, _targetHr);
} forEach [
    [Occupants, "NATO"],
    [Invaders, "CSAT"]
];

missionNamespace setVariable ["A3A_civilWarMode", true, true];

// Ensure an entry exists for the rebel AI side as well for save compatibility.
[teamPlayer, true] call A3A_fnc_getCommandStructureForSide;

Info("Civil War mode initialisation completed");
