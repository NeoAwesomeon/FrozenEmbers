extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var visuals: Node3D = $Visuals

#Areas & CollisionShapes
@onready var main_collision: CollisionShape3D = $CollisionShape3D
@onready var main_hurtbox: CollisionShape3D = $Hurtbox/MainHurtbox/CollisionShape3D
@onready var hearing_area: CollisionShape3D = $Hurtbox/HearingArea/CollisionShape3D
@onready var vision_area: CollisionShape3D = $Hurtbox/VisionArea/CollisionShape3D
@onready var attack_hitbox: CollisionShape3D = $Hitboxes/AttackHitbox/CollisionShape3D

#Raycast3Ds
@onready var ray_parent: Node3D = $Rays
@onready var light_ray: RayCast3D = $Rays/LightRay
@onready var player_ray: RayCast3D = $Rays/PlayerRay

#Timers
@onready var spawn_timer: Timer = $Timers/SpawnTimer
@onready var boredom_timer: Timer = $Timers/BoredomTimer
@onready var huh_duration: Timer = $Timers/HuhDuration
@onready var stare_duration: Timer = $Timers/StareDuration
@onready var chase_duration: Timer = $Timers/ChaseDuration
@onready var boost_count_rate: Timer = $Timers/BoostCountRate
@onready var stun_duration: Timer = $Timers/StunDuration
@onready var detective_anti_spam: Timer = $Timers/DetectiveAntiSpam
@onready var hurt_duration: Timer = $Timers/HurtDuration

#HEY! CHANGE THIS SHIT ONCE YOU GET ANIMATIONS IN HERE DUMBASS!
@onready var testingdesperationtimer: Timer = $Timers/TESTINGDESPERATIONTIMER

#Determines where the monster will move to, if at all
var target_pos: Vector3
var previous_target_pos: Vector3
var has_target : bool = false
var boost_active : bool = false
var vision_active : bool = false
var chase_prep : bool = false
var chase_active : bool = false
var desp_safe : bool = false

#Movement Requirements
var movement_velocity: Vector3
var rotation_direction: float
var gravity : float = 0.0
var true_speed : float = 0.0
var boost_count : float = 0.0
var detective_points : float = 0.0
var spawn_location : Vector3
var rotate_lock : bool = false
var remaining_knockback : float = 0.0

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
@export var hurt_knockback : float = 2000.0
@export var adaptation_1 : bool = false
@export var adaptation_2 : bool = false
@export var adaptation_3 : bool = false
@export var adaptation_4 : bool = false

enum States {SPAWN, WANDER, HUH, STARE, CURIOUS, PURSUIT, CHASE, ENDGAME, DESPERATION, STUNNED, HURT}
var current_state = States.SPAWN
#Priority Guide: 0=PLACE_OF_INTEREST, 1=MINOR, 2=MAJOR, 3=MAX, 4=PLAYER, 5=ENDGAME
var priority = 0


func _ready() -> void:
	difficulty = GlobalLevelStats.Wolf_Difficulty
	GlobalLevelStats.NUMBER_OF_MONSTERS += 2
	spawn_location = global_position
	previous_target_pos = global_position
	
	# Instantly destroys this monster if the difficulty is set to a negative value
	if difficulty == -1:
		queue_free()
	else:
		print("Twins: Spawning...")
	
	# Initial difficulty modifiers here
	spawn_timer.wait_time = 23.0 - difficulty
	print(spawn_timer.wait_time)
	
	huh_duration.wait_time = (2.0 - (difficulty)/10.0) + 1.0
	hearing_area.shape.radius = 40.0 + difficulty
	light_ray.target_position.z = -(hearing_area.shape.radius) - 0.5
	stun_duration.wait_time = 30.0 - difficulty
	
	if difficulty > 5:
		chase_duration.wait_time = 45.0 + (difficulty - 5.0)
	
	vision_area.disabled = true
	hearing_area.disabled = true
	attack_hitbox.disabled = true
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	print("Twins: Spawn Complete.")
	reset_wander()
	has_target = true
	vision_area.disabled = false
	hearing_area.disabled = false

func _physics_process(delta: float) -> void:
	
	if !stun_duration.is_stopped():
		current_state = States.STUNNED
	
	handle_gravity(delta)
	handle_line_of_sight()
	handle_distance_and_noise()
	handle_state_actions(delta)
	handle_chase_logic()
	
	visuals.scale = visuals.scale.lerp(Vector3(1, 1, 1), delta * 10)
	
	if has_target:
		nav_agent.target_position = target_pos
		var next_path_pos := nav_agent.get_next_path_position()
		var direction := global_position.direction_to(next_path_pos)
		
		var applied_velocity : Vector3
		
		#This is messy and stupid, but it works!
		#If not getting attacked, move normaly
		if hurt_duration.is_stopped():
			movement_velocity = direction * true_speed * delta
		#If getting attacked, be pushed back
		else:
			if remaining_knockback > 0:
				movement_velocity = transform.basis.z * -remaining_knockback * delta
				remaining_knockback -= remaining_knockback * 2 * delta
			else:
				movement_velocity = Vector3.ZERO
				remaining_knockback = 0
		#Turns values into movement
		applied_velocity = velocity.lerp(movement_velocity, delta * 10)
		applied_velocity.y = -gravity 
		velocity = applied_velocity
		
		#Failsafe in case no target is possible
		if nav_agent.is_navigation_finished():
			velocity = Vector3.ZERO
			has_target = false
		
		if !rotate_lock:
			var rotation_speed = 4
			var target_rotation := direction.signed_angle_to(Vector3.MODEL_FRONT, Vector3.DOWN)
			if abs(target_rotation - rotation.y) > deg_to_rad(60):
					rotation_speed = 20
			rotation.y = move_toward(rotation.y, target_rotation, delta * rotation_speed)
	
	move_and_slide()
	
	if Input.is_action_just_pressed("debug_0"):
		print(" --- TWINS CHECKUP --- ")
		print("Difficulty = " + str(difficulty))
		print("Current State = " + str(current_state))
		print("Priority = " + str(priority))
		print("Target Distance: " + str(distance_from_target))
		print("Speed:" + str(true_speed))
		print("Boost:" + str(boost_count))
		print("Detective Points:" + str(detective_points))
		print("Has Target? " + str(has_target))
		print("Boosting? "  + str(boost_active))
		print("Vision? "  + str(vision_active))
		print("Chase Prep? " + str(chase_prep))
		print("Chase Active? " + str(chase_active))
		print("Desp Safe? " + str(desp_safe))
		print(" ------------------------- ")

func handle_gravity(delta):
	if desp_safe or stun_duration.time_left != 0:
		gravity = 0
	elif !is_on_floor():
		gravity = 500 * delta
	else:
		gravity = 0

func handle_distance_and_noise():
	# Finds distance from target
	xxx = abs(self.global_position.x - target_pos.x)
	yyy = abs(self.global_position.y - target_pos.y)
	zzz = abs(self.global_position.z - target_pos.z)
	distance_from_target = xxx + yyy + zzz
	
	# Responds to noise only if not currently chasing the player
	if !chase_active:
		if GlobalLevelStats.MAX_NOISE_ACTIVE and priority < 4:
			trigger_huh()
			priority = 3
			target_pos = GlobalLevelStats.MAX_NOISE_LOCATION
			GlobalLevelStats.max_response_count += 2
			print("Twins: Max Noise Heard")
		
		# If monster reaches desired destination, change targets to a random point of interest
		if current_state != States.SPAWN and current_state != States.STUNNED:
			if distance_from_target < 6.0 and priority < 4:
				reset_wander()

func trigger_huh():
	current_state = States.HUH
	rotate_lock = true
	huh_duration.start()
	visuals.scale = Vector3(50,50,50)
	boost_count = 0
	boost_count_rate.stop()

# Automatic target changing from huh state
func _on_huh_duration_timeout() -> void:
	print("Twins: Huh Complete.")
	rotate_lock = false
	boredom_timer.start()
	boost_count_rate.start()
	change_speed()

func trigger_stare():
	print("Twins: Stare Complete!")
	current_state = States.STARE
	rotate_lock = true
	stare_duration.start()
	boost_count = 0
	boost_count_rate.stop()

# If player has not run from the monster, this will trigger a chase
func _on_stare_duration_timeout() -> void:
	rotate_lock = false
	if current_state == States.STARE:
		chase_active = true
		if chase_duration.is_stopped():
			chase_duration.start()
		boost_count_rate.start()
		change_speed()

func change_speed():
	if GlobalLevelStats.EXIT_OPEN:
		print("Twins: Speed - Endgame")
		current_state = States.ENDGAME
	
	elif chase_active and !GlobalLevelStats.EXIT_OPEN:
		print("Twins: Speed - Chase")
		current_state = States.CHASE
	
	elif priority == 4 and !chase_active:
		print("Twins: Speed - Pursuit")
		current_state = States.PURSUIT
	
	elif priority == 3:
		print("Twins: Speed - Pursuit")
		current_state = States.PURSUIT
	
	elif priority < 3 and priority != 0:
		print("Twins: Speed - Curious")
		current_state = States.CURIOUS
	
	elif priority == 0:
		print("Twins: Speed - Wander")
		current_state = States.WANDER
		boost_count = 0
		boost_count_rate.stop()

func reset_wander():
	# Resets monster's pathing and speed, forcing them to find a new target in the process
	current_state = States.WANDER
	rotate_lock = false
	priority = 0
	boost_count = 0
	boost_count_rate.stop()
	
	previous_target_pos = target_pos
	target_pos = GlobalLevelStats.Points_of_Interest_Wolf.pick_random()
	
	# If the prior target is identical to the last, rerun script until a new one is found
	# Can crash if it gets the same target 1024 times in a row, but that won't happen... right?
	if target_pos.round() == previous_target_pos.round():
		reset_wander()
	else:
		# If a new target is selected, updates the speed and possibly the hearing radius of the monster
		boredom_timer.start()
		print("Twins: Wandering to " + str(target_pos))
		if priority == 3 or priority == 0:
			if detective_anti_spam.is_stopped():
				detective_anti_spam.start()
				detective_points += 1
				hearing_area.shape.radius = (40.0 + difficulty) + ((difficulty/2.0) * detective_points)
				light_ray.target_position.z = -(hearing_area.shape.radius) - 0.5
		change_speed()

# Resets target if monster gets stuck on one for too long
func _on_boredom_timer_timeout() -> void:
	if !chase_active:
		print("Twins: Bored with Target. Switching Targets...")
		reset_wander()

# Used to handle perpetual actions
func handle_state_actions(_delta):
	#Section for forcing states to change
	if GlobalLevelStats.DESPERATION_MODE:
		current_state = States.DESPERATION
	
	elif !hurt_duration.is_stopped():
		current_state = States.HURT
	
	
	elif GlobalLevelStats.EXIT_OPEN and stun_duration.is_stopped() and spawn_timer.is_stopped():
		current_state = States.ENDGAME
	
	match current_state:
		States.SPAWN:
			true_speed = 0
		
		States.HUH:
			true_speed = 0
		
		States.HURT:
			rotate_lock = true
			
			
		
		States.STARE:
			true_speed = 0
			if distance_from_target > player_ray.target_position.z  or distance_from_target < 40:
				chase_active = true
				if chase_duration.is_stopped():
					chase_duration.start()
				change_speed()
		
		States.DESPERATION:
			true_speed = 0
			rotate_lock = true
			
			# If this was the monster that triggered desperation, start QTE.
			if desp_safe:
				main_collision.disabled = true
				global_position = target_pos
				
				if Input.is_action_just_pressed("attack"):
					if GlobalLevelStats.DESPERATION_SAVE_ACTIVE:
						GlobalLevelStats.DESPERATION_MODE = false
						GlobalLevelStats.DESPERATION_SAVE_ACTIVE = false
						priority = 0
						detective_points = 0
						current_state = States.STUNNED
						desp_safe = false
						boost_active = false
						vision_active = false
						chase_prep = false
						chase_active = false
						#HEY! CHANGE THIS SHIT ONCE YOU GET ANIMATIONS IN HERE DUMBASS!
						testingdesperationtimer.stop()
						stun_duration.start()
						print("Twins: Stunned!")
					else:
						print("TWINS: PLAYER KILL")
						GlobalLevelStats.game_over()
			#If this monster did not land the attack but another did, respawn.
			else:
				reset_respawn()
		
		States.STUNNED:
			true_speed = 0
			rotate_lock = true
			
			#print("Twins: Stun Duration = " + str(stun_duration.time_left))
			target_pos = GlobalPlayerStats.Player_Position
			
			# Forces Monster to respawn if the player survives and is out of range
			if distance_from_target > 250:
				reset_respawn()
		
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
			chase_active = true
			true_speed = (base_move_speed + (difficulty * 2.5)) * 1.5 + (difficulty * (boost_count * 2))
		
		States.ENDGAME:
			true_speed = (base_move_speed + (difficulty * 2.5)) * 1.5 + (difficulty * (boost_count * 2))


func handle_line_of_sight():
	if vision_active:
		ray_parent.look_at(GlobalPlayerStats.Player_Position)
		
		#This one checks to see if the light is visible
		if light_ray.is_colliding():
			var ray_target = light_ray.get_collider()
			
			if ray_target.is_in_group("player_light") and !chase_active:
				if priority < 4:
					trigger_huh()
					print("Twins: Light Spotted!")
				priority = 4
				target_pos = GlobalPlayerStats.Player_Position
				
		
		#This one checks to see if the player is visible
		if player_ray.is_colliding():
			var ray_target = player_ray.get_collider()
			
			if ray_target.is_in_group("player") and !chase_active:
				if !chase_prep:
					trigger_stare()
					print("Twins: PLAYER SEEN!")
				priority = 4
				target_pos = GlobalPlayerStats.Player_Position
				chase_active = true
				chase_prep = true

func handle_chase_logic():
	if chase_active and !desp_safe:
		rotate_lock = false
		current_state = States.CHASE
		target_pos = GlobalPlayerStats.Player_Position
		attack_hitbox.disabled = false
	else:
		attack_hitbox.disabled = true

func _on_boost_count_rate_timeout() -> void:
	#Maxes out at the fastest speed it should have, difficulty effects scaling
	if true_speed < 1000:
		boost_count += 1

#When chase goes on for too long, this resets everything back to the wander state
func _on_chase_duration_timeout() -> void:
	if current_state == States.CHASE:
		print("Twins: Chase Over - Out of Time")
		chase_prep = false
		chase_active = false
		reset_wander()

#Used to teleport the monster away when the player is caught by a different monster
func reset_respawn():
	main_collision.disabled = false
	rotate_lock = false
	self.global_position = spawn_location
	current_state = States.SPAWN
	vision_area.disabled = true
	hearing_area.disabled = true
	attack_hitbox.disabled = true
	desp_safe = false
	spawn_timer.wait_time = 30.0 - difficulty
	spawn_timer.start()
	print("Twins: Respawning...")

#If the player is still in range when the stun wares off, monster will begin wandering again
func _on_stun_duration_timeout() -> void:
	main_collision.disabled = false
	print("Twins: Stun Complete.")
	reset_wander()

#AREA REACTIONS HERE
func _on_main_hurtbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("player_attack"):
		remaining_knockback = hurt_knockback
		hurt_duration.start()

func _on_hurt_duration_timeout() -> void:
	if priority < 4:
		current_state = States.WANDER
	else:
		current_state = States.CHASE
		chase_active = true

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

func _on_vision_area_area_entered(area: Area3D) -> void:
	if area.is_in_group("player_light"):
		vision_active = true
		print("Twins: Vision Active")
func _on_vision_area_area_exited(area: Area3D) -> void:
	if area.is_in_group("player_light"):
		vision_active = false
		print("Twins: No Vision")

func _on_attack_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		desp_safe = true
		chase_prep = false
		chase_active = false
		current_state = States.DESPERATION
		GlobalLevelStats.DESPERATION_MODE = true
		print("Twins: ATTACKING")
		#HEY! CHANGE THIS SHIT ONCE YOU GET ANIMATIONS IN HERE DUMBASS!
		GlobalLevelStats.DESPERATION_SAVE_ACTIVE = true
		testingdesperationtimer.start()

#HEY! CHANGE THIS SHIT ONCE YOU GET ANIMATIONS IN HERE DUMBASS!
#MAKE SURE TO RESET THE GLOBAL VALUES WHEN A GAME OVER IS TRIGGERED!
func _on_testingdesperationtimer_timeout() -> void:
	current_state = States.SPAWN
	reset_respawn()
	GlobalLevelStats.game_over()


func _on_navigation_agent_3d_link_reached(details: Dictionary) -> void:
	global_position = details.link_exit_position
	global_position.y = details.link_exit_position.y + 5.0
