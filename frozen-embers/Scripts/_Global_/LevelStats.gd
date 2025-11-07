extends Node

var TOTAL_BEACONS : int
var REMAINING_BEACONS : int

var REMAINING_RINGS : int

var EXIT_OPEN = false

func _process(_delta: float) -> void:
	if GlobalLevelStats.REMAINING_BEACONS < 1:
		EXIT_OPEN = true
	else:
		EXIT_OPEN = false
	
