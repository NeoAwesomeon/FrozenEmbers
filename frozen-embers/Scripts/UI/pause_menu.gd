extends Control

func _ready() -> void:
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_resume_pressed() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	MusicController.play_hum_boop()
	queue_free()


func _on_restart_pressed() -> void:
	get_tree().paused = false
	MusicController.play_hum_boop()
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	MusicController.play_hum_boop()
	get_tree().change_scene_to_file("res://Scenes/Levels/Final/Level_Menu.tscn")


func _on_close_game_pressed() -> void:
	MusicController.play_hum_boop()
	get_tree().quit()
