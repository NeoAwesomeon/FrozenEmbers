extends MarginContainer


func _on_resolution_option_button_item_selected(index: int) -> void:
	match index:
		0:
			get_viewport().size = Vector2(1920,1080)
		1:
			get_viewport().size = Vector2(1600,900)
		2:
			get_viewport().size = Vector2(1366,768)
		3:
			get_viewport().size = Vector2(1360,768)
		4:
			get_viewport().size = Vector2(1280,720)
		5:
			get_viewport().size = Vector2(1176,664)
		6:
			get_viewport().size = Vector2(1680,1050)
		7:
			get_viewport().size = Vector2(1600,1024)
		8:
			get_viewport().size = Vector2(1440,960)
		9:
			get_viewport().size = Vector2(1440,900)
		10:
			get_viewport().size = Vector2(1280,800)
		11:
			get_viewport().size = Vector2(1280,768)
		12:
			get_viewport().size = Vector2(720,480)
		13:
			get_viewport().size = Vector2(1834,786)


func _on_window_option_button_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
