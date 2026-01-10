extends Control

@onready var speedrun_timer: Timer = $SpeedrunTimer
@onready var label: Label = $VBoxContainer/SpeedrunLabel

var milliseconds : int = 0

func stopwatch_start():
	speedrun_timer.start()

func stopwatch_end():
	speedrun_timer.stop()

func stopwatch_reset():
	milliseconds = 0

func convert_time(ms):
	var seconds = (ms / 1000) % 60
	var minutes = (ms / 1000 / 60) % 60
	var milli = (ms % 1000)
	
	return "Time: " + str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2) + ":" + str(milli).pad_zeros(3)

func _on_speedrun_timer_timeout() -> void:
	milliseconds += 50
	label.text = convert_time(milliseconds)
