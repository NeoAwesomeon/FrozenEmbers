extends Node

# THESE ARE JUST FOR DISPLAY AND DO NOT EFFECT THE PLAYER'S STATS! PLAYER STATS ARE ATTACHED TO THE CHARACTER!
var PLAYER_CURRENT_SPEED : float
var PLAYER_BOOST_COUNT : int
var PLAYER_GRAVITY : int
var PLAYER_CURRENT_STATE : String
var PLAYER_HEAT_SHIELD : float

var Player_Position

var Heat = 600.0
var Heat_Max_Start_Value = 600.0
var Heat_Max = Heat_Max_Start_Value
var Heat_Goal = 600.0

var Light = -50.0
var Light_Max = 50.0
var Light_Min = -50.0
var Light_Goal = 0.0

var Freeze = 0.0
var Freeze_Goal = 0.0
var Freeze_Max = Heat_Max_Start_Value

var Dive_Count = 0
var Pillar_Active = false

#Goals are the main thing you manipulate, where as the stat alone is most often reserved for visuals or delays

func _process(delta: float) -> void:
	
	# Keeps Heat and Light within desired limits
	if Heat_Goal > Heat_Max:
		Heat_Goal = Heat_Max
	elif Heat_Goal < 0.0:
		Heat_Goal = 0.0
	
	Heat_Max = Heat_Max_Start_Value - Freeze_Goal
	if Heat > Heat_Max:
		Heat = Heat_Max
	elif Heat < 0.0:
		Heat = 0.0
	
	if Light_Goal > Light_Max - 0.5:
		Light_Goal = Light_Max
	elif Light_Goal < Light_Min + 0.5:
		Light_Goal = Light_Min
	
	# Allows for better easing between values / makes it nicer to use for non-stat related reasons
	if Heat < Heat_Goal:
		Heat += 60.0 * delta
	elif Heat > Heat_Goal:
		Heat -= 60.0 * delta
	
	if Light < Light_Goal:
		Light += 30.0 * delta
	elif Light > Light_Goal:
		Light -= 30.0 * delta
	
	if Freeze < Freeze_Goal:
		Freeze += 90.0 * delta
	
	# Keeps the values from reaching absurd numbers due to the influence of delta
	Light = snapped(Light , 0.5)
	Heat = snapped(Heat , 0.1)
	Heat_Max = snapped(Heat_Max , 0.1)


func reset_player_stats():
	Heat = 600
	Heat_Max = 600
	Heat_Goal = 600
	
	Light = 0
	Light_Max = 50
	Light_Min = -50
	Light_Goal = 0
	
	Freeze = 0
	Freeze_Goal = 0
