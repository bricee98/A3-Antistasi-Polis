// Reset positions of all HQ objects except petros
// Server, unscheduled

params [
    ["_newPos", [0,0,0], [[]]],
    ["_sideInput", teamPlayer]
];

private _structure = [_sideInput, true] call A3A_fnc_getCommandStructureForSide;
if !(typeName _structure isEqualTo "HASHMAP") exitWith {
        Error("relocateHQObjects called without a valid command structure context");
};

if (_newPos isEqualTo [0,0,0]) then {
        _newPos = _structure getOrDefault ["hqPosition", _newPos];
};

private _hqObjects = _structure getOrDefault ["hqObjects", createHashMap];
private _advisor = _hqObjects getOrDefault ["advisor", petros];
private _campObject = _hqObjects getOrDefault ["camp", fireX];
private _crateObject = _hqObjects getOrDefault ["crate", boxX];
private _mapObject = _hqObjects getOrDefault ["map", mapX];
private _vehicleObject = _hqObjects getOrDefault ["vehicleCrate", vehicleBox];
private _flagObject = _hqObjects getOrDefault ["flag", flagX];

private _advisorDir = if (isNull _advisor) then {0} else {getDir _advisor};

// Move headless client logic objects near HQ so that firedNear EH etc. work more reliably
private _hcpos = _newPos vectorAdd [-100, -100, 0];
{ _x setPosATL _hcpos } forEach (entities "HeadlessClient_F");

private _alignNormals = {
	private _thing = _this;
	_thing setVectorUp surfaceNormal getPos _thing;
};

private _firePos = [_newPos, 3, _advisorDir] call BIS_fnc_relPos;
//Extra height on the fire to avoid it clipping into the ground
if !(isNull _campObject) then {
        _campObject setPos (_firePos vectorAdd [0,0,0.1]);
};

private _rnd = _advisorDir;
private _pos = [_firePos, 3, _rnd] call BIS_fnc_relPos;
if !(isNull _crateObject) then { _crateObject setPos _pos; };

_rnd = _rnd + 45;
_pos = [_firePos, 3, _rnd] call BIS_fnc_relPos;
if !(isNull _mapObject) then {
        _mapObject setDir ([_firePos, _pos] call BIS_fnc_dirTo);
        _mapObject setPos _pos;
};

_rnd = _rnd + 45;
_pos = [_firePos, 3, _rnd] call BIS_fnc_relPos;
if !(isNull _flagObject) then {
        private _emptyPos = _pos findEmptyPosition [0,50,(typeOf _flagObject)];
        _pos = if (count _emptyPos > 0) then {_emptyPos} else {_pos};
        _flagObject setPos _pos;
};

_rnd = _rnd + 45;
_pos = [_firePos, 3, _rnd] call BIS_fnc_relPos;
if !(isNull _vehicleObject) then { _vehicleObject setPos _pos; };

//Align with ground. Deliberately ignoring flag, because a flag pole at 45 degrees looks weird
{
        if !(isNull _x) then { _x call _alignNormals; };
} forEach [_campObject, _crateObject, _mapObject, _vehicleObject];

{
        if !(isNull _x) then { _x hideObjectGlobal false; };
} forEach [_crateObject, _vehicleObject, _mapObject, _campObject, _flagObject];
