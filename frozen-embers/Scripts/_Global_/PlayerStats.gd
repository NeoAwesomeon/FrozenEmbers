extends Node

var PLAYER_CURRENT_SPEED : float
var PLAYER_BOOST_COUNT : int
var PLAYER_GRAVITY : int
var PLAYER_CURRENT_STATE : String

var Heat = 300
var Heat_Max = 600
var Heat_Goal = 600

var Light = -50
var Light_Max = 50
var Light_Min = -50
var Light_Goal = 0

#Goals are the main thing you manipulate, where as the stat alone is most often reserved for visuals or delays

func _process(delta: float) -> void:
	
	# Keeps Heat and Light within desired limits
	if Heat_Goal > Heat_Max:
		Heat_Goal = Heat_Max
	elif Heat_Goal < 0:
		Heat_Goal = 0
	
	if Heat > Heat_Max:
		Heat = Heat_Max
	elif Heat < 0:
		Heat = 0
	
	if Light_Goal > Light_Max - 0.5:
		Light_Goal = Light_Max
	elif Light_Goal < Light_Min + 0.5:
		Light_Goal = Light_Min
	
	# Allows for better easing between values / makes it nicer to use for non-stat related reasons
	if Heat < Heat_Goal:
		Heat += 30 * delta
	elif Heat > Heat_Goal:
		Heat -= 30 * delta
	
	if Light < Light_Goal:
		Light += 30 * delta
	elif Light > Light_Goal:
		Light -= 30 * delta
	
	# Keeps the values from reaching absurd numbers due to the influence of delta
	Light = snapped(Light , 0.5)
	Heat = snapped(Heat , 0.1)
	Heat_Max = snapped(Heat_Max , 0.1)
