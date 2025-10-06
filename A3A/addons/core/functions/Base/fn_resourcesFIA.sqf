#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

/*
 * Extends the legacy FIA resource handler with side-aware economy support.
 * Arguments:
 * 0: HR delta <NUMBER>
 * 1: Resource delta <NUMBER>
 * 2: Silent update <BOOL> (optional)
 * 3: Target side <ANY> (optional, default teamPlayer)
 * 4: Propagate to clients <BOOL> (optional, default true)
 */

params [
    ["_hrDelta", "", [0, ""]],
    ["_resourceDelta", "", [0, ""]],
    ["_silent", false, [false]],
    ["_side", teamPlayer],
    ["_propagate", true, [false]]
];

if !(_hrDelta isEqualType 0) exitWith { Error("The first parameter, the added HR, must be a number"); };
if !(_resourceDelta isEqualType 0) exitWith { Error("The second parameter, the added money, must be a number"); };

private _sideKey = [_side] call A3A_fnc_sideToKey;
if (_sideKey isEqualTo "") then {
    Warning_1("Unrecognised side %1 passed to resourcesFIA, defaulting to rebel side", _side);
    _side = teamPlayer;
    _sideKey = "reb";
};

private _isRebel = _sideKey isEqualTo "reb";
private _lockVarName = format ["A3A_resourcesLock_%1", _sideKey];

if (_isRebel) then {
    waitUntil {!resourcesIsChanging};
    resourcesIsChanging = true;
} else {
    waitUntil {!(missionNamespace getVariable [_lockVarName, false])};
    missionNamespace setVariable [_lockVarName, true];
};

private _releaseLock = {
    params ["_lockName", "_useRebelLock"];
    if (_useRebelLock) then {
        resourcesIsChanging = false;
    } else {
        missionNamespace setVariable [_lockName, false];
    };
};

private _economy = [_side, true] call A3A_fnc_getEconomyForSide;
private _currentHr = _economy getOrDefault ["hr", 0];
private _currentResources = _economy getOrDefault ["resources", 0];

if ((floor _resourceDelta == 0) && {floor _hrDelta == 0}) exitWith {
    [_lockVarName, _isRebel] call _releaseLock;
    [_currentResources, _currentHr]
};

private _newHr = _currentHr + _hrDelta;
private _newResources = round (_currentResources + _resourceDelta);

if (_isRebel && {_newHr < 0}) then {
    // If we're using more HR than we have (eg. player respawn at 0 HR) then hurt nearby city support.
    private _nearCity = citiesX select selectRandom (citiesX inAreaArrayIndexes [markerPos "Synd_HQ", distanceMission, distanceMission]);
    [_newHr, _nearCity] remoteExecCall ["A3A_fnc_citySupportChange", 2];
    _newHr = 0;
};

if (_newResources < 0) then { _newResources = 0; };
private _hrDeltaApplied = _newHr - _currentHr;
private _resourceDeltaApplied = _newResources - _currentResources;

private _result = [_side, _resourceDeltaApplied, _hrDeltaApplied, _propagate] call A3A_fnc_updateEconomyForSide;
[_lockVarName, _isRebel] call _releaseLock;

if (_silent || {!_isRebel}) exitWith { _result };

private _textX = "";
private _hrSign = "";
if (_hrDelta > 0) then { _hrSign = "+"; };
private _resourceSign = "";
if (_resourceDelta > 0) then { _resourceSign = "+"; };

private _faction = format ["<t size='0.6' color='#C1C0BB'>" + localize "STR_A3A_fn_base_resourcesFIA_resources" + "<br/><br/> ", FactionGet(reb,"name")];
private _hrText = if (floor _hrDelta == 0) then {""} else {format ["<t size='0.5' color='#C1C0BB'>" + localize "STR_A3A_fn_base_resourcesFIA_hr" + "</t><br/>", _hrSign, _hrDelta toFixed 0];};
private _moneyText = if (floor _resourceDelta == 0) then {""} else {format ["<t size='0.5' color='#C1C0BB'>" + localize "STR_A3A_fn_base_resourcesFIA_money" + "</t>", _resourceSign, _resourceDelta toFixed 0];};
_textX = _faction + _hrText + _moneyText;

if (_textX != "") then {
    [petros, "income", _textX] remoteExec ["A3A_fnc_commsMP", theBoss];
};

_result
