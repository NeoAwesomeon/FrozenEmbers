extends VBoxContainer

func _on_run_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		GlobalOptionSettings.accessability_toggle_run = true
	else:
		GlobalOptionSettings.accessability_toggle_run = false

func _on_parry_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		GlobalOptionSettings.accessability_auto_parry = true
	else:
		GlobalOptionSettings.accessability_auto_parry = false
