extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var visuals: Node3D = $Visuals

#Areas & CollisionShapes
@onready var main_hurtbox: CollisionShape3D = $Hurtbox/MainHurtbox/CollisionShape3D
@onready var hearing_area: CollisionShape3D = $Hurtbox/HearingArea/CollisionShape3D
@onready var vision_area: CollisionShape3D = $Hurtbox/VisionArea/CollisionShape3D

#Raycast3Ds
@onready var ray_parent: Node3D = $Rays
@onready var light_ray: RayCast3D = $Rays/LightRay
@onready var player_ray: RayCast3D = $Rays/PlayerRay

#Timers
@onready var spawn_timer: Timer = $Timers/SpawnTimer
@onready var huh_duration: Timer = $Timers/HuhDuration
@onready var boredom_timer: Timer = $Timers/BoredomTimer

#Determines where the monster will move to, if at all
var target_pos: Vector3
var previous_target_pos: Vector3
var has_target = false
var chase_active = false

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


#Stats
@export_category("Monster Stats")
@export_range(-1, 20) var difficulty = 0
@export var base_move_speed : float = 350.0
@export var adaptation_1 : bool = false
@export var adaptation_2 : bool = false
@export var adaptation_3 : bool = false
@export var adaptation_4 : bool = false

enum States {SPAWN, WANDER, HUH, STARE, CURIOUS, PURSUIT, CHASE, ENDGAME, DESPERATION, STUNNED}
var current_state = States.SPAWN
#Priority Guide: 0=POI, 1=MINOR, 2=MAJOR, 3=MAX, 4=PLAYER, 5=ENDGAME
var priority = 0


func _ready() -> void:
	GlobalLevelStats.NUMBER_OF_MONSTERS += 2
	previous_target_pos = self.global_position
	
	if difficulty == -1:
		queue_free()
	else:
		print("Twins spawning...")
	
	spawn_timer.wait_time = 23.0 - difficulty
	if difficulty < 20:
		huh_duration.wait_time = (2.0 - (difficulty)/10.0) + 1.0
		hearing_area.shape.radius = 5.0 + ((difficulty)/4.0)
	else:
		huh_duration.wait_time = 1.0
		hearing_area.shape.radius = 10.0
	
	vision_area.disabled = true
	hearing_area.disabled = true
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	reset_wander()
	change_speed()
	has_target = true
	vision_area.disabled = false
	hearing_area.disabled = false

func _physics_process(delta: float) -> void:
	
	handle_distance_and_noise()
	handle_state_actions()
	
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

func handle_distance_and_noise():
	#Finds distance from target
	xxx = abs(self.global_position.x - target_pos.x)
	yyy = abs(self.global_position.y - target_pos.y)
	zzz = abs(self.global_position.z - target_pos.z)
	distance_from_target = xxx + yyy + zzz
	
	if current_state != States.SPAWN:
		if distance_from_target < 5 and priority < 4 and priority != 0:
			reset_wander()

func trigger_huh():
	current_state = States.HUH
	huh_duration.start()
	visuals.scale = Vector3(50,50,50)

#Automatic target changing from huh state
func _on_huh_duration_timeout() -> void:
	change_speed()
	boost_count = 0

func change_speed():
	if priority == 4 and !chase_active:
		current_state = States.PURSUIT
	
	elif priority == 3:
		current_state = States.PURSUIT
	
	elif priority < 3 and priority != 0:
		current_state = States.CURIOUS
	
	elif priority == 0:
		current_state = States.WANDER

func reset_wander():
	current_state = States.WANDER
	priority = 0
	boost_count = 0
	previous_target_pos = target_pos
	target_pos = GlobalLevelStats.Points_of_Interest_Wolf.pick_random()
	change_speed()
	
	if target_pos == previous_target_pos:
		reset_wander()
	else:
		boredom_timer.start()

func handle_state_actions():
	match current_state:
		States.SPAWN:
			true_speed = 0
			
		
		States.HUH:
			true_speed = 0
			
		
		States.STARE:
			true_speed = 0
			
		
		States.WANDER:
			true_speed = base_move_speed + (difficulty * 2.5)
			
		
		States.CURIOUS:
			if priority == 1:
				true_speed = (base_move_speed + (difficulty * 2.5)) * 1.25
				
			if priority == 2:
				true_speed = (base_move_speed + (difficulty * 2.5)) * 1.5
				
		
		States.PURSUIT:
			if priority == 3:
				true_speed = (base_move_speed + (difficulty * 2.5)) * 1.5 + (difficulty/2.0 * boost_count)
			if priority == 4:
				true_speed = (base_move_speed + (difficulty * 2.5)) * 1.5 + (difficulty/1.5 * boost_count)
		
		States.CHASE:
			true_speed = (base_move_speed + (difficulty * 2.5)) * 1.5 + (difficulty * boost_count)
		
		States.ENDGAME:
			true_speed = (base_move_speed + (difficulty * 2.5)) * 1.5 + (difficulty * boost_count)

#AREA REACTIONS HERE
func _on_main_hurtbox_area_entered(area: Area3D) -> void:
	#Only awards detective points if an objective is found
	if area.is_in_group("place_of_interest") and priority == 0:
		detective_points += 1
		hearing_area.shape.radius = (5.0 + ((difficulty)/4.0)) + ((difficulty/4.0) * detective_points)
		reset_wander()


func _on_hearing_area_area_entered(area: Area3D) -> void:
	if area.is_in_group("major_noise") and priority < 3:
		trigger_huh()
		priority = 2
		target_pos = area.global_position
		print("Twins: Major Noise Heard")
		
	elif area.is_in_group("minor_noise") and priority < 2:
		trigger_huh()
		priority = 1
		target_pos = area.global_position
		print("Twins: Minor Noise Heard")
		
