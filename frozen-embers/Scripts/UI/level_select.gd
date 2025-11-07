extends Control

@onready var test_00: Button = $VBoxContainer/HBoxContainer/Test00



func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")


func _on_test_01_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Testing/testing_world_01.tscn")
