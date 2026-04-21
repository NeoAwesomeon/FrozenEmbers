extends MarginContainer

func _on_auto_resolution_pressed() -> void:
	DisplayServer.screen_get_size()

func _on_resolution_option_button_item_selected(index: int) -> void:
	match index:
		
		#16x9
		0:
			get_viewport().size = Vector2(3840,2160)
		1:
			get_viewport().size = Vector2(3200,1800)
		2:
			get_viewport().size = Vector2(2732,1536)
		3:
			get_viewport().size = Vector2(2560,1440)
		4:
			get_viewport().size = Vector2(1920,1080)
		5:
			get_viewport().size = Vector2(1600,900)
		6:
			get_viewport().size = Vector2(1366,768)
		7:
			get_viewport().size = Vector2(1360,768)
		8:
			get_viewport().size = Vector2(1280,720)
		9:
			get_viewport().size = Vector2(1176,664)
		
		#16x10
		10:
			get_viewport().size = Vector2(3360,2100)
		11:
			get_viewport().size = Vector2(2880,1800)
		12:
			get_viewport().size = Vector2(2560,1600)
		13:
			get_viewport().size = Vector2(1920,1200)
		14:
			get_viewport().size = Vector2(1680,1050)
		15:
			get_viewport().size = Vector2(1600,1024)
		16:
			get_viewport().size = Vector2(1440,900)
		17:
			get_viewport().size = Vector2(1440,960)
		18:
			get_viewport().size = Vector2(1280,768)
		19:
			get_viewport().size = Vector2(1280,800)
		20:
			get_viewport().size = Vector2(720,480)
		
		#21x9
		21:
			get_viewport().size = Vector2(3668,1572)
		22:
			get_viewport().size = Vector2(1834,786)
		


func _on_window_option_button_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
