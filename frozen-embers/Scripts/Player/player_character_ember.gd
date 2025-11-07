extends CharacterBody3D

# Timers
@onready var heat_timer: Timer = $Timers/HeatTimer
@onready var coyote_time: Timer = $Timers/CoyoteTime
@onready var boost_count_rate: Timer = $Timers/BoostCountRate
@onready var slide_duration: Timer = $Timers/SlideDuration
@onready var slide_cooldown: Timer = $Timers/SlideCooldown
@onready var ignore_walls_timer: Timer = $Timers/IgnoreWalls
@onready var wall_jump_duration: Timer = $Timers/WallJumpDuration
@onready var hard_landing_recovery: Timer = $Timers/HardLandingRecovery
@onready var attack_recovery: Timer = $Timers/AttackRecovery
@onready var hitbox_duration: Timer = $Timers/AttackRecovery/HitboxDuration
@onready var ledge_cooldown: Timer = $Timers/LedgeCooldown
@onready var reignite_duration: Timer = $Timers/ReigniteDuration
@onready var extinguish_duration: Timer = $Timers/ExtinguishDuration
@onready var heat_shield_duration: Timer = $Timers/HeatShieldDuration

# Area3Ds and CollisionShape3Ds
@onready var attack_combo_1_2_hitbox: CollisionShape3D = $"Hitboxes/AttackCombo1&2/CollisionShape3D"
@onready var attack_combo_3_hitbox: CollisionShape3D = $Hitboxes/AttackCombo3/CollisionShape3D
@onready var attack_air_hitbox: CollisionShape3D = $Hitboxes/AttackAir/CollisionShape3D

# Used for ledge grabbing
@onready var head_ledge: RayCast3D = $Hitboxes/HeadLedge
@onready var eye_ledge: RayCast3D = $Hitboxes/EyeLedge

@export_subgroup("Auxiliary Scenes")
@export var firewall_scene : PackedScene

# These variables keep track of the CharacterBody3D's mobility
var point_of_view
var movement_velocity: Vector3
var rotation_direction: float
var wall_normal

# These variables will constantly change based on how the player acts
var gravity = 0.0
var ignore_gravity = false
var current_slide = 0.0
var current_boost = 0.0
var boost_count = 0.0
var boost_decay_rate = 0.0
var true_speed_goal = 0.0
var true_speed = 0.0
var is_moving = false
var jump_ground = true
var jump_midair = true
var jump_cancel = true
var slide_ready = true
var ignore_walls = false
var is_wall_jumping = false
var wall_jump_count = 0
var air_dive_hesitate = false
var combo_counter = 0
var air_attack_ready = true
var ledge_available = false

# These variables act as absolute stops in order to lock the player into actions
var move_lock = false
var rotate_lock = false
var action_lock = false
# This is excluded from clear locks as it is there to ensure the player does not repeat actions when holding buttons
var repeat_cause
var repeat_lock = false

# These variables will remain static and be used throughout the script
@export_subgroup("Player Stats")
@export var walk_base_speed = 400.0
@export var boost_base_speed = 200.0
@export var slide_base_speed = 350.0
@export var acceleration = 300.0
@export var deceleration = 150.0
@export var jump_strength = 10.0

# This is a state machine
enum States {GROUNDED, AIRBORNE, CROUCHED, SLIDING, HIGH_JUMP, LONG_JUMP, WALL_CLING, AIR_DIVE, ATTACK, AIR_ATTACK, 
LEDGE_GRAB, REIGNITE, EXTINGUISH}
var current_state = States.GROUNDED

func _ready() -> void:
	print("-GAME START-")
	
	point_of_view = get_tree().get_first_node_in_group("player_pov")


func _physics_process(delta: float) -> void:
	
	print(GlobalLevelStats.REMAINING_BEACONS)
	
	handle_state_transitions()
	handle_state_actions(delta)
	handle_boost(delta)
	handle_movement(delta)
	handle_gravity(delta)
	handle_global_stats()
	
	
	# Variable that allows movement to be tracked by script
	var applied_velocity: Vector3
	
	# Converts velocity into usable data while refreshing script and accounting for uncontrolled influences
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	velocity = applied_velocity
	move_and_slide()
	
	# Applies proper rotation to player based on prior code
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
	if !rotate_lock:
		rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 15)
	
	GlobalPlayerStats.Player_Position = self.global_position

# Allows states to be entered at any time should qualifications match, does not include states with specific triggers
func handle_state_transitions():
	# Treat this section similar to using "_ready"
	if !action_lock:
		if is_on_wall_only() and !ignore_walls:
			current_state = States.WALL_CLING
			
		elif !is_on_floor() and ledge_available and ledge_cooldown.is_stopped():
			action_lock = true
			move_lock = true
			rotate_lock = true
			current_state = States.LEDGE_GRAB
			
		elif !is_on_floor() and Input.is_action_just_pressed("attack") and air_attack_ready:
			action_lock = true
			air_attack_ready = false
			aerial_attack()
			current_state = States.AIR_ATTACK
			
		elif is_on_floor() and Input.is_action_just_pressed("attack"):
			current_state = States.ATTACK
			
		elif is_on_floor() and Input.is_action_just_pressed("reignite") and !repeat_lock:
			action_lock = true
			move_lock = true
			current_state = States.REIGNITE
			
		elif is_on_floor() and Input.is_action_just_pressed("extinguish") and !repeat_lock:
			action_lock = true
			current_state = States.EXTINGUISH
			
			
		elif !is_on_floor() and Input.is_action_just_pressed("crouch") and GlobalPlayerStats.Heat > 0.1:
			action_lock = true
			move_lock = true
			air_dive_hesitate = true
			gravity = -jump_strength / 1.5
			light_drain_high()
			current_state = States.AIR_DIVE
			
		elif is_on_floor() and is_moving and Input.is_action_just_pressed("crouch") and slide_ready and GlobalPlayerStats.Heat > 0.1:
			action_lock = true
			move_lock = true
			slide_duration.start()
			light_drain_low()
			current_state = States.SLIDING
			
		elif is_on_floor() and Input.is_action_pressed("crouch"):
			current_state = States.CROUCHED
			
		elif is_on_floor():
			current_state = States.GROUNDED
			coyote_time.stop()
			
		elif !is_on_floor() and coyote_time.is_stopped() and jump_ground:
				coyote_time.start()



# Used to handle perpetual actions that either can't be inturupted or shouldn't run at all times
func handle_state_actions(delta):
	match current_state:
		States.GROUNDED:
			ignore_walls = true
			wall_jump_count = 0
			air_attack_ready = true
		
		States.SLIDING:
			slide(delta)
			
		States.LONG_JUMP:
			slide(delta)
			if is_on_floor() or is_on_wall_only():
				slide_ready = true
				clear_locks()
				current_state = States.GROUNDED
		
		States.WALL_CLING:
			if is_on_wall_only():
				wall_normal = get_wall_normal()
			elif !is_on_wall():
				current_state = States.AIRBORNE
			
			if is_wall_jumping:
				movement_velocity = wall_normal * true_speed * delta
		
		States.AIR_DIVE:
			handle_air_dive(delta)
		
		States.ATTACK:
			handle_grounded_attack(delta)
		
		States.LEDGE_GRAB:
			handle_ledge_grab()
		
		# These need to be seperated or it causes weird bugs for some reason idk
		States.REIGNITE:
			handle_manual_heat_change(delta)
		States.EXTINGUISH:
			handle_manual_heat_change(delta)

func handle_movement(delta):
	var input := Vector3.ZERO
	
	# Detects if the player is moving
	if Input.is_action_pressed("move_back") or Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		is_moving = true
	else:
		is_moving = false
	
	# Determines true speed based on what state the player is in and if they can slide
	if current_state == States.CROUCHED:
		slide_ready = false
		true_speed = walk_base_speed / 2
	elif current_state == States.WALL_CLING:
		if !is_wall_jumping:
			true_speed = walk_base_speed / 4
		else:
			true_speed = (walk_base_speed + current_boost) * 2
	elif !move_lock:
		true_speed = walk_base_speed + current_boost
		if !slide_ready and slide_cooldown.is_stopped():
			slide_cooldown.start()
	
	# If player movement isn't restricted, this finds what direction they are moving in relation to the camera
	if !move_lock:
		input.x = Input.get_axis("move_left", "move_right")
		input.z = Input.get_axis("move_forward", "move_back")
		
		input = input.rotated(Vector3.UP, point_of_view.rotation.y).normalized()
		# MAJOR MOVEMENT HAPPENS HERE, DON'T FUCK WITH IT UNLESS ABSOLUTELY NESSESARY
		movement_velocity = input * true_speed * delta
	
	# All jumping is to be handled here!
	if Input.is_action_just_pressed("jump"):
		if current_state == States.CROUCHED and jump_ground:
			high_jump()
		
		# Wall jumping logic
		elif current_state == States.WALL_CLING and !is_wall_jumping and wall_jump_count < 3:
			wall_jump_count += 1
			rotate_lock = true
			move_lock = true
			is_wall_jumping = true
			wall_jump_duration.start()
			jump()
		
		elif current_state == States.SLIDING or current_state == States.LONG_JUMP and GlobalPlayerStats.Heat > 0.1:
			# Drain light based on state
			if current_state == States.SLIDING:
				light_drain_mid()
			elif current_state == States.LONG_JUMP:
				light_drain_high()
			# Then restart slide timer if needed and long jump
			if jump_ground or jump_midair:
				slide_duration.start()
			current_state = States.LONG_JUMP
			jump()
		
		elif !move_lock:
			current_state = States.AIRBORNE
			jump()
	
	# This section checks if a ledge grab is possible
	ledge_available = not head_ledge.is_colliding() and eye_ledge.is_colliding()
	
	# This section removes locks for states that need it
	if gravity > -3:
		if current_state == States.HIGH_JUMP:
			current_state = States.AIRBORNE
			ignore_walls = false
			clear_locks()
	if Input.is_action_just_released("reignite") or Input.is_action_just_released("extinguish"):
		repeat_lock = false

func handle_gravity(delta):
	# Constantly applies gravity to the player that slowly ramps up over time based on state
	if !ignore_gravity:
		if current_state == States.WALL_CLING and !is_wall_jumping:
			if Input.is_action_pressed("crouch"):
				gravity = 210 * delta
			else:
				gravity = 60 * delta
		else:
			gravity += 25 * delta
	
	# Resets gravity while on the floor and gives a small bit of time for a jump
	if gravity > 0 and is_on_floor():
		gravity = 0
		if current_state != States.AIRBORNE:
			jump_ground = true
			jump_cancel = true

func _on_heat_timer_timeout() -> void:
	
	# Checks if the player can gain heat from their torch first, even while immune to losing it
	if GlobalPlayerStats.Light_Goal > 4:
		GlobalPlayerStats.Heat_Goal += ( GlobalPlayerStats.Light_Goal / 5.0 )
	# Then checks to see if the player is immune to losing heat or under the the appropriate threshhold
	elif heat_shield_duration.is_stopped() and GlobalPlayerStats.Light_Goal < -4:
			GlobalPlayerStats.Heat_Goal += ( GlobalPlayerStats.Light_Goal / 5.0 )
	
	if GlobalPlayerStats.Heat < 0.1:
		GlobalPlayerStats.Freeze_Goal += 10

func handle_boost(delta):
	# If dash button is held and a reasource is available
	if Input.is_action_pressed("dash") and GlobalPlayerStats.Heat > 0.1:
		if boost_count_rate.is_stopped():
			boost_count_rate.start()
		
		# Uses number of timeouts from boost count rate to determine when to change speeds
		if boost_count < 4:
			current_boost = boost_base_speed
		elif boost_count < 8:
			current_boost = boost_base_speed * 2
		else:
			current_boost = boost_base_speed * 3
	
	else:
		boost_count_rate.stop()
		handle_boost_decay(delta)
	
	# Ensures that boost never excedes limits
	if current_boost > boost_base_speed * 4:
		current_boost = boost_base_speed * 4
	elif current_boost < 0:
		current_boost = 0

func _on_boost_count_rate_timeout() -> void:
	if boost_count < 10:
		boost_count += 1
	
	# Light drain for boost found here!
	if boost_count < 5:
		if GlobalPlayerStats.Light_Goal > GlobalPlayerStats.Light_Min + 0.1:
			GlobalPlayerStats.Light_Goal -= 0.5
		else:
			GlobalPlayerStats.Heat_Goal -= 5
	elif boost_count < 10:
		if GlobalPlayerStats.Light_Goal > GlobalPlayerStats.Light_Min + 0.1:
			GlobalPlayerStats.Light_Goal -= 1
		else:
			GlobalPlayerStats.Heat_Goal -= 10
	else:
		if GlobalPlayerStats.Light_Goal > GlobalPlayerStats.Light_Min + 0.1:
			GlobalPlayerStats.Light_Goal -= 2
		else:
			GlobalPlayerStats.Heat_Goal -= 15

func handle_boost_decay(delta):
	if current_boost != 0:
		# Applies increased deceleration based on how fast the player is going
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
	
	# Slows the player down over time
	current_boost -= deceleration * (boost_decay_rate) * delta


func jump():
	if jump_ground:
		gravity = -jump_strength
		jump_ground = false
		jump_midair = true
		if ignore_walls:
			ignore_walls_timer.start()
	
	elif jump_midair:
		gravity = -jump_strength
		jump_midair = false
		if ignore_walls:
			ignore_walls_timer.start()
	
	elif current_state == States.WALL_CLING:
		gravity = -jump_strength * 1.5

func high_jump():
	action_lock = true
	move_lock = true
	ignore_walls = true
	gravity = -jump_strength * 1.65
	jump_ground = false
	jump_midair = true
	light_drain_low()
	current_state = States.HIGH_JUMP

func _on_wall_jump_duration_timeout() -> void:
	clear_locks()
	is_wall_jumping = false
	if !is_on_wall_only():
		current_state = States.AIRBORNE

func _on_coyote_time_timeout() -> void:
	# Before this timer expires, it allows for grounded jump to be used in midair
	if current_state != States.AIRBORNE:
		jump_ground = false
		jump_midair = true
		current_state = States.AIRBORNE

func _on_ignore_walls_timeout() -> void:
	ignore_walls = false


func clear_locks():
	move_lock = false
	rotate_lock = false
	action_lock = false
	repeat_lock = false
	ignore_gravity = false



func slide(delta):
	slide_ready = false
	
	if current_state == States.LONG_JUMP:
		true_speed =  (walk_base_speed + current_boost) * 1.5
	else:
		true_speed =  walk_base_speed + current_boost + slide_base_speed
	
	movement_velocity = transform.basis.z * true_speed * delta

func _on_slide_duration_timeout() -> void:
	slide_cooldown.start()
	if current_state == States.SLIDING:
		if !is_on_floor():
			current_state = States.AIRBORNE
			coyote_time.start()
			
		else:
			current_state = States.GROUNDED
		clear_locks()

func _on_slide_cooldown_timeout() -> void:
	slide_ready = true


func _on_hard_landing_recovery_timeout() -> void:
	clear_locks()


func handle_grounded_attack(delta):
	# These are kept here to ensure that an attacking player isn't taken out of the state easily
	action_lock = true
	move_lock = true
	
	# Checks to see that an attack is not currently active before using another. Limits to 3 before reseting
	if Input.is_action_just_pressed("attack") and hitbox_duration.is_stopped():
		combo_counter += 1
		
		if combo_counter < 3:
			attack_combo_1_2_hitbox.disabled = false
			movement_velocity = transform.basis.z * (200 + current_boost) * delta
			attack_recovery.start()
			hitbox_duration.start()
			
		elif combo_counter == 3:
			attack_combo_3_hitbox.disabled = false
			movement_velocity = transform.basis.z * (600 + (current_boost)) * delta
			attack_recovery.start()
			hitbox_duration.start()

func aerial_attack():
	gravity -= jump_strength * 0.6
	attack_air_hitbox.disabled = false
	attack_recovery.start()
	hitbox_duration.start()

func _on_attack_recovery_timeout() -> void:
	action_lock = false
	move_lock = false
	rotate_lock = false
	combo_counter = 0
	if is_on_floor():
		current_state = States.GROUNDED
	elif !is_on_floor():
		current_state = States.AIRBORNE

func _on_hitbox_duration_timeout() -> void:
	attack_combo_1_2_hitbox.disabled = true
	attack_combo_3_hitbox.disabled = true
	attack_air_hitbox.disabled = true
	
	#This is here to make sure that proper speed is returned after the bursts of movement attacks give
	if current_state == States.ATTACK:
		movement_velocity = Vector3.ZERO

func handle_air_dive(delta):
	#Waits until gravity pulls the player back down, unless cancelled with a jump
	if gravity > -1:
		air_dive_hesitate = false
	
	elif Input.is_action_just_pressed("jump") and jump_cancel and GlobalPlayerStats.Heat > 0.1:
		gravity = - jump_strength / 1.5
		current_state = States.AIRBORNE
		jump_cancel = false
		light_drain_low()
		clear_locks()
	
	if is_on_floor():
		if hard_landing_recovery.is_stopped():
			hard_landing_recovery.start()
			
			if !GlobalPlayerStats.Pillar_Active:
				var instance = firewall_scene.instantiate()
				
				instance.position = self.global_position
				instance.rotation = self.rotation
				add_sibling(instance)
		else:
			movement_velocity = Vector3.ZERO
	else: 
		GlobalPlayerStats.Dive_Count += 6 * delta
	
	if !air_dive_hesitate:
		gravity += 900 * delta

func handle_ledge_grab():
	ignore_walls = true
	ignore_gravity = true
	gravity = 0
	movement_velocity = Vector3.ZERO
	
	if Input.is_action_just_pressed("jump"):
		gravity = -((jump_strength * 1.5) + (current_boost / 100))
		ledge_cooldown.start()
		ignore_walls_timer.start()
		clear_locks()
		current_state = States.AIRBORNE
	
	if Input.is_action_just_pressed("crouch"):
		ledge_cooldown.start()
		ignore_walls = false
		clear_locks()
		current_state = States.WALL_CLING

func handle_manual_heat_change(_delta):
	movement_velocity = Vector3.ZERO
	
	if current_state == States.REIGNITE and Input.is_action_pressed("reignite"):
		if reignite_duration.is_stopped():
			reignite_duration.start()
			
			
	elif current_state == States.REIGNITE and Input.is_action_just_released("reignite"):
		clear_locks()
		reignite_duration.stop()
		current_state = States.GROUNDED
	
	if current_state == States.EXTINGUISH and Input.is_action_pressed("extinguish"):
		if extinguish_duration.is_stopped():
			extinguish_duration.start()
			
			
	elif current_state == States.EXTINGUISH and Input.is_action_just_released("extinguish"):
		clear_locks()
		extinguish_duration.stop()
		current_state = States.GROUNDED


func _on_reignite_duration_timeout() -> void:
	#Due to the starting value for light being 0, this will always add light based on the upper limits (55% right now)
	GlobalPlayerStats.Light_Goal += snapped(1.1 * GlobalPlayerStats.Light_Max, 1)
	clear_locks()
	repeat_lock = true


func _on_extinguish_duration_timeout() -> void:
	
	#Grants a burst of heat based on how much light was extinguished
	GlobalPlayerStats.Heat_Goal += (GlobalPlayerStats.Light_Goal + 50.0) * 5.0
	
	#Then grants immunity to losing heat, ensuring the player always gets at least 4 seconds or more based on light
	if 10.0 * ((GlobalPlayerStats.Light + 50.0) / 100.0) < 4.0:
		heat_shield_duration.wait_time = 4.0
	else:
		heat_shield_duration.wait_time = 10.0 * ((GlobalPlayerStats.Light + 50.0) / 100.0)
	heat_shield_duration.start()
	
	#Then instantly reduces player light to its minimum value and clears all locks other than repeat lock
	GlobalPlayerStats.Light_Goal = GlobalPlayerStats.Light_Min
	GlobalPlayerStats.Light = GlobalPlayerStats.Light_Min
	clear_locks()
	repeat_lock = true

func light_drain_high():
	if GlobalPlayerStats.Light_Goal > GlobalPlayerStats.Light_Min + 0.1:
		GlobalPlayerStats.Light_Goal -= 5
	else:
		GlobalPlayerStats.Heat_Goal -= 25
func light_drain_mid():
	if GlobalPlayerStats.Light_Goal > GlobalPlayerStats.Light_Min + 0.1:
		GlobalPlayerStats.Light_Goal -= 3
	else:
		GlobalPlayerStats.Heat_Goal -= 15
func light_drain_low():
	if GlobalPlayerStats.Light_Goal > GlobalPlayerStats.Light_Min + 0.1:
		GlobalPlayerStats.Light_Goal -= 1
	else:
		GlobalPlayerStats.Heat_Goal -= 5



# Used for UI
func handle_global_stats():
	GlobalPlayerStats.PLAYER_BOOST_COUNT = boost_count
	GlobalPlayerStats.PLAYER_CURRENT_SPEED = true_speed
	GlobalPlayerStats.PLAYER_GRAVITY = gravity
	GlobalPlayerStats.PLAYER_HEAT_SHIELD = heat_shield_duration.time_left
	
	if current_state == States.GROUNDED:
		GlobalPlayerStats.PLAYER_CURRENT_STATE = "Grounded"
	elif current_state == States.AIRBORNE:
		GlobalPlayerStats.PLAYER_CURRENT_STATE = "Airborne"
	elif current_state == States.CROUCHED:
		GlobalPlayerStats.PLAYER_CURRENT_STATE = "Crouching"
	elif current_state == States.SLIDING:
		GlobalPlayerStats.PLAYER_CURRENT_STATE = "Sliding"
	elif current_state == States.HIGH_JUMP:
		GlobalPlayerStats.PLAYER_CURRENT_STATE = "High Jump"
	elif current_state == States.LONG_JUMP:
		GlobalPlayerStats.PLAYER_CURRENT_STATE = "Long Jump"
	elif current_state == States.WALL_CLING:
		GlobalPlayerStats.PLAYER_CURRENT_STATE = "Wall Cling"
	elif current_state == States.AIR_DIVE:
		GlobalPlayerStats.PLAYER_CURRENT_STATE = "Air Dive"
	elif current_state == States.ATTACK:
		GlobalPlayerStats.PLAYER_CURRENT_STATE = "Attack"
	elif current_state == States.AIR_ATTACK:
		GlobalPlayerStats.PLAYER_CURRENT_STATE = "Aerial Attack"
	elif current_state == States.LEDGE_GRAB:
		GlobalPlayerStats.PLAYER_CURRENT_STATE = "Ledge Grab"
	elif current_state == States.REIGNITE:
		GlobalPlayerStats.PLAYER_CURRENT_STATE = "Reignite"
	elif current_state == States.EXTINGUISH:
		GlobalPlayerStats.PLAYER_CURRENT_STATE = "Extinguish"
