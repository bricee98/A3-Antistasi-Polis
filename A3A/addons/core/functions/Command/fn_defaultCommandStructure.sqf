/*
 * Author: ChatGPT
 *
 * Description:
 *  Creates a default command structure hash map for the provided side key.
 *
 * Arguments:
 * 0: Side identifier <ANY> (SIDE, STRING, OBJECT, GROUP, SCALAR)
 *
 * Return Value:
 * <HASHMAP> Command structure definition.
 */
#include "..\..\script_component.hpp"
params ["_sideInput"];

private _sideKey = [_sideInput] call A3A_fnc_sideToKey;
if (_sideKey isEqualTo "") then {
    _sideKey = toLower str _sideInput;
};

private _structure = createHashMap;
_structure set ["sideKey", _sideKey];
_structure set ["side", _sideInput];
_structure set ["commanderLabel", _sideKey];
_structure set ["commander", objNull];
_structure set ["commanderHcGroups", []];
_structure set ["commanderSyncObjects", []];
_structure set ["commanderNotificationTarget", objNull];
_structure set ["commanderNotificationChannel", "hint"];
_structure set ["commanderNotificationTitle", ""];
_structure set ["commanderStatisticsTargets", [teamPlayer, civilian]];
_structure set ["commanderEligibilityVar", "eligible"];
_structure set ["hqObjects", []];
_structure set ["hqPosition", [0,0,0]];
_structure set ["hqMarker", ""];
_structure set ["economy", createHashMapFromArray [
    ["resources", 0],
    ["hr", 0],
    ["storage", createHashMap]
]];
_structure set ["unlockState", createHashMap];
_structure set ["logisticsQueue", []];
_structure set ["lastUpdated", diag_tickTime];

_structure
