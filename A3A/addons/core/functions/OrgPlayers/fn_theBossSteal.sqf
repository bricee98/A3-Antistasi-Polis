#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params [["_money",100]];
private _titleStr = localize "STR_A3A_fn_orgp_tBSteal_titel";

private _economy = [teamPlayer, true] call A3A_fnc_getEconomyForSide;
_resourcesFIA = _economy getOrDefault ["resources", 0];
if (_resourcesFIA < _money) exitWith {[_titleStr, format [localize "STR_A3A_fn_orgp_tBSteal_grab_no",FactionGet(reb,"name")]] call A3A_fnc_customHint;};
[teamPlayer, -_money, 0, true] call A3A_fnc_updateEconomyForSide;
[-money/50,theBoss] call A3A_fnc_playerScoreAdd;
[_money] call A3A_fnc_resourcesPlayer;

[_titleStr, format [localize "STR_A3A_fn_orgp_tBSteal_grab_yes",str _money,FactionGet(reb,"name")]] call A3A_fnc_customHint;
