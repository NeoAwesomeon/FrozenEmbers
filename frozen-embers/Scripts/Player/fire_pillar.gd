extends Node3D

#Use for height and detection
@onready var hitbox_area: Area3D = $HitboxArea
#Use for width and collision
@onready var hitbox_collision: CollisionShape3D = $HitboxArea/CollisionShape3D
@onready var visuals: Node3D = $Visuals

@onready var timer: Timer = $Timer

var given_scale = 1.0

func _ready() -> void:
	given_scale = 1.0 + GlobalPlayerStats.Dive_Count
	hitbox_collision.shape.radius = given_scale * 1.75
	hitbox_area.scale.y = given_scale * 1.2
	visuals.scale = Vector3(given_scale * 1.75, given_scale * 1.75, given_scale * 1.75) 

func _process(delta: float) -> void:
	# Ensures only one pillar can exist at a time
	GlobalPlayerStats.Pillar_Active = true
	
	# Timer autostarts and maintains width for a time, only reducing height until after the timer ends
	if timer.is_stopped():
		hitbox_collision.shape.radius -= 1.5 * delta
		visuals.scale.x -= 1.6 * delta
		visuals.scale.z -= 1.6 * delta
		
		hitbox_area.scale.y -= 0.75 * delta
		visuals.scale.y -= 0.76 * delta
	else:
		hitbox_area.scale.y -= 0.25 * delta
		visuals.scale.y -= 0.26 * delta
	
	# Destroys the pillar if it gets too small
	if hitbox_collision.shape.radius < 0.5:
		GlobalPlayerStats.Pillar_Active = false
		GlobalPlayerStats.Dive_Count = 0
		queue_free()
