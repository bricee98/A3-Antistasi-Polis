/*
Maintainer: Wurzel0701
    Checks if the HQ can currently be moved

Arguments:
    <NIL>

Return Value:
    <ARRAY> If the HQ can be moved right now, first element bool, every other afterwards string, at least 2 elements

Scope: Anywhere
Environment: Any
Public: Yes
Dependencies:
    <OBJECT> theBoss
    <OBJECT> boxX
    <OBJECT> petros

Example:
[player] call A3A_fnc_canMoveHQ;
*/

params [
    ["_player", objNull, [objNull]],
    ["_sideInput", teamPlayer]
];

private _structure = [_sideInput, true] call A3A_fnc_getCommandStructureForSide;
private _commander = _structure getOrDefault ["commander", objNull];
if (isNull _commander) then { _commander = theBoss; };

private _result = [false];
private _titleStr = localize "STR_A3A_fn_base_canmovehq_title";

if (!isNull _player && {!isNull _commander} && {_player != _commander}) then
{
    [_titleStr, localize "STR_A3A_fn_base_canmovehq_no_comm"] call A3A_fnc_customHint;
    _result pushBack localize "STR_A3A_fn_base_canmovehq_comm_only";
};

private _advisor = (_structure getOrDefault ["hqObjects", createHashMap]) getOrDefault ["advisor", petros];
if !(isNull _advisor) then
{
    if !(isNull attachedTo _advisor) then
    {
        if(count _result == 1) then
        {
            [_titleStr, localize "STR_A3A_fn_base_canmovehq_petros_down"] call A3A_fnc_customHint;
        };
        _result pushBack localize "STR_A3A_fn_base_canmovehq_petros_pickedup";
    };
};

if(count _result != 1) exitWith
{
    _result;
};

[true, ""];
