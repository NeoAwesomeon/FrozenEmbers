extends Node3D

@onready var hitbox_area: Area3D = $Hitbox
@onready var hitbox_collision: CollisionShape3D = $Hitbox/CollisionShape3D
@onready var particles: GPUParticles3D = $Hitbox/Particles

var counted = false

func _ready() -> void:
	hitbox_area.visible = false
	hitbox_collision.disabled = true
	particles.emitting = false

func _process(_delta: float) -> void:
	if get_parent().start:
		if !counted:
			GlobalLevelStats.REMAINING_RINGS += 1
			counted = true
		hitbox_area.visible = true
		hitbox_collision.disabled = false
		particles.emitting = true

func _on_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		
		GlobalLevelStats.REMAINING_RINGS -= 1
		queue_free()
