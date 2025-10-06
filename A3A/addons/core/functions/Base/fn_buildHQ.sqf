/*
    Complete HQ move process, put petros back into own group
	Also used for choosing new HQ position after petros death

    Scope: Server
    Environment: Unscheduled
    Public: Yes

    Example:
    [player] remoteExecCall ["A3A_fnc_buildHQ", 2];
*/

#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params [["_sideInput", teamPlayer]];

private _structure = [_sideInput, true] call A3A_fnc_getCommandStructureForSide;
if !(typeName _structure isEqualTo "HASHMAP") exitWith {
    Error("buildHQ called without a valid command structure context");
};

private _side = _structure getOrDefault ["side", _sideInput];
if !(typeName _side isEqualTo "SIDE") then { _side = _sideInput; };
private _sideKey = _structure getOrDefault ["sideKey", [_sideInput] call A3A_fnc_sideToKey];
private _isRebelSide = _sideKey isEqualTo ([teamPlayer] call A3A_fnc_sideToKey);

private _hqObjects = _structure getOrDefault ["hqObjects", createHashMap];
private _advisor = _hqObjects getOrDefault ["advisor", petros];
private _respawnMarker = _structure getOrDefault ["respawnMarker", "respawnTeamPlayer"];
private _hqMarker = _structure getOrDefault ["hqMarker", "Synd_HQ"];
private _hqGarrison = _structure getOrDefault ["hqGarrison", _hqMarker];

if (_structure getOrDefault ["hqMoving", false]) then {
        _structure set ["hqMoving", false];
        if (_isRebelSide) then {
                A3A_petrosMoving = false; publicVariable "A3A_petrosMoving";
        };

        if !(isNull _advisor) then {
                private _groupAdvisor = createGroup _side;
                [_advisor] join _groupAdvisor;
                _groupAdvisor selectLeader _advisor;

                group _advisor setGroupOwner 2;
                private _advisorRef = _advisor;
                [_advisorRef] spawn {
                        params ["_unit"];
                        waitUntil {sleep 0.01; local _unit};
                        _unit switchAction "PlayerStand";
                        _unit disableAI "MOVE";
                        _unit disableAI "AUTOTARGET";
                        _unit setBehaviour "SAFE";
                };
        };

        if !(_respawnMarker isEqualTo "") then {
                [_respawnMarker, 1, _side] call A3A_fnc_setMarkerAlphaForSide;
                [_respawnMarker, 1, civilian] call A3A_fnc_setMarkerAlphaForSide;
        };
};


// Update cur/old HQ knowledge
private _oldPos = if (_hqMarker isEqualTo "") then {[0,0,0]} else {markerPos _hqMarker};
private _newPos = if (isNull _advisor) then {_oldPos} else {getPosATL _advisor};

if (_isRebelSide) then {
        _oldPos set [2, A3A_curHQInfoOcc];
        A3A_oldHQInfoOcc pushBack +_oldPos;
        A3A_curHQInfoOcc = 0;
        {
                private _dist = _x distance2d _newPos;
                A3A_curHQInfoOcc = A3A_curHQInfoOcc max linearConversion [0, 1000, _dist, _x#2, 0, true];
        } forEach A3A_oldHQInfoOcc;

        _oldPos set [2, A3A_curHQInfoInv];
        A3A_oldHQInfoInv pushBack +_oldPos;
        A3A_curHQInfoInv = 0;
        {
                private _dist = _x distance2d _newPos;
                A3A_curHQInfoInv = A3A_curHQInfoInv max linearConversion [0, 1000, _dist, _x#2, 0, true];
        } forEach A3A_oldHQInfoInv;
};


// Do the actual HQ position set
if !(_respawnMarker isEqualTo "") then { _respawnMarker setMarkerPos _newPos; };
if (_isRebelSide) then {
        posHQ = _newPos; publicVariable "posHQ";
};
if !(_hqMarker isEqualTo "") then { _hqMarker setMarkerPos _newPos; };

_structure set ["hqPosition", _newPos];

if (_isRebelSide) then {
        chopForest = false; publicVariable "chopForest";
};

[_newPos, _sideInput] call A3A_fnc_relocateHQObjects;


// Move nearby buildings, statics & vehicles into HQ garrison
private _buildingsInArea = if (_hqMarker isEqualTo "") then {[]} else {A3A_buildingsToSave inAreaArray _hqMarker};
{
        if !(_hqGarrison isEqualTo "") then {
                [_hqGarrison, _x] call A3A_fnc_garrisonServer_addVehicle;
        };
} forEach _buildingsInArea;
A3A_buildingsToSave = A3A_buildingsToSave - _buildingsInArea;


// Only conditions are unattached for statics and no crew for vehicles?
// Probably need to check what exactly counts as a vehicle here
{
	if (!alive _x) then { continue };
	if (fullCrew [_x, "", true] isEqualTo []) then { continue };			// only want real vehicles & statics here

	if (_x isKindOf "staticWeapon") then {
		if (!isNull attachedTo _x) then { continue };
        } else {
                if (count crew _x != 0) then { continue };
        };

        if !(_hqGarrison isEqualTo "") then {
                [_hqGarrison, _x] call A3A_fnc_garrisonServer_addVehicle;
        };

} forEach (if (_hqMarker isEqualTo "") then {[]} else {vehicles inAreaArray _hqMarker});

[_sideInput, _structure] call A3A_fnc_setCommandStructureForSide;

["HQPlaced", [_newPos]] call EFUNC(Events,triggerEvent);
