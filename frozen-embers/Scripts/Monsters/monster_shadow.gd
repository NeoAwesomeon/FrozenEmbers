extends Node3D

@onready var spawn_timer: Timer = $Timers/SpawnTimer
@onready var danger_timer: Timer = $Timers/DangerTimer
@onready var true_kill_timer: Timer = $Timers/TrueKillTimer
@onready var bright_timer: Timer = $Timers/BrightTimer

@onready var height_ray: RayCast3D = $HeightRay

@onready var main_decal: Decal = $Visuals/Decal
@onready var debug_mesh: MeshInstance3D = $Visuals/debug_mesh

@export_category("Frames")
@export var frame_0 : Texture2D
@export var frame_1 : Texture2D
@export var frame_2 : Texture2D
@export var frame_3 : Texture2D
@export var frame_4 : Texture2D
@export var frame_5 : Texture2D
@export var frame_6 : Texture2D
@export var frame_7 : Texture2D
@export var frame_8 : Texture2D
@export var frame_9 : Texture2D
@export var frame_10 : Texture2D

@export_category("Monster Stats")
@export_range(-1, 20) var difficulty : int = 0

var active : bool = false
var progress_lock : bool = false
var target
var kill_progress : int = 0
var banish_count : int = 0

var was_danger : bool = false
var was_killing : bool = false

func _ready() -> void:
	difficulty = GlobalLevelStats.Shadow_Difficulty
	
	GlobalLevelStats.NUMBER_OF_MONSTERS += 1
	active = false
	
	if difficulty == -1:
		queue_free()
	
	main_decal.visible = false
	main_decal.texture_albedo = frame_0
	
	target = get_tree().get_first_node_in_group("player")
	spawn_timer.wait_time = 60.0 - (difficulty * 1.5)
	danger_timer.wait_time = (60.0 - (difficulty * 1.5)) / 10.0
	true_kill_timer.wait_time = 6.0 + (2.0 - difficulty/10.0) 
	
	print_rich("[color=orange]Shadow: Will become active at ([color=white]" + str(GlobalLevelStats.TOTAL_BEACONS - (2 - floori(difficulty/7.5)) -1) + "[color=orange]) Beacons remaining!")

func _physics_process(_delta: float) -> void:
	
	#Keeps the monster near the player at all times visible or not
	global_position = target.global_position
	rotation = target.rotation
	handle_visuals()
	
	handle_banish()
	
	if GlobalLevelStats.REMAINING_BEACONS < GlobalLevelStats.TOTAL_BEACONS - (2 - int(floori(difficulty/7.5))) and !active:
		print_rich("[color=orange]Shadow: [color=white]Active[color=orange]! Progress begins in [color=white]" + str(spawn_timer.wait_time) + "[color=orange] seconds...")
		active = true
		spawn_timer.start()
	
	if Input.is_action_just_pressed("debug_0"):
		print_rich("[color=white]>---<[color=orange]SHADOW CHECKUP[color=white]>---<")
		print_rich("[color=orange]Difficulty = " + str(difficulty))
		print_rich("[color=orange]Active? = " + str(active))
		print_rich("[color=orange]Kill Count = " + str(kill_progress))
		print_rich("[color=orange]Times Banished = " + str(banish_count))

func _on_spawn_timer_timeout() -> void:
	print_rich("[color=orange]Shadow: Danger Active!")
	danger_timer.start()

func _on_danger_timer_timeout() -> void:
	if kill_progress < 10:
		kill_progress += 1
		print_rich("[color=orange]Shadow: Kill Progress at [color=white]" + str(kill_progress) + "[color=orange] of [color=white]10")
	
	if kill_progress == 10:
		true_kill_timer.start()
		danger_timer.stop()

func handle_visuals():
	if !danger_timer.is_stopped():
		main_decal.visible = true
	else:
		main_decal.visible = false
	
	if kill_progress == 0:
		main_decal.texture_albedo = frame_0
	if kill_progress == 1:
		main_decal.texture_albedo = frame_1
	if kill_progress == 2:
		main_decal.texture_albedo = frame_2
	if kill_progress == 3:
		main_decal.texture_albedo = frame_3
	if kill_progress == 4:
		main_decal.texture_albedo = frame_4
	if kill_progress == 5:
		main_decal.texture_albedo = frame_5
	if kill_progress == 6:
		main_decal.texture_albedo = frame_6
	if kill_progress == 7:
		main_decal.texture_albedo = frame_7
	if kill_progress == 8:
		main_decal.texture_albedo = frame_8
	if kill_progress == 9:
		main_decal.texture_albedo = frame_9
	if kill_progress == 10:
		main_decal.texture_albedo = frame_10

func handle_banish():
	if GlobalLevelStats.MAX_NOISE_ACTIVE or GlobalLevelStats.extinguish_responce:
		if GlobalLevelStats.MAX_NOISE_ACTIVE:
			GlobalLevelStats.max_response_count += 1
		if GlobalLevelStats.extinguish_responce:
			GlobalLevelStats.extinguish_responce = false
		
		banish_count += 1
		danger_timer.stop()
		kill_progress = 0
		true_kill_timer.stop()
		spawn_timer.wait_time = 60.0 - (difficulty * 1.5) + 15.0 - (banish_count * 3)
		spawn_timer.start()
		was_danger = false
	

func _on_hurtbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("fire_pillar"):
		kill_progress = 0
		print_rich("[color=orange]Shadow: Kill Progress Cleared!")
	
	if area.is_in_group("warm_area"):
		bright_timer.start()
		if !danger_timer.is_stopped() and spawn_timer.is_stopped():
			danger_timer.stop()
			was_danger = true
		print_rich("[color=orange]Shadow: In Bright Area!")

func _on_hurtbox_area_exited(area: Area3D) -> void:
	if area.is_in_group("warm_area"):
		if spawn_timer.is_stopped() and was_danger:
			danger_timer.start()
			was_danger = false
		bright_timer.stop()
		print_rich("[color=orange]Shadow: Resuming...")

func _on_bright_timer_timeout() -> void:
	if kill_progress > 0:
		kill_progress -= 1
		print_rich("[color=orange]Shadow: Kill Progress at [color=white]" + str(kill_progress) + "[color=orange] of [color=white]10")
