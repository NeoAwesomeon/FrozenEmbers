extends Node

@export_group("Initial Resources")
@export_range(-50, 50) var Light = 50
@export_range(0, 600) var Heat = 600
@export_range(0, 600) var Freeze = 0
@export_range(-1000, -1) var Fall_Off = -20

var player_spawn_location : Vector3
var player

func _ready() -> void:
	GlobalPlayerStats.Light = Light
	GlobalPlayerStats.Light_Goal = Light
	GlobalPlayerStats.Heat = Heat
	GlobalPlayerStats.Heat_Goal = Heat
	GlobalPlayerStats.Freeze = Freeze
	GlobalPlayerStats.Freeze_Goal = Freeze
	GlobalLevelStats.FALL_OFF_DISTANCE = Fall_Off
	
	player = get_tree().get_first_node_in_group("player")
	player_spawn_location = player.global_position
