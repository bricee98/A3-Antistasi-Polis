#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
params [
    ["_side", teamPlayer, [sideUnknown, grpNull, objNull, "", 0]],
    ["_hrChange", 0, [0]],
    ["_resourceChange", 0, [0]],
    ["_options", createHashMap, [createHashMap, []]]
];

private _optionsHM = _options;
if !(_optionsHM isEqualType createHashMap) then {
    _optionsHM = createHashMapFromArray _options;
};

private _mode = _optionsHM getOrDefault ["mode", "delta"];

private _structures = missionNamespace getVariable ["A3A_commandStructures", objNull];
if !(_structures isEqualType createHashMap) then {
    _structures = call A3A_fnc_initCommandStructures;
};

private _key = [_side] call A3A_fnc_sideToKey;
private _structure = _structures getOrDefault [_key, objNull];
if !(_structure isEqualType createHashMap) then {
    _structure = [_side] call A3A_fnc_createCommandStructure;
    _structures set [_key, _structure];
};

private _currentHr = _structure getOrDefault ["hr", 0];
private _currentResources = _structure getOrDefault ["resources", 0];

switch (_mode) do {
    case "set": {
        _currentHr = _hrChange;
        _currentResources = _resourceChange;
    };
    default {
        _currentHr = _currentHr + _hrChange;
        _currentResources = _currentResources + _resourceChange;
    };
};

if (_currentHr < 0) then { _currentHr = 0; };
if (_currentResources < 0) then { _currentResources = 0; };

_structure set ["hr", _currentHr];
_structure set ["resources", _currentResources];
_structure set ["sideKey", _key];
if (_side isEqualType sideUnknown) then {
    _structure set ["side", _side];
};

_structures set [_key, _structure];
missionNamespace setVariable ["A3A_commandStructures", _structures, true];

[_currentHr, _currentResources]
