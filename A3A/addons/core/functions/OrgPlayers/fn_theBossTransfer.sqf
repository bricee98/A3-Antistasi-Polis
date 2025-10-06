#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

if !(isServer) exitWith {};

params [["_sideInput", teamPlayer], ["_newCommander", objNull], ["_silent", false]];

private _structure = [_sideInput, true] call A3A_fnc_getCommandStructureForSide;
if (typeName _structure != "HASHMAP") exitWith {};

private _side = _structure getOrDefault ["side", _sideInput];
private _sideKey = _structure getOrDefault ["sideKey", [_sideInput] call A3A_fnc_sideToKey];
private _sideLabel = _structure getOrDefault ["commanderLabel", _sideKey];
private _currentCommander = _structure getOrDefault ["commander", objNull];

private _syncObjects = +(_structure getOrDefault ["commanderSyncObjects", []]);
if (_syncObjects isEqualTo [] && {!isNil "HC_commanderX"} && {_side isEqualTo teamPlayer}) then {
    _syncObjects = [HC_commanderX];
    _structure set ["commanderSyncObjects", _syncObjects];
};

private _notificationTarget = _structure getOrDefault ["commanderNotificationTarget", objNull];
if (isNull _notificationTarget && {!isNil "petros"} && {alive petros} && {_side isEqualTo teamPlayer}) then {
    _notificationTarget = petros;
    _structure set ["commanderNotificationTarget", petros];
};

private _notificationChannel = _structure getOrDefault ["commanderNotificationChannel", "hint"];
private _notificationTitle = _structure getOrDefault ["commanderNotificationTitle", ""];
if (_notificationTitle isEqualTo "") then {
    _notificationTitle = localize "STR_A3A_fn_orgp_tBTransfer_newCommTitle";
};

private _statisticsTargets = _structure getOrDefault ["commanderStatisticsTargets", [_side, civilian]];

private _transferGroups = [];
if (!isNull _currentCommander) then {
    Debug_2("Removing %1 as commander for %2", name _currentCommander, _sideLabel);
    _transferGroups = hcAllGroups _currentCommander;
    {
        _currentCommander synchronizeObjectsRemove [_x];
        _x synchronizeObjectsRemove [_currentCommander];
    } forEach _syncObjects;
    hcRemoveAllGroups _currentCommander;
};
_structure set ["commanderHcGroups", _transferGroups];

[_sideInput, _newCommander, false] call A3A_fnc_setCommanderForSide;

if (isNull _newCommander) then {
    Debug_1("Commander position for %1 cleared", _sideLabel);
    [_sideInput, _structure] call A3A_fnc_setCommandStructureForSide;

    if (_silent) exitWith {};

    [_notificationTarget, _notificationChannel, _notificationTitle, _statisticsTargets, _sideLabel] spawn {
        params ["_commsTarget", "_channel", "_title", "_statsTargets", "_sideName"];
        sleep 5;
        private _text = format [localize "STR_A3A_fn_orgp_tBTransfer_noEligible", _sideName];
        if (!isNull _commsTarget) then {
            [_commsTarget, _channel, _text, _title] remoteExec ["A3A_fnc_commsMP", 0];
        };
        [] remoteExec ["A3A_fnc_statistics", _statsTargets];
    };

    exitWith {};
};

Debug_2("Assigning %1 as commander for %2", name _newCommander, _sideLabel);

private _commanderGroup = group _newCommander;
if (!isNull _commanderGroup) then {
    [_commanderGroup, _newCommander] remoteExec ["selectLeader", groupOwner _commanderGroup];
};

{
    _newCommander synchronizeObjectsAdd [_x];
    _x synchronizeObjectsAdd [_newCommander];
} forEach _syncObjects;

private _previousGroups = _structure getOrDefault ["commanderHcGroups", []];
if (_previousGroups isEqualTo []) then {
    {
        if ((leader _x getVariable ["spawner", false]) && {!isPlayer leader _x} && {side _x isEqualTo _side}) then {
            _newCommander hcSetGroup [_x];
            _x setGroupOwner owner _newCommander;
        };
    } forEach allGroups;
} else {
    {
        if (!isNull _x && {alive leader _x} && {side _x isEqualTo _side}) then {
            _newCommander hcSetGroup [_x];
            _x setGroupOwner owner _newCommander;
        };
    } forEach _previousGroups;
};

_structure set ["commanderHcGroups", []];
[_sideInput, _structure] call A3A_fnc_setCommandStructureForSide;

if (_silent) exitWith {};

[_notificationTarget, _notificationChannel, _notificationTitle, _statisticsTargets, _newCommander, _sideLabel] spawn {
    params ["_commsTarget", "_channel", "_title", "_statsTargets", "_commander", "_sideName"];
    sleep 5;
    private _text = format [localize "STR_A3A_fn_orgp_tBTransfer_newCommLong", name _commander, _sideName];
    if (!isNull _commsTarget) then {
        [_commsTarget, _channel, _text, _title] remoteExec ["A3A_fnc_commsMP", 0];
    };
    [] remoteExec ["A3A_fnc_statistics", _statsTargets];
};
