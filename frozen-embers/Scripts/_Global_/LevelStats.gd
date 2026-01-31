extends Node

var TOTAL_BEACONS : int
var REMAINING_BEACONS : int
var REMAINING_RINGS : int

var FALL_OFF_DISTANCE : float = -1000.0
var RESPAWN_LOCATION : Vector3

var EXIT_LOCATION : Vector3
var EXIT_OPEN = false

var NUMBER_OF_MONSTERS : int
var MAX_NOISE_ACTIVE = false
var MAX_NOISE_LOCATION : Vector3
var max_response_count = 0

var frame_delay : float
var frame_count = 0.0

var Points_of_Interest_Wolf = []

func _ready() -> void:
	RESPAWN_LOCATION = Vector3.ZERO

func _process(_delta: float) -> void:
	if max_response_count == NUMBER_OF_MONSTERS or max_response_count > NUMBER_OF_MONSTERS:
		MAX_NOISE_ACTIVE = false
		max_response_count = 0
