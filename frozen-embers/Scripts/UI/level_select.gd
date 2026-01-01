extends Control



func _on_return_pressed() -> void:
	MusicController.play_hum_boop()
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")


func _on_test_01_pressed() -> void:
	MusicController.play_hum_boop()
	get_tree().change_scene_to_file("res://Scenes/Levels/Testing/testing_world_01.tscn")


func _on_test_02_pressed() -> void:
	MusicController.play_hum_boop()
	get_tree().change_scene_to_file("res://Scenes/Levels/Testing/testing_world_02.tscn")
