extends Node

@onready var test_music: AudioStreamPlayer = $Test_Music

@onready var hum_boop: AudioStreamPlayer = $"UI SFX/HumBoop"

func _ready() -> void:
	play_test_music()

func stop_music():
	test_music.playing = false

func play_test_music():
	stop_music()
	test_music.playing = true

func play_hum_boop():
	hum_boop.playing = true
