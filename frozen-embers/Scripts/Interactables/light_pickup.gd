extends Node3D

@onready var visuals: Node3D = $Visuals
@onready var collect_hitbox: Area3D = $"Collect Hitbox"
@onready var magnet_hitbox: Area3D = $"Magnet Hitbox"

var collected = false
var speed = 8.0

func _on_magnet_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		collected = true

func _physics_process(delta: float) -> void:
	if !collected: return
	
	var direction: Vector3 = (GlobalPlayerStats.Player_Position - global_position).normalized()
	
	# Floats to player if they slightly miss it. Gets faster over time.
	global_position += direction * speed * delta
	speed += 2.0 * delta

func _on_collect_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		GlobalPlayerStats.Light_Goal += 2
		MusicController.hum_boop.pitch_scale = 1.0
		MusicController.play_hum_boop()
		queue_free()
