@tool
extends Node3D

@onready var ring_manager: Node3D = $RingManager
@onready var delay_timer: Timer = $Main/DelayTimer
@onready var warm_hitbox: CollisionShape3D = $Main/WarmthHitbox/CollisionShape3D
@onready var warm_timer: Timer = $Main/WarmthHitbox/WarmTimer
@onready var warm_visual: GPUParticles3D = $Main/WarmthHitbox/WarmVisual

@onready var wavy: AudioStreamPlayer3D = $Main/SFX/Wavy
@onready var gong: AudioStreamPlayer = $Main/SFX/Gong
@onready var alight_particles: GPUParticles3D = $Main/Visuals/AlightParticles
@onready var omni_light_3d: OmniLight3D = $Main/Visuals/OmniLight3D
@onready var respawn_point: Marker3D = $Main/RespawnPoint

@export var number_of_rings: int = 1
var marker_que = 0
var ring_que = 0
@export var ring_scene : PackedScene
@export_tool_button("Confirm") var run_action = create_markers

signal activate_rings

var active = false
var delay_complete = false
var completed = false
var level_credit = false

func create_markers():
	for old_spawn in ring_manager.get_children():
		ring_manager.remove_child(old_spawn)
		old_spawn.queue_free()
	
	marker_que = number_of_rings
	ring_que = number_of_rings

func _ready() -> void:
	# Works out of editor
	if not Engine.is_editor_hint():
		GlobalLevelStats.TOTAL_BEACONS += 1
		GlobalLevelStats.REMAINING_BEACONS += 1
		warm_hitbox.disabled = true
		warm_visual.emitting = false
		alight_particles.emitting = false
		omni_light_3d.light_energy = 0.2
		
		if GlobalLevelStats.Wolf_Difficulty > -1:
			GlobalLevelStats.Points_of_Interest_Wolf.append(self.global_position)

func _process(_delta: float) -> void:
	# Works in editor
	# Spawning the markers
	if Engine.is_editor_hint() and marker_que > 0:
		
		var marker = ring_scene.instantiate()
		ring_manager.add_child(marker)
		marker.name = "GoalRing" + str(marker_que)
		marker.owner = get_tree().edited_scene_root
		
		marker_que -= 1
	
	# Works out of Editor
	elif not Engine.is_editor_hint():
		
		# Tells Manager to activate the rings
		if active:
			# Adds a small delay so that the beacon isn't completed instantly
			if !delay_complete and delay_timer.is_stopped():
				delay_timer.start()
			activate_rings.emit()
		

func _on_interaction_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		if !active:
			wavy.playing = true
		active = true
		
		if completed:
			GlobalLevelStats.RESPAWN_LOCATION = respawn_point.global_position

func _on_warmth_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		warm_timer.start()
func _on_warmth_hitbox_area_exited(area: Area3D) -> void:
	if area.is_in_group("player"):
		warm_timer.stop()

func _on_warm_timer_timeout() -> void:
	GlobalPlayerStats.Light_Goal += 0.5
	GlobalPlayerStats.Heat_Goal += 2.5


func _on_delay_timer_timeout() -> void:
	delay_complete = true


func _on_ring_manager_completed() -> void:
	if not Engine.is_editor_hint():
		if active and delay_complete:
			completed = true
			
			if !level_credit:
				warm_hitbox.disabled = false
				warm_visual.emitting = true
				alight_particles.emitting = true
				omni_light_3d.light_energy = 3.0
				GlobalLevelStats.REMAINING_BEACONS -= 1
				gong.playing = true
				level_credit = true
				GlobalLevelStats.RESPAWN_LOCATION = respawn_point.global_position
				GlobalLevelStats.Points_of_Interest_Wolf.erase(self.global_position)
				
				if GlobalLevelStats.REMAINING_BEACONS < 1:
					GlobalLevelStats.EXIT_OPEN = true
