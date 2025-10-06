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
    _structure set ["commanderLabel", _label];
    private _economy = _structure getOrDefault ["economy", createHashMapFromArray [["resources", 0], ["hr", 0], ["storage", createHashMap]]];

    private _currentResources = _economy getOrDefault ["resources", 0];
    private _currentHr = _economy getOrDefault ["hr", 0];
    private _targetResources = if (_applyBaseline) then {_initialResources} else {_currentResources};
    private _targetHr = if (_applyBaseline) then {_initialHr} else {_currentHr};

    private _deltaResources = _targetResources - _currentResources;
    private _deltaHr = _targetHr - _currentHr;

    [_side, _deltaResources, _deltaHr, true] call A3A_fnc_updateEconomyForSide;

    _structure set ["commanderStatisticsTargets", [_side, civilian]];
    _structure set ["commanderNotificationTitle", localize "STR_A3A_fn_orgp_tBTransfer_newCommTitle"];
    _structure set ["commanderNotificationTarget", objNull];

    private _defaultMarker = if (_side isEqualTo Occupants) then {"NATO_carrier"} else {"CSAT_carrier"};
    _structure set ["hqMarker", _structure getOrDefault ["hqMarker", _defaultMarker]];

    private _hqObjects = _structure getOrDefault ["hqObjects", []];
    if (_hqObjects isEqualTo []) then {
        private _markerPos = markerPos (_structure get "hqMarker");
        if !(_markerPos isEqualTo [0,0,0]) then {
            private _searchClasses = [
                "Land_Cargo_HQ_V1_F",
                "Land_Cargo_HQ_V2_F",
                "Land_Cargo_HQ_V3_F",
                "Land_Cargo_Tower_V1_F",
                "FlagPole_F",
                "Flag_NATO_F",
                "Flag_CSAT_F"
            ];
            private _candidates = nearestObjects [_markerPos, _searchClasses, 125];
            if !(_candidates isEqualTo []) then {
                _hqObjects = [_candidates#0];
                _structure set ["hqObjects", _hqObjects];
            };
        };
    };

    [_side, _structure] call A3A_fnc_setCommandStructureForSide;

    {
        if (!isNull _x) then {
            [_x, _side, _label] remoteExec ["A3A_fnc_registerCommanderActions", 0, _x];
        };
    } forEach (_structure getOrDefault ["hqObjects", []]);

    Info_5("Civil War economy baseline applied to %1: res %2 -> %3, hr %4 -> %5", _label, _currentResources, _targetResources, _currentHr, _targetHr);
} forEach [
    [Occupants, "NATO"],
    [Invaders, "CSAT"]
];

missionNamespace setVariable ["A3A_civilWarMode", true, true];

// Ensure an entry exists for the rebel AI side as well for save compatibility.
[teamPlayer, true] call A3A_fnc_getCommandStructureForSide;

Info("Civil War mode initialisation completed");
