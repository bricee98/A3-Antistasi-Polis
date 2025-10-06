params [["_message", ""]];
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
private _countGroups = 0;
private _countRebels = 0;
private _countInvaders = 0;
private _countOccupants = 0;
private _countCiv = 0;

private _economy = [teamPlayer, true] call A3A_fnc_getEconomyForSide;
private _resourcesValue = _economy getOrDefault ["resources", 0];
private _hrValue = _economy getOrDefault ["hr", 0];

{
	_countGroups = _countGroups + 1;
	switch(side _x) do {
		case teamPlayer:
			{
				_countRebels = _countRebels + 1;
			};
		case Occupants:
			{
				_countOccupants = _countOccupants +	1;
			};
		case Invaders:
			{
				_countInvaders =	_countInvaders + 1;
			};
		case civilian:
			{
				_countCiv = _countCiv + 1;
			};
	};
} forEach allGroups;

private _performanceLog = format [
	"%10 ServerFPS:%1, Players:%11, DeadUnits:%2, AllUnits:%3, UnitsAwareOfEnemies:%14, AllVehicles:%4, WreckedVehicles:%12, Entities:%13, GroupsRebels:%5, GroupsInvaders:%6, GroupsOccupants:%7, GroupsCiv:%8, GroupsTotal:%9, GroupsCombatBehaviour:%15, Faction Cash:%16, HR:%17, OccAggro: %18, InvAggro: %19, Warlevel: %20"
	,diag_fps
	,(count alldead)
	,count allunits
	,count vehicles
	,_countRebels
	,_countInvaders
	,_countOccupants
	,_countCiv
	,_countGroups
	,_message
	,count (allPlayers)
	,{!alive _x} count vehicles
	,count entities ""
	,{!isPlayer _x && !isNull (_x findNearestEnemy _x)} count allUnits
	,{behaviour leader _x == "COMBAT"} count allGroups
        ,_resourcesValue toFixed 0
        ,_hrValue toFixed 0
    ,aggressionOccupants
    ,aggressionInvaders
    ,tierWar
];
Info(_performanceLog);
