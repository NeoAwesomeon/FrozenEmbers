extends State

class_name FreedomStatePlayer

@onready var coyote_time: Timer = $"../../Timers/CoyoteTime"
@onready var boost_count_rate: Timer = $"../../Timers/BoostCountRate"

# These variables keep track of the CharacterBody3D's mobility
var player_body
var point_of_view
var movement_velocity: Vector3
var rotation_direction: float

# These variables will constantly change based on how the player acts
var gravity = 0.0
var current_slide = 0.0
var current_boost = 0.0
var boost_count = 0.0
var boost_decay_rate = 0.0
var true_speed_goal = 0.0
var true_speed = 0.0
var is_moving = false
var jump_ground = true
var jump_midair = true
var slide_possible = false

# These variables act as absolute stops in order to lock the player into actions
var move_lock = false
var rotate_lock = false
var slide_lock = false

# These variables will remain static and be used throughout the script
@export_subgroup("Player Stats")
@export var walk_base_speed = 400.0
@export var boost_base_speed = 200.0
@export var slide_base_speed = 200.0
@export var acceleration = 300.0
@export var deceleration = 150.0
@export var jump_strength = 10.0

# This is a secondary state machine used to aid in the transition to other states
enum Modes {GROUNDED, AIRBORNE, CROUCHED, SLIDING}
var mode = Modes.GROUNDED

func enter():
	print("Current State: Freedom")
	point_of_view = get_tree().get_first_node_in_group("player_pov")
	player_body = state_machine.get_parent()
	
	current_slide = slide_base_speed

func physics_update(delta):
	
	
	print(str(boost_count))
	handle_mode_transitions()
	handle_state_machine_transitions()
	handle_boost(delta)
	handle_slide(delta)
	handle_movement(delta)
	handle_gravity(delta)
	handle_global_stats()
	
	# Variable that allows movement to be tracked by script
	var applied_velocity: Vector3
	
	# Converts velocity into usable data while refreshing script and accounting for uncontrolled influences
	applied_velocity = player_body.velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	player_body.velocity = applied_velocity
	player_body.move_and_slide()
	
	# Applies proper rotation to player based on prior code
	if Vector2(player_body.velocity.z, player_body.velocity.x).length() > 0:
		rotation_direction = Vector2(player_body.velocity.z, player_body.velocity.x).angle()
	if !rotate_lock:
		player_body.rotation.y = lerp_angle(player_body.rotation.y, rotation_direction, delta * 10)

func handle_mode_transitions():
	#Allows modes to be entered at any time should the qualifications match
	if player_body.is_on_floor() and is_moving and Input.is_action_pressed("crouch") and slide_possible and true_speed > 400:
		mode = Modes.SLIDING
	elif player_body.is_on_floor() and Input.is_action_pressed("crouch"):
		mode = Modes.CROUCHED
	elif player_body.is_on_floor():
		mode = Modes.GROUNDED
		coyote_time.stop()
	elif !player_body.is_on_floor() and coyote_time.is_stopped():
		coyote_time.start()
	

func handle_state_machine_transitions():
	if mode == 2 and Input.is_action_just_pressed("jump") and jump_ground:
		jump_ground = false
		state_machine.change_state("HighJumpPlayer")
		jump_ground = false

func handle_movement(delta):
	var input := Vector3.ZERO
	
	#Detects if the player is moving
	if Input.is_action_pressed("move_back") or Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		is_moving = true
	else:
		is_moving = false
	
	#Determines true speed based on what state the player is in
	if mode == 2:
		slide_possible = false
		true_speed = walk_base_speed / 2
	elif mode == 3:
		true_speed_goal = walk_base_speed + current_boost + current_slide
	elif is_moving:
		slide_possible = true
		true_speed_goal = walk_base_speed + current_boost
	else:
		true_speed_goal -= deceleration * delta
	
	#Adds ramp up to movement speed based on acceleration
	if true_speed_goal < 0:
		true_speed_goal = 0
	elif true_speed > true_speed_goal:
		true_speed = true_speed_goal
	elif mode == 3:
		true_speed += (acceleration * 3) * delta
	elif true_speed < true_speed_goal:
		true_speed += acceleration * delta
	
	if !move_lock:
		input.x = Input.get_axis("move_left", "move_right")
		input.z = Input.get_axis("move_forward", "move_back")
		# Bases controls on camera angle
		input = input.rotated(Vector3.UP, point_of_view.rotation.y).normalized()
		
		movement_velocity = input * true_speed * delta
	
	if Input.is_action_just_pressed("jump") and mode != 2:
		jump()
		mode = Modes.AIRBORNE

func handle_gravity(delta):
	#Constantly applies gravity to the player that slowly ramps up over time
	gravity += 25 * delta
	#Resets gravity while on the floor and gives a small bit of time for a jump
	if gravity > 0 and player_body.is_on_floor():
		gravity = 0
		if mode != 1:
			jump_ground = true

func handle_boost(delta):
	#If dash button is held
	if Input.is_action_pressed("dash") and mode != 3:
		if boost_count_rate.is_stopped():
			boost_count_rate.start()
		
		#Uses number of timeouts from boost count rate to determine when to change speeds
		if boost_count < 4:
			current_boost = boost_base_speed
		elif boost_count < 8:
			current_boost = boost_base_speed * 2
		else:
			current_boost = boost_base_speed * 3
	
	else:
		boost_count_rate.stop()
		handle_boost_decay(delta)

func _on_boost_count_rate_timeout() -> void:
	boost_count += 1

func handle_boost_decay(delta):
	#Applies increased deceleration based on how fast the player is going
	if current_boost > boost_base_speed * 2:
		boost_decay_rate = 1.5
		boost_count = 8
	elif current_boost > boost_base_speed:
		boost_decay_rate = 1.0
		boost_count = 4
	elif current_boost > 0:
		boost_decay_rate = 0.5
		boost_count = 0
	else:
		boost_decay_rate = 0
		boost_count = 0
	
	#Ensures that boost never excedes limits
	if current_boost > boost_base_speed * 4:
		current_boost = boost_base_speed * 4
	elif current_boost < 0:
		current_boost = 0
	
	#Decreases rate of boost decay if player is sliding
	if current_boost != 0:
		if mode == 3:
			current_boost -= (deceleration / 2) * (boost_decay_rate) * delta
		else:
			current_boost -= deceleration * (boost_decay_rate) * delta

func handle_slide(delta):
	
	#Keeps current slide within wanted limits
	if current_slide > slide_base_speed:
		current_slide = slide_base_speed
	elif current_slide < 0:
		current_slide = 0
	
	if Input.is_action_pressed("crouch"):
		if current_slide < 0.1:
			slide_possible = false
			mode = Modes.CROUCHED
		elif mode == 3:
			if current_boost > 0.1:
				current_slide = slide_base_speed
			else:
				current_slide -= (slide_base_speed) * delta
	else:
		if current_slide < slide_base_speed:
			current_slide += (slide_base_speed / 1.5) * delta

func jump():
	if jump_ground:
		gravity = -jump_strength
		jump_ground = false
		jump_midair = true
		mode = Modes.AIRBORNE
	elif jump_midair:
		gravity = -jump_strength
		jump_midair = false

func _on_coyote_time_timeout() -> void:
	#Before this timer expires, it allows for grounded jump to be used in midair
	if mode != 1:
		mode = Modes.AIRBORNE

func handle_global_stats():
	GlobalPlayerStats.PLAYER_CURRENT_SPEED = true_speed
	
	if mode == 0:
		GlobalPlayerStats.PLAYER_CURRENT_STATE = "Freedom: Grounded"
	elif mode == 1:
		GlobalPlayerStats.PLAYER_CURRENT_STATE = "Freedom: Airborne"
	elif mode == 2:
		GlobalPlayerStats.PLAYER_CURRENT_STATE = "Freedom: Crouching"
	elif mode == 3:
		GlobalPlayerStats.PLAYER_CURRENT_STATE = "Freedom: Sliding"
