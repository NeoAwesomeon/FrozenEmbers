extends Area3D

@export_multiline var message : String
@export var duration : float = 5.0
@export var one_shot : bool

func _on_area_entered(area: Area3D) -> void:
	if one_shot:
		if area.is_in_group("player"):
			
			TimedMessage.text = message
			TimedMessage.timer.wait_time = duration
			TimedMessage.timer.start()
			TimedMessage.visible = true
			queue_free()
	
	elif !one_shot:
		TimedMessage.text = message
		TimedMessage.timer.wait_time = duration
		TimedMessage.timer.start()
		TimedMessage.visible = true
