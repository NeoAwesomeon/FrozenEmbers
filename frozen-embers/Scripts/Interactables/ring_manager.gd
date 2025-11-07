extends Node3D

var start = false

func _on_goal_beacon_activate_rings() -> void:
	start = true
