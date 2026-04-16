extends Control

# This is here to enure controllers work on pause
@onready var resume: Button = $PauseMain/VBoxContainer/Resume
@onready var om_return: Button = $OptionsMenu/OMReturn

@onready var pause_main: Panel = $PauseMain
@onready var options_menu: Control = $OptionsMenu

@onready var unpause_delay: Timer = $UnpauseDelay

func _ready() -> void:
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	options_menu.visible = false
	resume.grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		unpause_delay.start()
		MusicController.play_hum_boop()

func _on_resume_pressed() -> void:
	get_tree().paused = false
	unpause_delay.start()
	MusicController.play_hum_boop()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	MusicController.play_hum_boop()
	get_tree().reload_current_scene()

func _on_options_pressed() -> void:
	pause_main.visible = false
	options_menu.visible = true
	om_return.grab_focus()
	MusicController.play_hum_boop()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	MusicController.play_hum_boop()
	get_tree().change_scene_to_file("res://Scenes/Levels/Final/Level_Menu.tscn")

func _on_close_game_pressed() -> void:
	MusicController.play_hum_boop()
	get_tree().quit()

func _on_om_return_pressed() -> void:
	pause_main.visible = true
	options_menu.visible = false
	resume.grab_focus()
	MusicController.play_hum_boop()


func _on_unpause_delay_timeout() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_free()
