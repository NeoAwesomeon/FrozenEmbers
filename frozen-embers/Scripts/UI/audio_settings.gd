extends VBoxContainer

# Audio Bus
@onready var MASTER_BUS_ID = AudioServer.get_bus_index("Master")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")

# Volume Slider Labels
@onready var master_label: Label = $MasterLabel
@onready var music_label: Label = $MusicLabel
@onready var sfx_label: Label = $SFXLabel

# AUDIO CONTROL
func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MASTER_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MASTER_BUS_ID, value < 0.01)
	GlobalOptionSettings.MASTER_AUDIO = value
	MusicController.play_hum_boop()
	master_label.text = "Master Volume: " + str(value * 10) + "%"
	master_label.text = master_label.text.remove_chars(".")

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < 0.01)
	GlobalOptionSettings.MUSIC_AUDIO = value
	MusicController.play_hum_boop()
	music_label.text = "Music Volume: " + str(value * 10) + "%"
	music_label.text = music_label.text.remove_chars(".")

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < 0.01)
	GlobalOptionSettings.SFX_AUDIO = value
	MusicController.play_hum_boop()
	sfx_label.text = "Sound Effects Volume: " + str(value * 10) + "%"
	sfx_label.text = sfx_label.text.remove_chars(".")
