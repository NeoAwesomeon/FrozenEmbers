extends Area3D

@onready var timer: Timer = $Timer

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("monster"):
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()
