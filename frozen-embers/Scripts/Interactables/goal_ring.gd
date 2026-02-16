extends Node3D

@onready var hitbox_area: Area3D = $Hitbox
@onready var hitbox_collision: CollisionShape3D = $Hitbox/CollisionShape3D
@onready var ring_particles: GPUParticles3D = $Hitbox/RingParticles
@onready var lead_particles: GPUParticles3D = $LeadParticles
@onready var lead_timer: Timer = $LeadTimer
@onready var omni_light_3d: OmniLight3D = $OmniLight3D

var counted = false
var lead_sent = false
var lead_speed = 10.0

func _ready() -> void:
	# Hides the ring until it is activated
	hitbox_area.visible = false
	hitbox_collision.disabled = true
	ring_particles.emitting = false
	lead_particles.global_position = get_parent().global_position
	lead_particles.emitting = false
	lead_sent = false
	omni_light_3d.visible = false

func _process(delta: float) -> void:
	# Checks if a variable on the parent is activated, then makes the ring interactable
	if get_parent().start:
		if !counted:
			GlobalLevelStats.REMAINING_RINGS += 1
			counted = true
		hitbox_area.visible = true
		hitbox_collision.disabled = false
		ring_particles.emitting = true
		omni_light_3d.visible = true
		
		if !lead_sent:
			lead_particles.emitting = true
			lead_timer.start()
			lead_sent = true
		if !lead_timer.is_stopped():
			lead_to_ring(delta)


func _on_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		
		GlobalLevelStats.REMAINING_RINGS -= 1
		MusicController.hum_boop.pitch_scale = 1.1 - (GlobalLevelStats.REMAINING_RINGS / 30.0)
		MusicController.play_hum_boop()
		queue_free()

func lead_to_ring(delta):
	var direction: Vector3 = (hitbox_collision.global_position - lead_particles.global_position).normalized()
	
	lead_particles.global_position += direction * lead_speed * delta
	lead_speed += 2.0 * delta

func _on_lead_timer_timeout() -> void:
	lead_particles.emitting = false
