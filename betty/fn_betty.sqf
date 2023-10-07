/*
	Author: MrThomasM

	Description: Handles the voice warning system for NATO.
*/

waitUntil {sleep 0.1; (typeOf objectParent player) in (getArray (missionConfigFile >> "voiceWarningSystem" >> "west" >> "general")) || {!(alive player)}};

if !(alive player) exitWith {};
_v = (objectParent player);

_v setVariable ["currentTargets", []];
_v setVariable ["newTargets", []];
_v setVariable ["altCeiling", 2000];
_v setVariable ["isBettyBitching", false];
_v setVariable ["landingGear", true];
_v setVariable ["Incomming", []];

_v addEventHandler ["Gear", {
	params ["_vehicle", "_gearState"];
	_vehicle setVariable ["landingGear", _gearState];
}];
_v addEventHandler ["IncomingMissile", {
	params ["_target", "_ammo", "_vehicle", "_instigator", "_missile"];
	_target setVariable ["Incomming", ((_target getVariable "Incomming") + [_missile])];
}];
_v addEventHandler ["Killed", {
	params ["_unit", "_killer", "_instigator", "_useEffects"];
	_unit removeAllEventHandlers "Gear";
	_unit removeAllEventHandlers "IncomingMissile";
	_unit removeAllEventHandlers "Killed";
}];

0 spawn {
	while {(typeOf (objectParent player) in (getArray (missionConfigFile >> "voiceWarningSystem" >> "west" >> "pullUp"))) && {alive player}} do {
		_v = (objectParent player);
		if !(_v getVariable "isBettyBitching") then {
			if (getPosATL player select 2 <= _v getVariable "altCeiling" && {getPosATL player select 2 > 100 && {_v getVariable "landingGear" == false}}) then {
				if (asin (vectorDir _v select 2) < - (((getPosATL player select 2) * 40) / speed _v)) then {
					playSoundUI ["pullUp", (getMissionConfigValue ["pullUp", 0.3]), 1];
					_v setVariable ["isBettyBitching", true];
					private _startTime = serverTime + 1.33;
					waitUntil {serverTime > _startTime};
					_v setVariable ["isBettyBitching", false];
				};
			};
		};
		private _startTime1 = serverTime + 0.2;  
		waitUntil {serverTime > _startTime1};
	};
};

0 spawn {
	while {(typeOf (objectParent player) in (getArray (missionConfigFile >> "voiceWarningSystem" >> "west" >> "altitude"))) && {alive player}} do {
		_v = (objectParent player);
		if !(_v getVariable "isBettyBitching") then {
			if ((getPosATL player select 2) < 100 && {_v getVariable "landingGear" == false}) then {
				playSoundUI ["altWarning", (getMissionConfigValue ["altitude", 0.3]), 1];
				_v setVariable ["isBettyBitching", true];
				private _startTime = serverTime + 3; 
				waitUntil {serverTime > _startTime};
				_v setVariable ["isBettyBitching", false];
			};
		};
		private _startTime1 = serverTime + 1;  
		waitUntil {serverTime > _startTime1};
	};
};

0 spawn {
	while {(typeOf (objectParent player) in (getArray (missionConfigFile >> "voiceWarningSystem" >> "west" >> "general"))) && {alive player}} do {
		_v = (objectParent player);
		if (fuel _v < 0.2) then {
			playSoundUI ["bingoFuel", (getMissionConfigValue ["fuel", 0.3]), 1];
			_v setVariable ["isBettyBitching", true];
			private _startTime1 = serverTime + 1.6;  
			waitUntil {serverTime > _startTime1};
			_v setVariable ["isBettyBitching", false];				
		};
		private _startTime1 = serverTime + 2;  
		waitUntil {serverTime > _startTime1};
	};
};

//Sensor targets
0 spawn {
	while {(typeOf (objectParent player) in (getArray (missionConfigFile >> "voiceWarningSystem" >> "west" >> "general"))) && {alive player}} do {
		_v = (objectParent player);
		_v setVariable ["newTargets", getSensorTargets _v];
		if (count (_v getVariable "newTargets") > count (_v getVariable "currentTargets")) then {
			playSoundUI ["radarTargetNew", (getMissionConfigValue ["incomming", 0.3]), 1];
			sleep 0.1;
		};

		if (count (_v getVariable "newTargets") < count (_v getVariable "currentTargets")) then {
			playSoundUI ["radarTargetLost", (getMissionConfigValue ["incomming", 0.3]), 1];
			sleep 0.1;
		};
		_v setVariable ["currentTargets", _v getVariable "newTargets"];
		sleep 1;
	};
};

0 spawn {
	while {(typeOf (objectParent player) in (getArray (missionConfigFile >> "voiceWarningSystem" >> "west" >> "general"))) && {alive player}} do {
		_v = (objectParent player);
		if !(_v getVariable "isBettyBitching") then {
			if (count (_v getVariable ["Incomming", []]) > 0) then {
				_v setVariable ["isBettyBitching", true];
				_incomming = ((_v getVariable "Incomming") # 0);
				_mDir = (_v getRelDir _incomming);
				_3Dir = abs (90 - _mDir);
				_6Dir = abs (180 - _mDir);
				_9Dir = abs (270 - _mDir);
				_12Dir = abs (360 - _mDir);
				_0Dir = abs (0 - _mDir);

				_fDir = 0;
				switch (true) do {
					case ((_6Dir < _9Dir) && {(_6Dir < _3Dir) && {(_6Dir < _0Dir) && {(_6Dir < _12Dir)}}}): {
						_fDir = 180;
					};
					case (((_3Dir < _6Dir)) && {(_3Dir < _0Dir) && {(_3Dir < _12Dir) && {(_3Dir < _9Dir)}}}): {
						_fDir = 90;
					};
					case ((_9Dir < _6Dir) && {(_9Dir < _0Dir) && {(_9Dir < _12Dir) && {(_9Dir < _3Dir)}}}): {
						_fDir = 270;
					};
				};
				_sound = format ["incMissile_%1", _fDir];
				playSoundUI [_sound, ((getMissionConfigValue ["incomming", 0.3]) + 0.3), 1];
				sleep 2.3;
				_v setVariable ["isBettyBitching", false];
			};
		};

		{
			_v setVariable ["Incomming", ((_v getVariable "Incomming") - [_x])];
		} forEach ((_v getVariable "Incomming") select {!alive _x});
		sleep 1;
	};
};
