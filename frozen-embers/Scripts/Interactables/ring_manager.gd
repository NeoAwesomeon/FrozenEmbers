extends Node3D

var start = false
var rings : int

signal completed

func _on_goal_beacon_activate_rings() -> void:
	start = true
	
	rings = get_child_count()
	
	if rings < 1:
		completed.emit()
