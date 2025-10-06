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

private _hqDefinitions = [
    [Occupants, "NATO", "NATO_carrier", "Flag_NATO_F", "B_officer_F"],
    [Invaders, "CSAT", "CSAT_carrier", "Flag_CSAT_F", "O_officer_F"]
];

{
    _x params ["_side", "_label", "_anchorMarker", "_flagClass", "_advisorClass"];

    private _structure = [_side, true] call A3A_fnc_getCommandStructureForSide;
    if !(typeName _structure isEqualTo "HASHMAP") then { continue };

    private _spawnPos = markerPos _anchorMarker;
    if (_spawnPos isEqualTo [0,0,0]) then { continue };

    private _respawnMarker = _structure getOrDefault ["respawnMarker", ""];
    if (_respawnMarker isEqualTo "") then {
        _respawnMarker = format ["respawn_%1", toLower _label];
    };

    if !(_respawnMarker in allMapMarkers) then {
        createMarker [_respawnMarker, _spawnPos];
    };
    _respawnMarker setMarkerAlpha 0;
    _respawnMarker setMarkerPos _spawnPos;
    _structure set ["respawnMarker", _respawnMarker];

    private _hqMarker = _structure getOrDefault ["hqMarker", ""];
    if (_hqMarker isEqualTo "") then {
        _hqMarker = format ["%1_HQ", _label];
    };
    if !(_hqMarker in allMapMarkers) then {
        createMarker [_hqMarker, _spawnPos];
    };
    _hqMarker setMarkerShape "ELLIPSE";
    _hqMarker setMarkerSize [75,75];
    _hqMarker setMarkerPos _spawnPos;
    _structure set ["hqMarker", _hqMarker];

    if (_structure getOrDefault ["hqGarrison", ""] isEqualTo "") then {
        _structure set ["hqGarrison", _hqMarker];
    };

    private _garrison = A3A_garrison getOrDefault [_hqMarker, createHashMap];
    if !(typeName _garrison isEqualTo "HASHMAP") then {
        _garrison = createHashMap;
    };
    {
        if (isNil {_garrison get _x}) then { _garrison set [_x, []]; };
    } forEach ["troops", "vehicles", "buildings", "spawnedBuildings"];
    A3A_garrison set [_hqMarker, _garrison];

    _structure set ["hqPosition", _spawnPos];

    private _hqObjects = _structure getOrDefault ["hqObjects", createHashMap];
    if !(typeName _hqObjects isEqualTo "HASHMAP") then { _hqObjects = createHashMap; };

    private _spawnStatic = {
        params ["_existing", "_className"];
        if !(isNull _existing) exitWith { _existing };
        if (_className isEqualTo "") exitWith { objNull };
        private _obj = createVehicle [_className, _spawnPos, [], 0, "CAN_COLLIDE"];
        _obj allowDamage false;
        _obj enableRopeAttach false;
        _obj hideObjectGlobal true;
        _obj
    };

    private _camp = [_hqObjects getOrDefault ["camp", objNull], "Land_TentSolar_01_olive_F"] call _spawnStatic;
    private _crate = [_hqObjects getOrDefault ["crate", objNull], "IG_supplyCrate_F"] call _spawnStatic;
    private _vehicleCrate = [_hqObjects getOrDefault ["vehicleCrate", objNull], "Land_CargoBox_V1_F"] call _spawnStatic;
    private _mapBoard = [_hqObjects getOrDefault ["map", objNull], "MapBoard_seismic_F"] call _spawnStatic;
    private _flag = [_hqObjects getOrDefault ["flag", objNull], _flagClass] call _spawnStatic;

    private _advisor = _hqObjects getOrDefault ["advisor", objNull];
    if (isNull _advisor && {!(_advisorClass isEqualTo "")}) then {
        private _group = createGroup _side;
        _advisor = _group createUnit [_advisorClass, _spawnPos, [], 0, "NONE"];
        _advisor allowDamage false;
        _advisor setBehaviour "SAFE";
        _advisor disableAI "MOVE";
        _advisor disableAI "AUTOTARGET";
        group _advisor setGroupOwner 2;
    };

    _hqObjects set ["camp", _camp];
    _hqObjects set ["crate", _crate];
    _hqObjects set ["vehicleCrate", _vehicleCrate];
    _hqObjects set ["map", _mapBoard];
    _hqObjects set ["flag", _flag];
    if !(isNull _advisor) then { _hqObjects set ["advisor", _advisor]; };

    _structure set ["hqObjects", _hqObjects];
    _structure set ["hqMoving", false];

    [_spawnPos, _side] call A3A_fnc_relocateHQObjects;

    [_respawnMarker, 1, _side] call A3A_fnc_setMarkerAlphaForSide;
    {
        if (_x == _side) then { continue };
        [_respawnMarker, 0, _x] call A3A_fnc_setMarkerAlphaForSide;
    } forEach [teamPlayer, Occupants, Invaders, resistance, civilian];

    [_side, _structure] call A3A_fnc_setCommandStructureForSide;
} forEach _hqDefinitions;

missionNamespace setVariable ["A3A_civilWarMode", true, true];

// Ensure an entry exists for the rebel AI side as well for save compatibility.
[teamPlayer, true] call A3A_fnc_getCommandStructureForSide;

Info("Civil War mode initialisation completed");
