extends Control

@onready var custom_override: CheckBox = $PanelContainer/VBoxContainer/CustomOverride

@onready var wolf_level_label: Label = $PanelContainer/VBoxContainer/GridContainer/Wolf/MonsterLevel

@onready var smog_level_label: Label = $PanelContainer/VBoxContainer/GridContainer/Smog/MonsterLevel

@onready var shadow_level_label: Label = $PanelContainer/VBoxContainer/GridContainer/Shadow/MonsterLevel

@onready var bear_level_label: Label = $PanelContainer/VBoxContainer/GridContainer/Bear/MonsterLevel


func _ready() -> void:
	if CustomNightSettings.CUSTOM_NIGHT_ENABLED:
		custom_override.button_pressed = true
	else:
		custom_override.button_pressed = false
	
	
	if CustomNightSettings.CN_Wolf_Difficulty == 0:
		wolf_level_label.text = "> MIN <"
	elif CustomNightSettings.CN_Smog_Difficulty == -1:
		wolf_level_label.text = "> OFF <"
	elif CustomNightSettings.CN_Wolf_Difficulty == 21:
		wolf_level_label.text = "> MAX <"
	else:
		wolf_level_label.text = "> " + str(CustomNightSettings.CN_Wolf_Difficulty) + " <"
	
	if CustomNightSettings.CN_Smog_Difficulty == 0:
		smog_level_label.text = "> MIN <"
	elif CustomNightSettings.CN_Smog_Difficulty == -1:
		smog_level_label.text = "> OFF <"
	elif CustomNightSettings.CN_Smog_Difficulty == 21:
		smog_level_label.text = "> MAX <"
	else:
		smog_level_label.text = "> " + str(CustomNightSettings.CN_Smog_Difficulty) + " <"
	

func _on_custom_override_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CustomNightSettings.CUSTOM_NIGHT_ENABLED = true
	else:
		CustomNightSettings.CUSTOM_NIGHT_ENABLED = false


# WOLF
func _on_w_minus_pressed() -> void:
	if CustomNightSettings.CN_Wolf_Difficulty > -1:
		CustomNightSettings.CN_Wolf_Difficulty -= 1
		
		if CustomNightSettings.CN_Wolf_Difficulty == 0:
			wolf_level_label.text = "> MIN <"
		elif CustomNightSettings.CN_Wolf_Difficulty == -1:
			wolf_level_label.text = "> OFF <"
		else:
			wolf_level_label.text = "> " + str(CustomNightSettings.CN_Wolf_Difficulty) + " <"

func _on_w_plus_pressed() -> void:
	if CustomNightSettings.CN_Wolf_Difficulty < 20:
		CustomNightSettings.CN_Wolf_Difficulty += 1
	
	if CustomNightSettings.CN_Wolf_Difficulty == 21:
		wolf_level_label.text = "> MAX <"
	elif CustomNightSettings.CN_Wolf_Difficulty == 0:
			wolf_level_label.text = "> MIN <"
	else:
		wolf_level_label.text = "> " + str(CustomNightSettings.CN_Wolf_Difficulty) + " <"

func _on_w_adept_1_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CustomNightSettings.CN_Wolf_Adept_1 = true
	else:
		CustomNightSettings.CN_Wolf_Adept_1 = false

func _on_w_adept_2_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CustomNightSettings.CN_Wolf_Adept_2 = true
	else:
		CustomNightSettings.CN_Wolf_Adept_2 = false

func _on_w_adept_3_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CustomNightSettings.CN_Wolf_Adept_3 = true
	else:
		CustomNightSettings.CN_Wolf_Adept_3 = false

func _on_w_adept_4_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CustomNightSettings.CN_Wolf_Adept_4 = true
	else:
		CustomNightSettings.CN_Wolf_Adept_4 = false


# SMOG
func _on_s_minus_pressed() -> void:
	if CustomNightSettings.CN_Smog_Difficulty > -1:
		CustomNightSettings.CN_Smog_Difficulty -= 1
		
		if CustomNightSettings.CN_Smog_Difficulty == 0:
			smog_level_label.text = "> MIN <"
		elif CustomNightSettings.CN_Smog_Difficulty == -1:
			smog_level_label.text = "> OFF <"
		else:
			smog_level_label.text = "> " + str(CustomNightSettings.CN_Smog_Difficulty) + " <"

func _on_s_plus_pressed() -> void:
	if CustomNightSettings.CN_Smog_Difficulty < 20:
		CustomNightSettings.CN_Smog_Difficulty += 1
	
	if CustomNightSettings.CN_Smog_Difficulty == 21:
		smog_level_label.text = "> MAX <"
	elif CustomNightSettings.CN_Smog_Difficulty == 0:
			smog_level_label.text = "> MIN <"
	else:
		smog_level_label.text = "> " + str(CustomNightSettings.CN_Smog_Difficulty) + " <"

func _on_s_adept_1_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CustomNightSettings.CN_Smog_Adept_1 = true
	else:
		CustomNightSettings.CN_Smog_Adept_1 = false

func _on_s_adept_2_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CustomNightSettings.CN_Smog_Adept_2 = true
	else:
		CustomNightSettings.CN_Smog_Adept_2 = false

func _on_s_adept_3_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CustomNightSettings.CN_Smog_Adept_3 = true
	else:
		CustomNightSettings.CN_Smog_Adept_3 = false

func _on_s_adept_4_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CustomNightSettings.CN_Smog_Adept_4 = true
	else:
		CustomNightSettings.CN_Smog_Adept_4 = false


#SHADOW
func _on_sh_minus_button_down() -> void:
	if CustomNightSettings.CN_Shadow_Difficulty > -1:
		CustomNightSettings.CN_Shadow_Difficulty -= 1
		
		if CustomNightSettings.CN_Shadow_Difficulty == 0:
			shadow_level_label.text = "> MIN <"
		elif CustomNightSettings.CN_Shadow_Difficulty == -1:
			shadow_level_label.text = "> OFF <"
		else:
			shadow_level_label.text = "> " + str(CustomNightSettings.CN_Shadow_Difficulty) + " <"

func _on_sh_plus_button_down() -> void:
	if CustomNightSettings.CN_Shadow_Difficulty < 20:
		CustomNightSettings.CN_Shadow_Difficulty += 1
	
	if CustomNightSettings.CN_Shadow_Difficulty == 21:
		shadow_level_label.text = "> MAX <"
	elif CustomNightSettings.CN_Smog_Difficulty == 0:
			shadow_level_label.text = "> MIN <"
	else:
		shadow_level_label.text = "> " + str(CustomNightSettings.CN_Shadow_Difficulty) + " <"

func _on_sh_adept_1_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CustomNightSettings.CN_Shadow_Adept_1 = true
	else:
		CustomNightSettings.CN_Shadow_Adept_1 = false

func _on_sh_adept_2_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CustomNightSettings.CN_Shadow_Adept_2 = true
	else:
		CustomNightSettings.CN_Shadow_Adept_2 = false

func _on_sh_adept_3_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CustomNightSettings.CN_Shadow_Adept_3 = true
	else:
		CustomNightSettings.CN_Shadow_Adept_3 = false

func _on_sh_adept_4_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CustomNightSettings.CN_Shadow_Adept_4 = true
	else:
		CustomNightSettings.CN_Shadow_Adept_4 = false

#BEAR
func _on_b_minus_button_down() -> void:
	if CustomNightSettings.CN_Bear_Difficulty > -1:
		CustomNightSettings.CN_Bear_Difficulty -= 1
		
		if CustomNightSettings.CN_Bear_Difficulty == 0:
			bear_level_label.text = "> MIN <"
		elif CustomNightSettings.CN_Bear_Difficulty == -1:
			bear_level_label.text = "> OFF <"
		else:
			bear_level_label.text = "> " + str(CustomNightSettings.CN_Bear_Difficulty) + " <"
	
func _on_b_plus_button_down() -> void:
	if CustomNightSettings.CN_Bear_Difficulty < 20:
		CustomNightSettings.CN_Bear_Difficulty += 1
	
	if CustomNightSettings.CN_Bear_Difficulty == 21:
		bear_level_label.text = "> MAX <"
	elif CustomNightSettings.CN_Smog_Difficulty == 0:
			bear_level_label.text = "> MIN <"
	else:
		bear_level_label.text = "> " + str(CustomNightSettings.CN_Bear_Difficulty) + " <"

func _on_b_adept_1_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CustomNightSettings.CN_Bear_Adept_1 = true
	else:
		CustomNightSettings.CN_Bear_Adept_1 = false

func _on_b_adept_2_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CustomNightSettings.CN_Bear_Adept_2 = true
	else:
		CustomNightSettings.CN_Bear_Adept_2 = false

func _on_b_adept_3_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CustomNightSettings.CN_Bear_Adept_3 = true
	else:
		CustomNightSettings.CN_Bear_Adept_3 = false

func _on_b_adept_4_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CustomNightSettings.CN_Bear_Adept_4 = true
	else:
		CustomNightSettings.CN_Bear_Adept_4 = false
