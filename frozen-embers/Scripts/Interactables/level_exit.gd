extends Node3D

@onready var visuals: Node3D = $Visuals
@onready var gpu_particles_3d: GPUParticles3D = $Visuals/GPUParticles3D

func _ready() -> void:
	visuals.visible = false
	gpu_particles_3d.emitting = false

func _process(_delta: float) -> void:
	if GlobalLevelStats.EXIT_OPEN:
		visuals.visible = true
		gpu_particles_3d.emitting = true

func _on_interaction_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("player") and GlobalLevelStats.EXIT_OPEN:
		get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
