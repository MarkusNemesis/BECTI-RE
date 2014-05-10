private ["_sideID", "_town", "_town_name", "_town_side", "_town_value"];

_town = _this select 0;
_town_name = _this select 1;
_town_side = _this select 2;
_town_value = _this select 3;

_town setVariable ["cti_town_name", _town_name];

waitUntil {!isNil 'CTI_Init_JIP' && !isNil 'CTI_Init_Common'};

_sideID = _town_side call CTI_CO_FNC_GetSideID;
if (CTI_IsServer) then {
	_town setVariable ["cti_town_sideID", _sideID, true];
	_town setVariable ["cti_town_lastSideID", _sideID, true];
	_town setVariable ["cti_town_value", _town_value, true];
	
	(_town) execFSM "Server\FSM\town_capture.fsm";
	(_town) execFSM "Server\FSM\town_resistance.fsm";
	if (missionNamespace getVariable "CTI_TOWNS_OCCUPATION" > 0) then {(_town) execFSM "Server\FSM\town_occupation.fsm"};
};

if (CTI_IsClient) then {
	//--- The client awaits for the MP variable to be available
	waitUntil {!isNil "CTI_Init_Client"};
	
	waitUntil {!(isNil {_town getVariable "cti_town_sideID"}) && !(isNil {_town getVariable "cti_town_lastSideID"})};
	
	//--- We retrieve the current side
	_current_side = (_town getVariable "cti_town_sideID") call CTI_CO_FNC_GetSideFromID;
	
	_coloration = CTI_RESISTANCE_COLOR;
	
	if (CTI_P_SideID in [_town getVariable "cti_town_lastSideID", _town getVariable "cti_town_sideID"]) then { //--- Environment awareness
		_coloration = _current_side call CTI_CO_FNC_GetSideColoration;
	};
	
	//--- Area marker
	_marker = createMarkerLocal [format ["cti_town_areaMarker_%1", _town], getPos _town];
	_marker setMarkerShapeLocal "ELLIPSE"; 
	_marker setMarkerBrushLocal "SolidBorder"; 
	_marker setMarkerSizeLocal [CTI_MARKERS_TOWN_AREA_RANGE, CTI_MARKERS_TOWN_AREA_RANGE]; 
	_marker setMarkerColorLocal _coloration;
	_marker setMarkerAlphaLocal 0.5;
	diag_log format ["%1 marker created for town %2", _marker, _town_name];
	//--- Center marker
	_marker2 = createMarkerLocal [format ["cti_town_marker_%1", _town], getPos _town];
	_marker2 setMarkerTypeLocal "mil_flag";
	_marker2 setMarkerTextLocal format["%1 : %2", _town_name, _town_value];
	_marker2 setMarkerColorLocal _coloration;
	_marker2 setMarkerSizeLocal [1, 1]; 
	// _marker setMarkerAlphaLocal CTI_MARKERS_OPACITY;
};