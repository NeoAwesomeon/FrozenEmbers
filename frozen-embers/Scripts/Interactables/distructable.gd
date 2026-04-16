extends CSGBox3D

func _on_hurtbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("player_attack"):
		queue_free()
