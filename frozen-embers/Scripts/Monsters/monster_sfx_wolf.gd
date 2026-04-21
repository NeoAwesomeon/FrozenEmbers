extends Node3D

@onready var wake_up: AudioStreamPlayer3D = $WakeUp
@onready var alert: AudioStreamPlayer3D = $Alert


func _on_spawn_timer_timeout() -> void:
	wake_up.playing = true

func _on_stare_duration_timeout() -> void:
	alert.playing = true
