extends CharacterBody3D

@onready var hurtbox: Area3D = $Hurtbox

func _ready() -> void:
	GlobalPlayerStats.Player_Position = hurtbox.global_position

func _on_hurtbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("monster_attack"):
		queue_free()
