extends CharacterBody3D

@onready var visuals: Node3D = $Visuals

#Allows monster to navigate the environment
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

# Area3Ds, CollisionShape3Ds, and Lights
@onready var hearing_area: CollisionShape3D = $Hurtboxes/Hearing/CollisionShape3D
@onready var vision_area: CollisionShape3D = $Hurtboxes/VisionArea/CollisionShape3D
@onready var raycasts: Node3D = $Hurtboxes/Raycasts
@onready var light_vision: RayCast3D = $Hurtboxes/Raycasts/LightVision
@onready var player_vision: RayCast3D = $Hurtboxes/Raycasts/PlayerVision


#Timers
@onready var spawn_timer: Timer = $Timers/SpawnTimer
@onready var huh_timer: Timer = $Timers/HuhTimer
@onready var stare_timer: Timer = $Timers/StareTimer
@onready var boredom_timer: Timer = $Timers/BoredomTimer


#Determines where the monster will move to, if at all
var target_pos: Vector3
var previous_target_pos: Vector3
var has_target = false
var changing_state = false

#Movement Requirements
var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0
var true_speed = 0
var boost_count = 0.0
var detective_points = 0.0
#Used to measure distance from objectives in prefered units
var xxx = 0
var yyy = 0
var zzz = 0
var distance_from_target = 0
#Used for line of sight
var use_vision = false
var hunting_player = false
var staring = false
var stare_target = 0
var CHASE_ACTIVE = false

@export_category("Monster Stats")
@export_range(0, 20) var Difficulty = 1
@export var base_move_speed : float = 350.0

enum States {SPAWN, WANDER, HUH, STARE, CURIOUS, PURSUIT, CHASE, ENDGAME, DESPERATION, STUNNED}
var current_state = States.SPAWN
#Priority Guide: 0=POI, 1=MINOR, 2=MAJOR, 3=MAX, 4=PLAYER, 5=ENDGAME
var priority = 0

func _ready() -> void:
	previous_target_pos = self.global_position
	
	if Difficulty == 0:
		queue_free()
	GlobalLevelStats.NUMBER_OF_MONSTERS += 2
	
	#spawn_timer.wait_time = 23.0 - Difficulty 
	huh_timer.wait_time = (2.0 - Difficulty/10.0) + 1.0
	spawn_timer.start()
	vision_area.disabled = true
	hearing_area.disabled = true
	hearing_area.shape.radius = 5.0 + (Difficulty/4.0)

func _on_spawn_timer_timeout() -> void:
	change_wander_target()
	current_state = States.WANDER
	priority = 0
	has_target = true
	vision_area.disabled = false
	hearing_area.disabled = false

func _physics_process(delta: float) -> void:
	
	#if use_vision:
		#handle_line_of_sight()
	handle_auto_target_change()
	handle_state_transitions()
	handle_state_actions(delta)
	
	visuals.scale = visuals.scale.lerp(Vector3(1, 1, 1), delta * 10)
	
	if has_target:
		nav_agent.target_position = target_pos
		var next_path_pos := nav_agent.get_next_path_position()
		var direction := global_position.direction_to(next_path_pos)
		
		var applied_velocity : Vector3
		
		movement_velocity = direction * true_speed * delta
		applied_velocity = velocity.lerp(movement_velocity, delta * 10)
		applied_velocity.y = -gravity
		velocity = applied_velocity
		
		if nav_agent.is_navigation_finished():
			velocity = Vector3.ZERO
			has_target = false
		
		var rotation_speed = 4
		var target_rotation := direction.signed_angle_to(Vector3.MODEL_FRONT, Vector3.DOWN)
		if abs(target_rotation - rotation.y) > deg_to_rad(60):
				rotation_speed = 20
		rotation.y = move_toward(rotation.y, target_rotation, delta * rotation_speed)
	
	move_and_slide()

func handle_state_transitions():
	#if hunting_player:
		#pass
	
	
	if GlobalLevelStats.MAX_NOISE_ACTIVE and priority < 4 and !player_vision:
			priority = 3
			target_pos = GlobalLevelStats.MAX_NOISE_LOCATION
			GlobalLevelStats.max_response_count += 2
			current_state = States.HUH
			huh_timer.start()
			visuals.scale = Vector3(50,50,50)
	
	if changing_state and (current_state != States.CHASE or current_state != States.ENDGAME):
		if priority == 4 or hunting_player:
			current_state = States.PURSUIT
			changing_state = false
		
		elif priority == 3:
			current_state = States.PURSUIT
			changing_state = false
		
		elif priority < 3 and priority != 0:
			current_state = States.CURIOUS
			changing_state = false
		
		elif priority == 0:
			current_state = States.WANDER
			changing_state = false

func handle_state_actions(_delta):
	match current_state:
		
		States.SPAWN:
			true_speed = 0
		
		States.WANDER:
			true_speed = base_move_speed + (Difficulty * 2.5)
		
		States.HUH:
			true_speed = 0
		
		States.STARE:
			true_speed = 0
		
		States.CURIOUS:
			if priority == 1:
				true_speed = base_move_speed * 1.25
			if priority == 2:
				true_speed = base_move_speed * 1.5
		
		States.PURSUIT:
			if priority == 3:
				true_speed = (base_move_speed * 1.25) + (Difficulty/4.0 * boost_count)
			if priority == 4:
				true_speed = (base_move_speed * 1.25) + (Difficulty/2.0 * boost_count)
		
		States.CHASE:
			true_speed = (base_move_speed * 1.5) + (Difficulty * boost_count)
		
		States.ENDGAME:
			true_speed = (base_move_speed * 1.5) + (Difficulty * boost_count)

func _on_boost_count_rate_timeout() -> void:
	pass

func handle_auto_target_change():
	#Finds distance from target
	xxx = abs(self.global_position.x - target_pos.x)
	yyy = abs(self.global_position.y - target_pos.y)
	zzz = abs(self.global_position.z - target_pos.z)
	distance_from_target = xxx + yyy + zzz
	
	if current_state != States.SPAWN:
		if distance_from_target < 5 and priority < 4 and priority != 0:
			change_wander_target()

func _on_huh_timer_timeout() -> void:
	changing_state = true

#This timer changes the monster's target if it either gets stuck or can't reach its destination in time
func _on_boredom_timer_timeout() -> void:
	change_wander_target()

func change_wander_target():
	priority = 0
	previous_target_pos = target_pos
	target_pos = GlobalLevelStats.Points_of_Interest.pick_random()
	current_state = States.WANDER
	
	if target_pos == previous_target_pos:
		change_wander_target()
	else:
		boredom_timer.start()

func _on_main_body_hurtbox_area_entered(area: Area3D) -> void:
	#Only awards detective points if an objective is found
	if area.is_in_group("place_of_interest") and priority == 0:
		detective_points += 1
		hearing_area.shape.radius = 25.0 + ((Difficulty/4.0) * detective_points)
		change_wander_target()

func _on_hearing_area_entered(area: Area3D) -> void:
	#If the monster isn't following a big lead, it will hunt down noise areas.
	if area.is_in_group("major_noise") and priority < 3:
		current_state = States.HUH
		huh_timer.start()
		priority = 2
		target_pos = area.global_position
		visuals.scale = Vector3(50,50,50)
	elif area.is_in_group("minor_noise") and priority < 2:
		current_state = States.HUH
		huh_timer.start()
		priority = 1
		target_pos = area.global_position
		visuals.scale = Vector3(50,50,50)

func _on_vision_area_entered(area: Area3D) -> void:
	if area.is_in_group("player_light"):
		use_vision = true
		light_vision.enabled = true

func _on_vision_area_exited(area: Area3D) -> void:
	if area.is_in_group("player_light"):
		use_vision = false
		light_vision.enabled = false

func handle_line_of_sight():
	raycasts.look_at(GlobalPlayerStats.Player_Position)
	
	if light_vision.is_colliding():
		var vision_target = light_vision.get_collider()
		
		if vision_target.is_in_group("player_light") and !CHASE_ACTIVE:
			player_vision.enabled = true
			hunting_player = true
			current_state = States.HUH
			huh_timer.start()
			priority = 3
			visuals.scale = Vector3(50,50,50)
			
		else:
			player_vision.enabled = false
	
	if player_vision.is_colliding():
		var vision_target = player_vision.get_collider()
		
		if vision_target.is_in_group("player") and !CHASE_ACTIVE:
			hunting_player = true
			priority = 4
			visuals.scale = Vector3(50,50,50)
			stare_target = distance_from_target
