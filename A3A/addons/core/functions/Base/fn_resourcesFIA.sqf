#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

private _sideInput = teamPlayer;
private _hrDelta = 0;
private _resourceDelta = 0;
private _silent = false;

// Maintain backwards compatibility with pre-refactor parameter order
private _args = _this;
if (!(_args isEqualType [])) then { _args = [_args]; };

if ((count _args) > 0 && {(_args#0) isEqualType 0}) then {
    _hrDelta = _args#0;
    if ((count _args) > 1 && {(_args#1) isEqualType 0}) then { _resourceDelta = _args#1; };
    if ((count _args) > 2 && {(_args#2) isEqualType true}) then { _silent = _args#2; };
} else {
    if ((count _args) > 0) then { _sideInput = _args#0; };
    if ((count _args) > 1) then { _hrDelta = _args#1; };
    if ((count _args) > 2) then { _resourceDelta = _args#2; };
    if ((count _args) > 3) then { _silent = _args#3; };
};

if !(_hrDelta isEqualType 0) exitWith { Error("The added HR must be a number"); };
if !(_resourceDelta isEqualType 0) exitWith { Error("The added money must be a number"); };
if !(_silent isEqualType true) then { _silent = false; };

waitUntil { !resourcesIsChanging };
resourcesIsChanging = true;

if ((floor _resourceDelta == 0) && {floor _hrDelta == 0}) exitWith { resourcesIsChanging = false };

private _economy = [_sideInput, true] call A3A_fnc_getEconomyForSide;
private _currentResources = _economy getOrDefault ["resources", 0];
private _currentHr = _economy getOrDefault ["hr", 0];

private _sideKey = [_sideInput] call A3A_fnc_sideToKey;
private _pendingHr = _currentHr + _hrDelta;

if ((_pendingHr < 0) && {_sideKey isEqualTo "reb"}) then {
    private _structure = [_sideInput, false] call A3A_fnc_getCommandStructureForSide;
    private _hqMarker = "Synd_HQ";
    if (_structure isEqualType createHashMap) then {
        _hqMarker = _structure getOrDefault ["hqMarker", _hqMarker];
    };

    private _hqPos = markerPos _hqMarker;
    private _cityIndexes = citiesX inAreaArrayIndexes [_hqPos, distanceMission, distanceMission];
    if (_cityIndexes isNotEqualTo []) then {
        private _nearCity = citiesX select selectRandom _cityIndexes;
        [_pendingHr, _nearCity] remoteExecCall ["A3A_fnc_citySupportChange", 2];
    };
};

[_sideInput, _resourceDelta, _hrDelta] call A3A_fnc_updateEconomyForSide;

resourcesIsChanging = false;

if (_silent) exitWith {};

private _factionName = switch (_sideKey) do {
    case "occ": { FactionGet(occ,"name") };
    case "inv": { FactionGet(inv,"name") };
    case "civ": { FactionGet(civ,"name") };
    default { FactionGet(reb,"name") };
};

private _hrSim = if (_hrDelta > 0) then {"+"} else {""};
private _resSim = if (_resourceDelta > 0) then {"+"} else {""};

private _hrText = if (floor _hrDelta == 0) then {
    ""
} else {
    format ["<t size='0.5' color='#C1C0BB'>" + localize "STR_A3A_fn_base_resourcesFIA_hr" + "</t><br/>", _hrSim, _hrDelta toFixed 0]
};

private _moneyText = if (floor _resourceDelta == 0) then {
    ""
} else {
    format ["<t size='0.5' color='#C1C0BB'>" + localize "STR_A3A_fn_base_resourcesFIA_money" + "</t>", _resSim, _resourceDelta toFixed 0]
};

private _textX = format ["<t size='0.6' color='#C1C0BB'>" + localize "STR_A3A_fn_base_resourcesFIA_resources" + "<br/><br/> ", _factionName] + _hrText + _moneyText;

if (_textX isEqualTo "") exitWith {};

private _commanderUnit = [_sideInput] call A3A_fnc_getCommanderForSide;
private _speaker = _commanderUnit;
private _target = _commanderUnit;

if (isNull _commanderUnit && {_sideKey isEqualTo "reb"}) then {
    _speaker = petros;
    _target = theBoss;
};

if (!isNull _speaker && {!isNull _target}) then {
    [_speaker, "income", _textX] remoteExec ["A3A_fnc_commsMP", _target];
};
