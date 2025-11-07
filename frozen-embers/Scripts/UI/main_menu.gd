extends Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Testing/testing_world_01.tscn")


func _on_level_select_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/level_select.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/options_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
