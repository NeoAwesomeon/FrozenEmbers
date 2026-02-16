extends Node3D

@onready var visuals: Node3D = $Visuals
@onready var gpu_particles_3d: GPUParticles3D = $Visuals/GPUParticles3D

var hold_up = false

func _ready() -> void:
	visuals.visible = false
	gpu_particles_3d.emitting = false
	GlobalLevelStats.EXIT_LOCATION = self.global_position
	GlobalLevelStats.EXIT_OPEN = false

func _process(_delta: float) -> void:
	# Exit is only visible if all beacons are complete
	if GlobalLevelStats.EXIT_OPEN:
		visuals.visible = true
		gpu_particles_3d.emitting = true
		# This is here as a small 1 frame buffer to ensure everything is cleared out before leaving the level
		if hold_up:
			exit_level()

func _on_interaction_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("player") and GlobalLevelStats.EXIT_OPEN:
		hold_up = true

func exit_level():
	SpeedrunDisplay.stopwatch_end()
	get_tree().change_scene_to_file("res://Scenes/Levels/Final/Level_Menu.tscn")
