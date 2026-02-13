extends Control

@onready var top_menu: Control = $"Top Menu"
@onready var level_select_menu: Control = $LevelSelectMenu
@onready var options_menu: Control = $OptionsMenu

@onready var MASTER_BUS_ID = AudioServer.get_bus_index("Master")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	top_menu.visible = true
	level_select_menu.visible = false
	options_menu.visible = false
	SpeedrunDisplay.stopwatch_end()

#TOP MENU
func _on_start_pressed() -> void:
	MusicController.play_hum_boop()
	get_tree().change_scene_to_file("res://Scenes/Levels/Testing/testing_world_02.tscn")

func _on_level_select_pressed() -> void:
	MusicController.play_hum_boop()
	top_menu.visible = false
	level_select_menu.visible = true

func _on_options_pressed() -> void:
	MusicController.play_hum_boop()
	top_menu.visible = false
	options_menu.visible = true

func _on_quit_pressed() -> void:
	MusicController.play_hum_boop()
	get_tree().quit()

#LEVEL SELECT MENU
func _on_lsm_return_pressed() -> void:
	MusicController.play_hum_boop()
	top_menu.visible = true
	level_select_menu.visible = false
	options_menu.visible = false

func _on_test_01_pressed() -> void:
	MusicController.play_hum_boop()
	get_tree().change_scene_to_file("res://Scenes/Levels/Testing/testing_world_01.tscn")

func _on_test_02_pressed() -> void:
	MusicController.play_hum_boop()
	get_tree().change_scene_to_file("res://Scenes/Levels/Testing/testing_world_02.tscn")

func _on_test_03_pressed() -> void:
	MusicController.play_hum_boop()
	get_tree().change_scene_to_file("res://Scenes/Levels/Testing/testing_world_03.tscn")

#OPTIONS MENU
func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MASTER_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MASTER_BUS_ID, value < 0.05)
	GlobalOptionSettings.MASTER_AUDIO = value
	MusicController.play_hum_boop()

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < 0.05)
	GlobalOptionSettings.MUSIC_AUDIO = value
	MusicController.play_hum_boop()

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < 0.05)
	GlobalOptionSettings.SFX_AUDIO = value
	MusicController.play_hum_boop()

func _on_om_return_pressed() -> void:
	MusicController.play_hum_boop()
	top_menu.visible = true
	level_select_menu.visible = false
	options_menu.visible = false

# LINK BUTTONS
func _on_discord_link_pressed() -> void:
	OS.shell_open("https://discord.gg/nsDmJ7mtGe")
	
