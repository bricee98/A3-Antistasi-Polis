/*
    Start HQ move process, join petros into player group

    Scope: Server
    Environment: Unscheduled
    Public: Yes

    Example:
    [player] remoteExecCall ["A3A_fnc_moveHQ", 2];
*/

#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params [
    ["_player", objNull, [objNull]],
    ["_sideInput", teamPlayer]
];

private _structure = [_sideInput, true] call A3A_fnc_getCommandStructureForSide;
if !(typeName _structure isEqualTo "HASHMAP") exitWith {
    Error("MoveHQ called without a command structure context");
};

private _side = _structure getOrDefault ["side", _sideInput];
if !(typeName _side isEqualTo "SIDE") then { _side = _sideInput; };
private _sideKey = _structure getOrDefault ["sideKey", [_sideInput] call A3A_fnc_sideToKey];
private _isRebelSide = _sideKey isEqualTo ([teamPlayer] call A3A_fnc_sideToKey);

private _moveInProgress = _structure getOrDefault ["hqMoving", false];
if (_isRebelSide && {A3A_petrosMoving}) exitWith {
    Error("MoveHQ called when petros was moving");
};
if (!_isRebelSide && {_moveInProgress}) exitWith {
    Error_1("MoveHQ called while HQ move already active for %1", _sideKey);
};

private _possible = [_player, _sideInput] call A3A_fnc_canMoveHQ;
private _titleStr = localize "STR_A3A_fn_base_movehq_garrison";

if !(_possible#0) exitWith {
    if (!isNull _player) then {
        [_titleStr, _possible#1] remoteExecCall ["customHint", owner _player];
    };
};

_structure set ["hqMoving", true];
[_sideInput, _structure] call A3A_fnc_setCommandStructureForSide;

if (_isRebelSide) then {
    A3A_petrosMoving = true; publicVariable "A3A_petrosMoving";
};

// The enableAI commands will only affect localhost
private _hqObjects = _structure getOrDefault ["hqObjects", createHashMap];
private _advisor = _hqObjects getOrDefault ["advisor", petros];
private _campObject = _hqObjects getOrDefault ["camp", fireX];

if !(isNull _advisor) then {
    _advisor setBehaviour "AWARE";
    _advisor enableAI "MOVE";
    _advisor enableAI "AUTOTARGET";

    private _groupAdvisor = group _advisor;
    private _commander = [_sideInput] call A3A_fnc_getCommanderForSide;
    if (isNull _commander) then { _commander = theBoss; };

    if (!isNull _commander) then {
        [_advisor] join _commander;
    };

    if (!isNull _groupAdvisor && {_groupAdvisor != group _advisor}) then {
        deleteGroup _groupAdvisor;
    };
};

if !(isNull _campObject) then {
    try {
        _campObject inflame false;
    } catch {
        // Some HQ camp objects do not support inflame, ignore
    };
};

private _respawnMarker = _structure getOrDefault ["respawnMarker", ""];
if !(_respawnMarker isEqualTo "") then {
    [_respawnMarker, 0, _side] call A3A_fnc_setMarkerAlphaForSide;
    [_respawnMarker, 0, civilian] call A3A_fnc_setMarkerAlphaForSide;
};

private _hqGarrison = _structure getOrDefault ["hqGarrison", _structure getOrDefault ["hqMarker", ""]];
if !(_hqGarrison isEqualTo "") then {
    [_hqGarrison, false, true, true] call A3A_fnc_garrisonServer_clear;
};
