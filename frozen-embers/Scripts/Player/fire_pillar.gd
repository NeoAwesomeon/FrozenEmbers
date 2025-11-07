extends Node3D

#Use for height and detection
@onready var hitbox_area: Area3D = $HitboxArea
#Use for width and collision
@onready var hitbox_collision: CollisionShape3D = $HitboxArea/CollisionShape3D

@onready var timer: Timer = $Timer

var given_scale = 1.0

func _ready() -> void:
	given_scale = 1.0 + GlobalPlayerStats.Dive_Count
	hitbox_collision.shape.radius = given_scale * 1.75
	hitbox_area.scale.y = given_scale * 1.1

func _process(delta: float) -> void:
	GlobalPlayerStats.Pillar_Active = true
	
	if timer.is_stopped():
		hitbox_collision.shape.radius -= 1.5 * delta
		hitbox_area.scale.y -= 0.75 * delta
	else:
		hitbox_area.scale.y -= 0.35 * delta
	
	if hitbox_collision.shape.radius < 0.5:
		GlobalPlayerStats.Pillar_Active = false
		GlobalPlayerStats.Dive_Count = 0
		queue_free()
