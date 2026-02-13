extends Node

@export_group("Initial Resources")
@export_range(-50, 50) var Light = 50
@export_range(0, 600) var Heat = 600
@export_range(0, 600) var Freeze = 0
@export_range(-1000, -1) var Fall_Off = -20
@export_group("Monster Levels")
@export_range(-1, 20) var Wolf_Difficulty = 0

var player
var force_heat

func _ready() -> void:
	#Working
	GlobalLevelStats.REMAINING_BEACONS = 0
	GlobalLevelStats.REMAINING_RINGS = 0
	GlobalPlayerStats.Freeze_Goal = Freeze
	GlobalPlayerStats.Freeze = Freeze
	GlobalPlayerStats.Light_Goal = Light
	GlobalPlayerStats.Light = Light
	GlobalLevelStats.Wolf_Difficulty = Wolf_Difficulty
	
	#Not Working!?
	GlobalPlayerStats.Heat_Goal = Heat
	GlobalPlayerStats.Heat = Heat
	
	GlobalLevelStats.FALL_OFF_DISTANCE = Fall_Off
	
	player = get_tree().get_first_node_in_group("player")
	
	SpeedrunDisplay.stopwatch_reset()
	SpeedrunDisplay.stopwatch_start()

func _process(_delta: float) -> void:
	if !force_heat:
		GlobalPlayerStats.Heat_Goal = Heat
		GlobalPlayerStats.Heat = Heat
		force_heat = true
	else:
		pass
