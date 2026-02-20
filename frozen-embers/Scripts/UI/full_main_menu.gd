extends Control

@onready var top_menu: Control = $"Top Menu"
@onready var level_select_menu: Control = $LevelSelectMenu
@onready var options_menu: Control = $OptionsMenu

@onready var MASTER_BUS_ID = AudioServer.get_bus_index("Master")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")

# Used for grab focus
@onready var start_button: Button = $"Top Menu/VBox/Start"
@onready var level_select_button: Button = $"Top Menu/VBox/LevelSelect"
@onready var test_01_button: Button = $LevelSelectMenu/VBoxContainer/HBoxContainer/Test01
@onready var om_return_button: Button = $OptionsMenu/OMReturn

func _ready() -> void:
	get_viewport().size = DisplayServer.screen_get_size()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	top_menu.visible = true
	level_select_menu.visible = false
	options_menu.visible = false
	SpeedrunDisplay.stopwatch_end()
	start_button.grab_focus()

#TOP MENU
func _on_start_pressed() -> void:
	MusicController.play_hum_boop()
	get_tree().change_scene_to_file("res://Scenes/Levels/Testing/testing_world_02.tscn")

func _on_level_select_pressed() -> void:
	MusicController.play_hum_boop()
	top_menu.visible = false
	level_select_menu.visible = true
	test_01_button.grab_focus()

func _on_options_pressed() -> void:
	MusicController.play_hum_boop()
	top_menu.visible = false
	options_menu.visible = true
	om_return_button.grab_focus()

func _on_quit_pressed() -> void:
	MusicController.play_hum_boop()
	get_tree().quit()

#LEVEL SELECT MENU
func _on_lsm_return_pressed() -> void:
	MusicController.play_hum_boop()
	top_menu.visible = true
	level_select_menu.visible = false
	options_menu.visible = false
	level_select_button.grab_focus()

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
func _on_om_return_pressed() -> void:
	MusicController.play_hum_boop()
	top_menu.visible = true
	level_select_menu.visible = false
	options_menu.visible = false
	start_button.grab_focus()

# LINK BUTTONS
func _on_discord_link_pressed() -> void:
	OS.shell_open("https://discord.gg/nsDmJ7mtGe")
	
