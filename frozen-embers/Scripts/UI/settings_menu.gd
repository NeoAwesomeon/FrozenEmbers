extends Control

@onready var display: MarginContainer = $TabContainer/Display

func _process(_delta: float) -> void:
	if GlobalOptionSettings.settings_steal_focus:
		display.grab_focus()
		GlobalOptionSettings.settings_steal_focus = false
