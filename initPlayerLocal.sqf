player addEventHandler ["GetInMan", {
	params ["_unit", "_role", "_vehicle", "_turret"];
	if ((typeOf _vehicle) in (getArray (missionConfigFile >> "voiceWarningSystem" >> "west" >> "general"))) then  {
		0 spawn MRTM_fnc_betty;
	};
	if ((typeOf _vehicle) in (getArray (missionConfigFile >> "voiceWarningSystem" >> "east" >> "general"))) then {
		0 spawn MRTM_fnc_rita;
	};
}];