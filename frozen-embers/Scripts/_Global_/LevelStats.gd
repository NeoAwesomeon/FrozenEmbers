extends Node

var TOTAL_BEACONS : int
var REMAINING_BEACONS : int
var REMAINING_RINGS : int

var FALL_OFF_DISTANCE : float = -1000.0
var RESPAWN_LOCATION : Vector3

var EXIT_LOCATION : Vector3
var EXIT_OPEN = false

var frame_delay : float
var frame_count = 0.0

func _ready() -> void:
	RESPAWN_LOCATION = Vector3.ZERO
