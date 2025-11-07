@tool
extends Node3D

@onready var ring_manager: Node3D = $RingManager
@onready var delay_timer: Timer = $DelayTimer
@onready var warm_hitbox: CollisionShape3D = $WarmthHitbox/CollisionShape3D
@onready var warm_timer: Timer = $WarmthHitbox/WarmTimer
@onready var warm_visual: GPUParticles3D = $WarmthHitbox/WarmVisual

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
		
		# Collecting every ring
		if GlobalLevelStats.REMAINING_RINGS < 1 and active and delay_complete:
			completed = true
			warm_hitbox.disabled = false
			warm_visual.emitting = true
			if !level_credit:
				GlobalLevelStats.REMAINING_BEACONS -= 1
				level_credit = true

func _on_interaction_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		active = true

func _on_warmth_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		warm_timer.start()
func _on_warmth_hitbox_area_exited(area: Area3D) -> void:
	if area.is_in_group("player"):
		warm_timer.stop()

func _on_warm_timer_timeout() -> void:
	GlobalPlayerStats.Light_Goal += 1
	GlobalPlayerStats.Heat_Goal += 5


func _on_delay_timer_timeout() -> void:
	delay_complete = true
