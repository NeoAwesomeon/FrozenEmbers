extends Control

@onready var master_slider: HSlider = $VBoxContainer/GridContainer/MasterSlider
@onready var music_slider: HSlider = $VBoxContainer/GridContainer/MusicSlider
@onready var sfx_slider: HSlider = $VBoxContainer/GridContainer/SFXSlider

@onready var MASTER_BUS_ID = AudioServer.get_bus_index("Master")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")

func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")

func _ready() -> void:
	master_slider.value = GlobalOptionSettings.MASTER_AUDIO
	music_slider.value = GlobalOptionSettings.MUSIC_AUDIO
	sfx_slider.value = GlobalOptionSettings.SFX_AUDIO

func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MASTER_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MASTER_BUS_ID, value < 0.05)
	GlobalOptionSettings.MASTER_AUDIO = value

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < 0.05)
	GlobalOptionSettings.MUSIC_AUDIO = value

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < 0.05)
	GlobalOptionSettings.SFX_AUDIO = value
