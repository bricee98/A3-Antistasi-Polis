#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
Info("loadServer Starting.");
if (isServer) then {
    Info("Starting Persistent Load.");
	petros allowdamage false;

	// Set all main markers to occupant control by default, overridden by mrkSDK & mrkCSAT
	{ 
		if (sidesX getVariable _x != Occupants) then { sidesX setVariable [_x, Occupants, true] };
	} forEach (airportsX + resourcesX + factories + outposts + seaports);

	A3A_saveVersion = 0;
	["version"] call A3A_fnc_getStatVariable;
	["outpostsFIA"] call A3A_fnc_getStatVariable;
	["mrkSDK"] call A3A_fnc_getStatVariable;
	["mrkCSAT"] call A3A_fnc_getStatVariable;
	["destroyedSites"] call A3A_fnc_getStatVariable;
	["minesX"] call A3A_fnc_getStatVariable;
	["antennas"] call A3A_fnc_getStatVariable;
	["hr"] call A3A_fnc_getStatVariable;
	["dateX"] call A3A_fnc_getStatVariable;
	["weather"] call A3A_fnc_getStatVariable;
	["prestigeBLUFOR"] call A3A_fnc_getStatVariable;		// backwards compat, overwritten by cityData
	["cityData"] call A3A_fnc_getStatVariable;
	["radioKeys"] call A3A_fnc_getStatVariable;
	["resourcesFIA"] call A3A_fnc_getStatVariable;
//	["garrison"] call A3A_fnc_getStatVariable;			// loaded later if it's an old save
	["skillFIA"] call A3A_fnc_getStatVariable;
	["membersX"] call A3A_fnc_getStatVariable;
	["vehInGarage"] call A3A_fnc_getStatVariable;			// backwards compat, overwritten by HR_Garage
    ["HR_Garage"] call A3A_fnc_getStatVariable;
    ["A3A_fuelAmountleftArray"] call A3A_fnc_getStatVariable;
	["destroyedBuildings"] call A3A_fnc_getStatVariable;
	["enemyResources"] call A3A_fnc_getStatVariable;
	["HQKnowledge"] call A3A_fnc_getStatVariable;
//	["idlebases"] call A3A_fnc_getStatVariable;			// Might bring this back at some point
	["killZones"] call A3A_fnc_getStatVariable;
	["bombRuns"] call A3A_fnc_getStatVariable;
	["arsenalLimits"] call A3A_fnc_getStatVariable;
	["rebelLoadouts"] call A3A_fnc_getStatVariable;
	["jna_datalist"] call A3A_fnc_getStatVariable;
	["minorSites"] call A3A_fnc_getStatVariable;
	// Restore command structure state and per-side economies
	private _commandStructureBlob = "commandStructures" call A3A_fnc_returnSavedStat;
	private _loadedStructures = createHashMap;
	private _commandStructureData = createHashMap;
	if (_commandStructureBlob isEqualType createHashMap) then {
		_commandStructureData = _commandStructureBlob getOrDefault ["structures", createHashMap];
		if !(_commandStructureData isEqualType createHashMap) then { _commandStructureData = createHashMap };
	};

	{
		private _sideKey = _x;
		private _savedEntry = _y;
		if !(typeName _savedEntry == "HASHMAP") then { continue };

		private _sideValue = _savedEntry getOrDefault ["side", _sideKey];
		private _structure = [_sideValue] call A3A_fnc_defaultCommandStructure;
		private _structureSideKey = _structure getOrDefault ["sideKey", _sideKey];
		if !(_structureSideKey isEqualTo _sideKey) then { _structure set ["sideKey", _sideKey] };

		_structure set ["hqMarker", _savedEntry getOrDefault ["hqMarker", _structure getOrDefault ["hqMarker", ""]]];
		_structure set ["hqPosition", +(_savedEntry getOrDefault ["hqPosition", _structure getOrDefault ["hqPosition", [0,0,0]]])];

		private _hqObjects = [];
		{
			if !(_x isEqualType "") then { continue };
			private _obj = objectFromNetId _x;
			if (isNull _obj) then { continue };
			_hqObjects pushBackUnique _obj;
		} forEach (_savedEntry getOrDefault ["hqObjects", []]);
		_structure set ["hqObjects", _hqObjects];

		private _economyData = _savedEntry getOrDefault ["economy", createHashMap];
		private _economy = _structure getOrDefault ["economy", createHashMapFromArray [["resources", 0], ["hr", 0], ["storage", createHashMap]]];
		if (_economyData isEqualType createHashMap) then {
			_economy set ["resources", _economyData getOrDefault ["resources", _economy getOrDefault ["resources", 0]]];
			_economy set ["hr", _economyData getOrDefault ["hr", _economy getOrDefault ["hr", 0]]];
			private _storageData = _economyData getOrDefault ["storage", _economy getOrDefault ["storage", createHashMap]];
			if (_storageData isEqualType createHashMap) then {
				_economy set ["storage", _storageData];
			} else {
				_economy set ["storage", createHashMap];
			};
		} else {
			if (_economyData isEqualType []) then {
				_economy set ["resources", _economyData param [0, _economy getOrDefault ["resources", 0]]];
				_economy set ["hr", _economyData param [1, _economy getOrDefault ["hr", 0]]];
			} else {
				_economy set ["resources", _economy getOrDefault ["resources", 0]];
				_economy set ["hr", _economy getOrDefault ["hr", 0]];
			};
			_economy set ["storage", createHashMap];
		};
		_structure set ["economy", _economy];

		private _unlockState = _savedEntry getOrDefault ["unlockState", _structure getOrDefault ["unlockState", createHashMap]];
		if (_unlockState isEqualType createHashMap) then {
			private _unlockCopy = createHashMap;
			{ _unlockCopy set [_x, _unlockState get _x] } forEach keys _unlockState;
			_structure set ["unlockState", _unlockCopy];
		} else {
			_structure set ["unlockState", createHashMap];
		};

		private _logisticsQueue = _savedEntry getOrDefault ["logisticsQueue", []];
		if (_logisticsQueue isEqualType []) then { _structure set ["logisticsQueue", +_logisticsQueue] } else { _structure set ["logisticsQueue", _structure getOrDefault ["logisticsQueue", []]] };

		private _commanderData = _savedEntry getOrDefault ["commander", createHashMap];
		private _commanderUID = "";
		private _commander = objNull;
		if (_commanderData isEqualType createHashMap) then {
			_commanderUID = _commanderData getOrDefault ["uid", ""];
			private _commanderNetId = _commanderData getOrDefault ["netId", ""];
			if !(_commanderNetId isEqualTo "") then { _commander = objectFromNetId _commanderNetId };
			if (isNull _commander && !(_commanderUID isEqualTo "")) then {
				{ if (getPlayerUID _x == _commanderUID) exitWith { _commander = _x } } forEach (allPlayers - entities "HeadlessClient_F");
			};
		};
		_structure set ["commander", _commander];
		_structure set ["commanderUID", _commanderUID];

		_loadedStructures set [_sideKey, _structure];
	} forEach _commandStructureData;

	private _requiredSides = [
		[teamPlayer, [teamPlayer] call A3A_fnc_sideToKey],
		[Occupants, [Occupants] call A3A_fnc_sideToKey],
		[Invaders, [Invaders] call A3A_fnc_sideToKey]
	];
	{
		_x params ["_side", "_sideKey"];
		if (_sideKey isEqualTo "") then { continue };
		if (isNil {_loadedStructures get _sideKey}) then {
			private _structure = [_side] call A3A_fnc_defaultCommandStructure;
			if (_sideKey isEqualTo ([teamPlayer] call A3A_fnc_sideToKey)) then {
				private _economy = _structure getOrDefault ["economy", createHashMap];
				_economy set ["resources", server getVariable ["resourcesFIA", initialFactionMoney]];
				_economy set ["hr", server getVariable ["hr", initialHr]];
				_structure set ["economy", _economy];
			};
			_loadedStructures set [_sideKey, _structure];
		};
	} forEach _requiredSides;

	missionNamespace setVariable ["A3A_commandStructures", _loadedStructures];
	if (isMultiplayer) then { publicVariable "A3A_commandStructures" };

	{
		private _sideKey = _x;
		private _structure = _y;
		private _economy = _structure getOrDefault ["economy", createHashMap];
		private _resources = _economy getOrDefault ["resources", 0];
		private _hr = _economy getOrDefault ["hr", 0];
		private _resVar = format ["A3A_resources_%1", _sideKey];
		private _hrVar = format ["A3A_hr_%1", _sideKey];
		missionNamespace setVariable [_resVar, _resources];
		missionNamespace setVariable [_hrVar, _hr];
		if (isMultiplayer) then { publicVariable _resVar; publicVariable _hrVar; };
		if (_sideKey isEqualTo ([teamPlayer] call A3A_fnc_sideToKey)) then {
			server setVariable ["resourcesFIA", _resources, true];
			server setVariable ["hr", _hr, true];
		};
	} forEach _loadedStructures;

	private _rebelKey = [teamPlayer] call A3A_fnc_sideToKey;
	private _rebelStructure = _loadedStructures getOrDefault [_rebelKey, createHashMap];
	private _savedCommander = _rebelStructure getOrDefault ["commander", objNull];
	if (isNull _savedCommander) then {
		private _savedUID = _rebelStructure getOrDefault ["commanderUID", ""];
		if !(_savedUID isEqualTo "") then {
			{ if (getPlayerUID _x == _savedUID) exitWith { _savedCommander = _x } } forEach (allPlayers - entities "HeadlessClient_F");
		};
	};

	if (!isNull _savedCommander && {theBoss != _savedCommander}) then {
		[_savedCommander, true] call A3A_fnc_theBossTransfer;
	} else {
		if (isNull theBoss) then { [] call A3A_fnc_assignBossIfNone };
	};

	private _finalCommander = theBoss;
	if (isNull _finalCommander) then {
		_finalCommander = _rebelStructure getOrDefault ["commander", objNull];
	};
	private _finalCommanderUID = "";
	if (!isNull _finalCommander) then {
		_finalCommanderUID = _finalCommander getVariable ["A3A_playerUID", getPlayerUID _finalCommander];
	};
	_rebelStructure set ["commander", _finalCommander];
	_rebelStructure set ["commanderUID", _finalCommanderUID];
	_loadedStructures set [_rebelKey, _rebelStructure];
	missionNamespace setVariable ["A3A_commandStructures", _loadedStructures];
	if (isMultiplayer) then { publicVariable "A3A_commandStructures" };
	//===========================================================================

	//RESTORE THE STATE OF THE 'UNLOCKED' VARIABLES USING JNA_DATALIST
	private _categoriesToPublish = createHashMap;
	{
		private _arsenalTabDataArray = _x;
		private _unlockedItemsInTab = _arsenalTabDataArray select { _x select 1 == -1 } apply { _x select 0 };
		{
			private _categories = [_x, true, true] call A3A_fnc_unlockEquipment;
			_categoriesToPublish insert [true, _categories, []];
		} forEach _unlockedItemsInTab;
	} forEach jna_dataList;

	Info_1("Categories to publish: %1", keys _categoriesToPublish);

	// Publish the unlocked categories (once each)
	{ publicVariable ("unlocked" + _x) } forEach keys _categoriesToPublish;

	if !(unlockedNVGs isEqualTo []) then {
		haveNV = true; publicVariable "haveNV"
	};

	//Check if we have radios unlocked and update haveRadio.
	call A3A_fnc_checkRadiosUnlocked;

	{
		if (_x in destroyedSites) then {
			sidesX setVariable [_x, Invaders, true];
			[_x] call A3A_fnc_destroyCity
		};
	} forEach citiesX;

	// update war tier silently, calls updatePreference if changed
	// Needed for garrison sanity checks
	[true] call A3A_fnc_tierCheck;

	// ****************************************************************************************************
	// Garrison backwards compatibility & update
	A3A_garrison = +(["newGarrison"] call A3A_fnc_returnSavedStat);

	// Copy old garrison data into new garrisons
	private _garrisonCompat = isNil "A3A_garrison";
	if (_garrisonCompat) then { call A3A_fnc_convertSavedGarrisons };		// Creates & fills A3A_garrison

	// Fill out any garrison that hasn't already been filled
	// This might happen with map changes so we do it here rather than convertSavedGarrisons
	private _emptyGarrison = createHashMapFromArray [ ["troops", []], ["vehicles", []], ["buildings", []] ];
	{
		if (_x in A3A_garrison) then { continue };
		private _side = sidesX getVariable _x;
		if (_side == teamPlayer) then { A3A_garrison set [_x, +_emptyGarrison]; continue };		// should be impossible?
		[_x] call A3A_fnc_buildEnemyGarrison;		// cities, or markers added to map
	} forEach markersX;

	// outpostsFIA should be fully handled by convertSavedGarrisons

	// Sync minor site data & generate if missing
	call A3A_fnc_initMinorSites;

	// Add police stations if missing
	call A3A_fnc_initPoliceStations;

	// Fill out city civ component if missing (should be done after police stations because they share vehicle places)
	{ [_x] call A3A_fnc_buildCity } forEach citiesX;

	// Add type info to markers
	call A3A_fnc_initMarkerTypes;

	// Move saved statics & buildings into the correct garrisons
	if (_garrisonCompat) then { call A3A_fnc_convertSavedStatics };

	// **********************************************************************************************

	// Validate garrison vehicles (in case of faction or logic change)
	Debug("Starting garrison vehicle validation");
	private _civMarkers = citiesX apply { _x + "_civ" };
	{
		[_x, true, false] call A3A_fnc_garrisonServer_cleanup;
	} forEach (markersX + _civMarkers);
	Debug("Completed garrison vehicle validation");

	// Should have garrison data for this now
	{
		[_x] call A3A_fnc_mrkUpdate
	} forEach markersX;


	// Spawn in HQ buildings before we potentially place HQ objects on them
	private _spawnedBuildings = [];
	{
		_x params ["_typeVeh", "_posVeh", "_vecDir", "_vecUp"];
		isNil {
			private _veh = createVehicle [_typeVeh, _posVeh, [], 0, "CAN_COLLIDE"];
			_veh setPosWorld _posVeh;
			_veh setVectorDirAndUp [_vecDir, _vecUp];
			_spawnedBuildings pushBack _veh;
		};
	} forEach (A3A_garrison get "Synd_HQ" get "buildings");
	A3A_garrison get "Synd_HQ" set ["spawnedBuildings", _spawnedBuildings];


    //Load aggro stacks and level and calculate current level
    ["aggressionOccupants"] call A3A_fnc_getStatVariable;
	["aggressionInvaders"] call A3A_fnc_getStatVariable;
    [true] call A3A_fnc_calculateAggression;

	["chopForest"] call A3A_fnc_getStatVariable;

	["posHQ"] call A3A_fnc_getStatVariable;				// second call, this one after buildings compat
	["nextTick"] call A3A_fnc_getStatVariable;

	{_x setPosATL getMarkerPos respawnTeamPlayer} forEach ((call A3A_fnc_playableUnits) select {side _x == teamPlayer});

	// Move headless client logic objects near HQ so that firedNear EH etc. work more reliably
	private _hcpos = markerPos respawnTeamPlayer vectorAdd [-100, -100, 0];
	{ _x setPosATL _hcpos } forEach (entities "HeadlessClient_F");


    //Load state of testing timer
    ["testingTimerIsActive"] call A3A_fnc_getStatVariable;

	// Load all player data into A3A_playerSaveData hashmap
	private _savedPlayers = "savedPlayers" call A3A_fnc_returnSavedStat;
	if (isNil "_savedPlayers") then { _savedPlayers = [] };
	if (_savedPlayers isEqualType createHashMap) then {
		A3A_playerSaveData = _savedPlayers;
	} else {
		// backwards compat with old array + separate vars format
		// chuck this code after a couple of versions
		{
			private _uid = _x;
			private _playerData = createHashMap;
			{
				_playerData set [_x, [_uid, _x] call A3A_fnc_retrievePlayerStat];
			} forEach ["moneyX", "loadoutPlayer", "scorePlayer", "rankPlayer", "personalGarage","missionsCompleted"];

			if (isNil {_playerData get "moneyX"}) then { Error_1("Saved player %1 has no money var", _uid); continue };
			A3A_playerSaveData set [_uid, _playerData];
		} forEach _savedPlayers;
	};

    Info("Persistent Load Completed.");

	// uh, why here?
	["tasks"] call A3A_fnc_getStatVariable;

	statsLoaded = 0; publicVariable "statsLoaded";
	petros allowdamage true;
};
Info("loadServer Completed.");
