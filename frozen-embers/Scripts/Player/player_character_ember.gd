extends CharacterBody3D

@onready var visuals: Node3D = $Visuals
@onready var sfx_controller: Node = $SFX

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
@onready var water_buffer: Timer = $Timers/WaterBuffer
@onready var ignore_water_timer: Timer = $Timers/IgnoreWater

# Area3Ds, CollisionShape3Ds, and Lights
@onready var attack_combo_1_2_hitbox: CollisionShape3D = $"Hitboxes/AttackCombo1&2/CollisionShape3D"
@onready var attack_combo_3_hitbox: CollisionShape3D = $Hitboxes/AttackCombo3/CollisionShape3D
@onready var attack_air_hitbox: CollisionShape3D = $Hitboxes/AttackAir/CollisionShape3D
@onready var swim_hurtbox: Area3D = $Hurtboxes/SwimHurtbox
@onready var swim_marker: Marker3D = $Hurtboxes/SwimHurtbox/SwimMarker
@onready var torch_omni_light: OmniLight3D = $Visuals/TorchOmniLight
@onready var visibility_spot_light: SpotLight3D = $Visuals/VisibilitySpotLight
@onready var light_hitbox: CollisionShape3D = $Hitboxes/LightHitbox/CollisionShape3D
@onready var noise_hitbox: CollisionShape3D = $Hitboxes/NoiseHitbox/CollisionShape3D
@onready var main_hurtbox: CollisionShape3D = $Hurtboxes/MainHurtbox/CollisionShape3D

# Used for ledge grabbing
@onready var high_ledge: RayCast3D = $Hitboxes/HighLedge
@onready var low_ledge: RayCast3D = $Hitboxes/LowLedge

@export_subgroup("Auxiliary Scenes")
@export var pause_menu : PackedScene
@export var firewall_scene : PackedScene

# These variables keep track of the CharacterBody3D's mobility
var point_of_view : Node3D
var movement_velocity: Vector3
var rotation_direction: float
var wall_normal: Vector3 = Vector3.ZERO

# These variables will constantly change based on how the player acts
var gravity : float = 0.0
var ignore_gravity : bool = false
var current_slide : float = 0.0
var current_boost : float = 0.0
var boost_count : int = 0
var boost_decay_rate : float = 0.0
var true_speed_goal : float = 0.0
var true_speed : float = 0.0
var is_moving : bool = false
var jump_ground : bool = true
var jump_midair : bool = true
var jump_cancel : bool = true
var slide_ready : bool = true
var ignore_walls : bool = false
var is_wall_jumping : bool = false
var wall_jump_count : int = 0
var air_dive_hesitate : bool = false
var combo_counter : int = 0
var air_attack_ready : bool = true
var ledge_available : bool = false
var in_water : bool = false
var water_surface : float = 0.0
var dash_toggle : bool = false

# These variables act as absolute stops in order to lock the player into actions
var move_lock : bool = false
var rotate_lock : bool = false
var action_lock : bool = false
# This is excluded from clear locks as it is there to ensure the player does not repeat actions when holding buttons
var repeat_lock : bool = false

# These variables will remain static and be used throughout the script
@export_subgroup("Player Stats")
@export var walk_base_speed : float = 400.0
@export var boost_base_speed : float = 200.0
@export var slide_base_speed : float = 350.0
@export var acceleration : float = 300.0
@export var deceleration : float = 150.0
@export var jump_strength : float = 11.0
@export var high_jump_multiplier : float = 2.0

var debug_aware : bool = false

# This is a state machine
enum States {GROUNDED, AIRBORNE, CROUCHED, SLIDING, HIGH_JUMP, LONG_JUMP, WALL_CLING, AIR_DIVE, ATTACK, AIR_ATTACK, 
LEDGE_GRAB, REIGNITE, EXTINGUISH, SWIMMING, FREEZE_DEATH, DESPIRATION}
var current_state = States.GROUNDED

func _ready() -> void:
	print_rich("[color=cyan]-PLAYER START-")
	current_boost = 0
	point_of_view = get_tree().get_first_node_in_group("player_pov")
	GlobalLevelStats.RESPAWN_LOCATION = global_position


func _physics_process(delta: float) -> void:
	#Placed here that that pauses will happen as soon as possible:
	if Input.is_action_just_pressed("pause"):
		add_sibling(pause_menu.instantiate())
	
	handle_debug()
	handle_state_transitions()
	handle_state_actions(delta)
	handle_boost(delta)
	handle_movement(delta)
	handle_gravity(delta)
	handle_light(delta)
	handle_global_stats()
	if global_position.y < GlobalLevelStats.FALL_OFF_DISTANCE:
		handle_fall_off()
	handle_noise(delta)
	
	# Variable that allows movement to be tracked by script
	var applied_velocity: Vector3
	
	# Converts velocity into usable data while refreshing script and accounting for uncontrolled influences
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	velocity = applied_velocity
	move_and_slide()
	
	# Applies proper rotation to player based on prior code
	if !rotate_lock:
		if Vector2(velocity.z, velocity.x).length() > 0:
			rotation_direction = Vector2(velocity.z, velocity.x).angle()
		if current_state == States.WALL_CLING:
			rotation_direction = Vector2(-wall_normal.z, -wall_normal.x).angle()
			rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 15)
		else:
			rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 15)
	elif rotate_lock and current_state == States.WALL_CLING:
		rotation_direction = Vector2(wall_normal.z, wall_normal.x).angle()
		rotation.y = rotation_direction
	
	

# Allows states to be entered at any time should qualifications match, does not include states with specific triggers
func handle_state_transitions():
	# Treat this section similar to using "_ready" as these trigger only once
	if GlobalPlayerStats.Freeze > GlobalPlayerStats.Freeze_Max - 1 and !GlobalLevelStats.DESPERATION_MODE:
		current_state = States.FREEZE_DEATH
	
	elif in_water:
		clear_locks()
		GlobalPlayerStats.Light_Goal =  GlobalPlayerStats.Light_Min
		GlobalPlayerStats.Light = GlobalPlayerStats.Light_Min
		if heat_shield_duration.is_stopped():
			sfx_controller.play_freezing()
		current_state = States.SWIMMING
	
	elif !action_lock:
		if !is_on_floor() and ledge_available and ledge_cooldown.is_stopped():
			action_lock = true
			move_lock = true
			rotate_lock = true
			current_state = States.LEDGE_GRAB
			jump_midair = true
			wall_jump_count = 0
			sfx_controller.play_crumple()
			
		elif is_on_wall_only() and !ignore_walls:
			current_state = States.WALL_CLING
			
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
			
			
		elif !is_on_floor() and Input.is_action_just_pressed("crouch") and !Input.is_action_pressed("jump") and GlobalPlayerStats.Heat > 0.1:
			action_lock = true
			move_lock = true
			air_dive_hesitate = true
			gravity = -jump_strength / 1.5
			light_drain_high()
			sfx_controller.play_boost_fire()
			current_state = States.AIR_DIVE
			
		elif is_on_floor() and is_moving and Input.is_action_just_pressed("crouch") and slide_ready: 
			if  GlobalPlayerStats.Light > GlobalPlayerStats.Light_Min + 0.1 or GlobalPlayerStats.Heat > 0.1:
				action_lock = true
				move_lock = true
				slide_duration.start()
				#light_drain_low()
				current_state = States.SLIDING
				sfx_controller.play_slide()
			
		elif is_on_floor() and Input.is_action_pressed("crouch"):
			current_state = States.CROUCHED
			
		elif is_on_floor():
			current_state = States.GROUNDED
			clear_locks()
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
			high_ledge.enabled = false
			low_ledge.enabled = false
			if !is_on_floor():
				ignore_walls = false
				low_ledge.enabled = true
				high_ledge.enabled = true
		
		States.AIRBORNE:
			if ignore_walls:
				high_ledge.enabled = false
				low_ledge.enabled = false
			else:
				high_ledge.enabled = true
				low_ledge.enabled = true
		
		States.SLIDING:
			slide(delta)
			if Input.is_action_pressed("move_left"):
				rotation.y += deg_to_rad(150 * delta)
			if Input.is_action_pressed("move_right"):
				rotation.y -= deg_to_rad(150 * delta)
		
		States.LONG_JUMP:
			slide(delta)
			low_ledge.enabled = true
			high_ledge.enabled = true
			
			if !is_on_floor() and Input.is_action_just_pressed("attack") and air_attack_ready:
				move_lock = false
				rotate_lock = false
				action_lock = true
				air_attack_ready = false
				aerial_attack()
				light_drain_mid()
				current_state = States.AIR_ATTACK
				
			if is_on_floor() or is_on_wall_only():
				slide_ready = true
				clear_locks()
				if is_on_floor():
					current_state = States.GROUNDED
				elif is_on_wall_only():
					current_state = States.WALL_CLING
			
			if Input.is_action_pressed("move_left"):
				rotation.y += deg_to_rad(120 * delta)
			if Input.is_action_pressed("move_right"):
				rotation.y -= deg_to_rad(120 * delta)
		
		States.HIGH_JUMP:
			hard_landing_recovery.stop()
		
		States.WALL_CLING:
			if is_on_wall_only():
				wall_normal = get_wall_normal()
				
			elif !is_on_wall():
				current_state = States.AIRBORNE
			
			if is_wall_jumping:
				movement_velocity = wall_normal * true_speed * delta
		
		States.AIR_DIVE:
			movement_velocity = Vector3.ZERO
			handle_air_dive(delta)
			if is_on_floor() and Input.is_action_just_pressed("jump"):
				current_state = States.HIGH_JUMP
		
		States.ATTACK:
			handle_grounded_attack(delta)
		
		States.LEDGE_GRAB:
			handle_ledge_grab()
		
		# These need to be seperated or it causes weird bugs for some reason idk
		States.REIGNITE:
			handle_manual_heat_change(delta)
		States.EXTINGUISH:
			handle_manual_heat_change(delta)
		
		States.SWIMMING:
			if water_buffer.is_stopped():
				jump_ground = true
				jump_cancel = true
			else:
				jump_ground = false
				jump_midair = false
		
		States.FREEZE_DEATH:
			# Must reset at moment of death or freeze will trigger for one frame when reloading
			GlobalPlayerStats.Freeze = 0
			GlobalPlayerStats.Freeze_Goal = 0
			get_tree().change_scene_to_file("res://Scenes/Levels/Final/Level_Menu.tscn")

func handle_movement(delta):
	var input := Vector3.ZERO
	
	# Detects if the player is moving
	if Input.is_action_pressed("move_back") or Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		is_moving = true
	else:
		is_moving = false
	
	# Determines true speed based on what state the player is in and if they can slide
	if current_state == States.SWIMMING:
		true_speed = walk_base_speed * 0.35
	elif current_state == States.CROUCHED:
		slide_ready = false
		true_speed = walk_base_speed * 0.5
	elif current_state == States.WALL_CLING:
		if !is_wall_jumping:
			true_speed = walk_base_speed * 0.25
		else:
			true_speed = ((walk_base_speed + current_boost) * 2) - (current_boost * 0.25)
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
	
	# Jumping is to be handled here!
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
		
		elif current_state == States.SWIMMING:
			jump()
		
		elif !move_lock:
			current_state = States.AIRBORNE
			jump()
	
	# This section checks if a ledge grab is possible
	ledge_available = not high_ledge.is_colliding() and low_ledge.is_colliding()
	
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
		if in_water:
			#If the player is no longer sinking and are underwater, rise to the surface
			if !water_buffer.is_stopped() and swim_marker.global_position.y > water_surface:
				gravity += 20 * delta
			#If the player just entered the water, make them sink for a time
			elif (swim_marker.global_position.y < water_surface or !water_buffer.is_stopped()) and ignore_water_timer.is_stopped():
				gravity -= 15 * delta
			else:
					#Make player float on the surface of the water
					if ignore_water_timer.is_stopped():
						gravity = 0
					else:
						return
		
		#Enables the sliding effect of wall clinging
		elif current_state == States.WALL_CLING and !is_wall_jumping:
			if Input.is_action_pressed("crouch"):
				gravity = 210 * delta
			else:
				gravity = 60 * delta
		else:
			gravity += 25 * delta
	
	# Resets gravity while on the floor and gives a small bit of time for a jump
	if gravity > 0 and is_on_floor():
		if current_state == States.GROUNDED and Input.is_action_pressed("dash"):
			gravity = 3
		elif current_state == States.GROUNDED:
			gravity = 2
		elif current_state == States.SLIDING:
			gravity = 7
		elif current_state == States.REIGNITE:
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
			
	# If the player is out of heat or enters the water, begin adding freeze
	if GlobalPlayerStats.Heat < 0.1 or (current_state == States.SWIMMING and heat_shield_duration.is_stopped()):
		if !GlobalLevelStats.DESPERATION_MODE:
			GlobalPlayerStats.Freeze_Goal += 15
	

func handle_boost(delta):
	
	# Accessability: Toggle Run
	if GlobalOptionSettings.accessability_toggle_run and Input.is_action_just_pressed("dash") and !dash_toggle:
		dash_toggle = true
	elif GlobalOptionSettings.accessability_toggle_run and Input.is_action_just_pressed("dash") and dash_toggle:
		dash_toggle = false
	
	# If you are out of resources, end boosting effects instantly
	if GlobalPlayerStats.Heat < 1 and GlobalPlayerStats.Light_Goal < GlobalPlayerStats.Light_Min + 0.1:
		boost_count_rate.stop()
		handle_boost_decay(delta)
		sfx_controller.stop_boost_loop()
	
	elif Input.is_action_pressed("dash") or dash_toggle:
		# This is here to punish mashing
		if Input.is_action_just_pressed("dash"):
				if boost_count < 3:
					GlobalPlayerStats.Light_Goal -= 0.5 
				elif boost_count < 8:
					GlobalPlayerStats.Light_Goal -= 1 
				else:
					GlobalPlayerStats.Light_Goal -= 1.5 
		
		#If the player has a resource to spend, boosting is enabled
		if GlobalPlayerStats.Heat > 0 or GlobalPlayerStats.Light_Goal > GlobalPlayerStats.Light_Min + 0.1:
			if boost_count_rate.is_stopped():
				boost_count_rate.start()
		
		# Uses number of timeouts from boost count rate to determine when to change speeds
		if boost_count < 4:
			current_boost = boost_base_speed + (walk_base_speed/16 * boost_count)
		elif boost_count < 8:
			current_boost = (boost_base_speed * 2) + (walk_base_speed/16 * (boost_count - 4))
		else:
			current_boost = boost_base_speed * 3 
		sfx_controller.play_boost_loop()
	
	# When the button is released, speed returns to normal over time  
	else:
		boost_count_rate.stop()
		handle_boost_decay(delta)
		sfx_controller.stop_boost_loop()
	
	# Ensures that boost never excedes limits
	if current_boost > boost_base_speed * 4:
		current_boost = boost_base_speed * 4
	elif current_boost < 0:
		current_boost = 0

func _on_boost_count_rate_timeout() -> void:
	boost_count += 1
	
	# Light drain for boost found here!
	if boost_count < 5:
		if GlobalPlayerStats.Light_Goal > GlobalPlayerStats.Light_Min + 0.1:
			GlobalPlayerStats.Light_Goal -= 0.5
		else:
			GlobalPlayerStats.Heat_Goal -= 5
			sfx_controller.play_heartbeat()
	elif boost_count < 10:
		if GlobalPlayerStats.Light_Goal > GlobalPlayerStats.Light_Min + 0.1:
			GlobalPlayerStats.Light_Goal -= 1
		else:
			GlobalPlayerStats.Heat_Goal -= 10
			sfx_controller.play_heartbeat()
	else:
		if GlobalPlayerStats.Light_Goal > GlobalPlayerStats.Light_Min + 0.1:
			GlobalPlayerStats.Light_Goal -= 2
		else:
			GlobalPlayerStats.Heat_Goal -= 15
			sfx_controller.play_heartbeat()

func handle_boost_decay(delta):
	if current_boost != 0:
		# Applies increased deceleration based on how fast the player is going
		if current_boost > boost_base_speed * 2:
			boost_decay_rate = 0.6
			boost_count = 8
		elif current_boost > boost_base_speed:
			boost_decay_rate = 0.55
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
	if current_state == States.SWIMMING:
		if water_buffer.is_stopped():
			ignore_water_timer.start()
			gravity = -jump_strength * 0.75
			sfx_controller.play_jump()
	
	elif current_state == States.WALL_CLING:
		gravity = -jump_strength * 1.5
		sfx_controller.play_jump()
	
	elif jump_ground:
		gravity = -jump_strength
		jump_ground = false
		jump_midair = true
		if ignore_walls:
			ignore_walls_timer.start()
		
		if current_state == States.LONG_JUMP:
			sfx_controller.play_long_jump()
		else:
			sfx_controller.play_jump()
	
	elif jump_midair and !is_on_wall():
		gravity = -jump_strength
		jump_midair = false
		if ignore_walls:
			ignore_walls_timer.start()
		
		if current_state == States.LONG_JUMP:
			sfx_controller.play_long_jump()
		else:
			sfx_controller.play_jump()
	

func high_jump():
	action_lock = true
	move_lock = true
	ignore_walls = true
	gravity = -jump_strength * high_jump_multiplier
	jump_ground = false
	jump_midair = true
	jump_cancel = true
	light_drain_low()
	current_state = States.HIGH_JUMP
	wall_jump_count = 0
	sfx_controller.play_high_jump()

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
	
	# Speed is based on the state that triggers this code
	if current_state == States.LONG_JUMP:
		true_speed =  (walk_base_speed + current_boost) * 1.5
	else:
		true_speed =  walk_base_speed + current_boost + slide_base_speed
	
	# This is what restricts movement, this happens because it is using transform rather than inputs
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
	sfx_controller.stop_slide()

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
			sfx_controller.play_torch_swing()
			
		elif combo_counter == 3:
			attack_combo_3_hitbox.disabled = false
			movement_velocity = transform.basis.z * (600 + (current_boost)) * delta
			attack_recovery.start()
			hitbox_duration.start()
			sfx_controller.play_torch_swing()

func aerial_attack():
	gravity = -jump_strength * 0.65
	attack_air_hitbox.disabled = false
	attack_recovery.start()
	hitbox_duration.start()
	sfx_controller.play_torch_swing()

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
	
	# Air Dive Jump Cancel is here!
	elif Input.is_action_just_pressed("jump") and jump_cancel and GlobalPlayerStats.Heat > 0.1 and !is_on_floor():
		gravity = - jump_strength * 0.8
		current_state = States.AIRBORNE
		jump_cancel = false
		light_drain_low()
		sfx_controller.play_flap()
		clear_locks()
	
	if is_on_floor():
		noise_hitbox.shape.radius = 20.0
		
		#Allows you to cancel your recovery with a jump, which also grants you a high jump
		if Input.is_action_just_pressed("jump"):
			clear_locks()
			jump_ground = true
			gravity = -20
			high_jump()
		
		if hard_landing_recovery.is_stopped():
			hard_landing_recovery.start()
			sfx_controller.play_boom()
			if !GlobalPlayerStats.Pillar_Active:
				var instance = firewall_scene.instantiate()
				
				instance.position = global_position
				instance.rotation = rotation
				add_sibling(instance)
		else:
			movement_velocity = Vector3.ZERO
	else: 
		GlobalPlayerStats.Dive_Count += 9.5 * delta
	
	#This fucker right here is an asshole. Make it identify what state it is in or else.
	if !air_dive_hesitate and current_state == States.AIR_DIVE:
		gravity += 900 * delta

func handle_ledge_grab():
	# HEY! FIND A WAY TO MAKE THE PLAYER SNAP TO THE LEDGE'S LOCATION AS WELL!
	ignore_walls = true
	ignore_gravity = true
	gravity = 0
	movement_velocity = Vector3.ZERO
	
	if Input.is_action_just_pressed("jump"):
		gravity = -((jump_strength * 1.5) + (current_boost / 200))
		ledge_cooldown.start()
		ignore_walls_timer.start()
		clear_locks()
		current_state = States.AIRBORNE
		sfx_controller.play_jump()
	
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
	sfx_controller.play_boost_fire()
	clear_locks()
	repeat_lock = true
	#This is here for debug reasons (Disable Player Awareness)
	if !debug_aware:
		GlobalLevelStats.MAX_NOISE_ACTIVE = true
		GlobalLevelStats.MAX_NOISE_LOCATION = global_position
		noise_hitbox.shape.radius = 20.0
	print_rich("[color=cyan]PLAYER: Light Reignited")

func _on_extinguish_duration_timeout() -> void:
	#Grants a burst of heat based on how much light was extinguished
	GlobalPlayerStats.Heat_Goal += (GlobalPlayerStats.Light_Goal + 50.0) * 5.0
	print_rich("[color=cyan]PLAYER: Light Extinguished")
	
	#Then grants immunity to losing heat, ensuring the player always gets at least 5 seconds or more based on light
	if 20.0 * ((GlobalPlayerStats.Light + 50.0) / 100.0) < 5.0:
		heat_shield_duration.wait_time = 5.0
	else:
		heat_shield_duration.wait_time = 20.0 * ((GlobalPlayerStats.Light + 50.0) / 100.0)
	heat_shield_duration.start()
	
	#Then instantly reduces player light to its minimum value and clears all locks other than repeat lock
	GlobalPlayerStats.Light_Goal = GlobalPlayerStats.Light_Min
	GlobalPlayerStats.Light = GlobalPlayerStats.Light_Min
	sfx_controller.play_snuff_fire()
	clear_locks()
	repeat_lock = true

#These are the core values of light and heat that are drained when using a resource
func light_drain_high():
	if GlobalPlayerStats.Light_Goal > GlobalPlayerStats.Light_Min + 0.1:
		GlobalPlayerStats.Light_Goal -= 5.0
		torch_omni_light.light_energy = 12.0
	else:
		GlobalPlayerStats.Heat_Goal -= 25.0
		sfx_controller.play_heartbeat()
func light_drain_mid():
	if GlobalPlayerStats.Light_Goal > GlobalPlayerStats.Light_Min + 0.1:
		GlobalPlayerStats.Light_Goal -= 3.0
		torch_omni_light.light_energy = 12.0
	else:
		GlobalPlayerStats.Heat_Goal -= 15.0
		sfx_controller.play_heartbeat()
func light_drain_low():
	if GlobalPlayerStats.Light_Goal > GlobalPlayerStats.Light_Min + 0.1:
		GlobalPlayerStats.Light_Goal -= 1.0
		torch_omni_light.light_energy = 12.0
	else:
		GlobalPlayerStats.Heat_Goal -= 5.0
		sfx_controller.play_heartbeat()

#Water controlls here!
func _on_swim_hurtbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("water"):
		in_water = true
		sfx_controller.play_splash()
		water_buffer.start()
		water_surface = swim_hurtbox.global_position.y

func _on_swim_hurtbox_area_exited(area: Area3D) -> void:
	if area.is_in_group("water"):
		in_water = false

func _on_ignore_water_timeout() -> void:
	if in_water:
		current_state = States.SWIMMING
	if !in_water:
		current_state = States.AIRBORNE

func handle_light(delta):
	#Keeps the light source at a fixed energy so that it may cause a flash from the light drain functions
	if torch_omni_light.light_energy > 3.0:
		torch_omni_light.light_energy -= 12.0 * delta
	else:
		torch_omni_light.light_energy = 3.0
	
	#Matches the visual size of the light and its hitbox to the light resource of the player
	if GlobalPlayerStats.Light > GlobalPlayerStats.Light_Min:
		if !current_state == States.CROUCHED:
			torch_omni_light.omni_range = (GlobalPlayerStats.Light + 50) * 0.1 + 1.5
			light_hitbox.shape.radius = (GlobalPlayerStats.Light + 50) * 0.1 + 2.0
		else:
			torch_omni_light.omni_range = ((GlobalPlayerStats.Light + 50) * 0.1 + 1.5) / 4
			light_hitbox.shape.radius = ((GlobalPlayerStats.Light + 50) * 0.1 + 2.0) / 4
	else:
		torch_omni_light.omni_range = 0.0
		light_hitbox.shape.radius = 0.5
	
	visibility_spot_light.spot_angle = 10.0 + ((GlobalPlayerStats.Light + 50) / 2)

func handle_fall_off():
	# Respawns the player if they fall into a pit by placing them at the last triggered respawn location
	GlobalPlayerStats.Freeze_Goal += GlobalPlayerStats.Heat_Max_Start_Value * 0.1
	global_position = GlobalLevelStats.RESPAWN_LOCATION

func handle_noise(delta):
	if noise_hitbox.shape.radius > 1.0 and !debug_aware:
		noise_hitbox.disabled = false
		noise_hitbox.shape.radius -= 2.0 * delta
	else:
		noise_hitbox.disabled = true
	
	if is_moving and current_state != States.CROUCHED:
		if Input.is_action_pressed("dash") and noise_hitbox.shape.radius < 15.0:
			noise_hitbox.shape.radius += 4.0 * delta
		elif noise_hitbox.shape.radius < 5.0:
			noise_hitbox.shape.radius += 3.0 * delta
		
	elif is_moving and current_state == States.CROUCHED:
		if noise_hitbox.shape.radius < 1.5:
			noise_hitbox.shape.radius += 3.0 * delta
	elif !is_moving and current_state == States.CROUCHED:
		noise_hitbox.shape.radius -= 2.0 * delta

# Used for UI and SFX
func handle_global_stats():
	GlobalPlayerStats.Player_Position = main_hurtbox.global_position
	
	if GlobalPlayerStats.Light_Goal > GlobalPlayerStats.Light_Min:
		sfx_controller.play_torch_loop()
	else:
		sfx_controller.stop_torch_loop()
	
	GlobalPlayerStats.PLAYER_BOOST_COUNT = boost_count
	GlobalPlayerStats.PLAYER_CURRENT_SPEED = true_speed
	GlobalPlayerStats.PLAYER_GRAVITY = int(gravity)
	GlobalPlayerStats.PLAYER_HEAT_SHIELD = heat_shield_duration.time_left
	GlobalPlayerStats.PLAYER_NOISE_SIZE = noise_hitbox.shape.radius
	
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
	elif current_state == States.SWIMMING:
		GlobalPlayerStats.PLAYER_CURRENT_STATE = "Swimming"

func handle_debug():
	#DEBUG REFILL
	if Input.is_action_just_pressed("debug_3"):
		GlobalPlayerStats.Heat_Goal = GlobalPlayerStats.Heat_Max
		GlobalPlayerStats.Light_Goal = GlobalPlayerStats.Light_Max
		noise_hitbox.shape.radius = 0.0
		print_rich("[color=cyan]PLAYER: DEBUG REFILL")
	
	#DEBUG TOGGLE INVINCIBILITY
	if Input.is_action_just_pressed("debug_4"):
		if !main_hurtbox.disabled:
			main_hurtbox.disabled = true
			print_rich("[color=cyan]PLAYER: INVINCIBILITY ON")
		else:
			main_hurtbox.disabled = false
			print_rich("[color=cyan]PLAYER: INVINCIBILITY OFF")
	
	#DEBUG TOGGLE PLAYER AWARENESS
	if Input.is_action_just_pressed("debug_5"):
		if !debug_aware:
			debug_aware = true
			noise_hitbox.disabled = true
			light_hitbox.disabled = true
			print_rich("[color=cyan]PLAYER: OBLIVIOUS ON")
		else:
			debug_aware = false
			noise_hitbox.disabled = false
			light_hitbox.disabled = false
			print_rich("[color=cyan]PLAYER: OBLIVIOUS OFF")
