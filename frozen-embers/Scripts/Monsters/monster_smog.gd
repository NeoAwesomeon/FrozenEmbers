extends Node3D

@onready var visuals: Node3D = $Visuals

# Timers
@onready var wake_up_timer: Timer = $Timers/WakeUpTimer

# Stats
@export_category("Monster Stats")
@export_range(-1, 20) var difficulty : int = 0
@export var base_move_speed : float = 5.0
@export var max_move_speed : float = 16.0
@export var adaptation_1 : bool = false
@export var adaptation_2 : bool = false
@export var adaptation_3 : bool = false
@export var adaptation_4 : bool = false

var active : bool = false
var in_wall : bool = false
var rubber_band : bool = false
var true_speed : float = 0.0
var added_speed : float = 0.0
var freezing : float = 0.0

#Used to measure distance from objectives in prefered units
var xxx = 0
var yyy = 0
var zzz = 0
var distance_from_target = 0

func _ready() -> void:
	difficulty = GlobalLevelStats.Smog_Difficulty
	# Instantly destroys this monster if the difficulty is set to a negative value
	if difficulty == -1:
		queue_free()
	
	GlobalLevelStats.NUMBER_OF_MONSTERS += 1
	wake_up_timer.wait_time = 5.0 - (difficulty/10.0)
	wake_up_timer.start()
	print_rich("[color=black]Smog: Active in " + str(wake_up_timer.wait_time) + "[color=black] seconds...")
	
	visuals.scale = Vector3(0.01,0.01,0.01)
	visuals.visible = true

func _on_wake_up_timer_timeout() -> void:
	active = true
	print_rich("[color=black]Smog: Wake Up Complete.")

func _process(delta: float) -> void:
	
	# Finds distance from target
	xxx = abs(global_position.x - GlobalPlayerStats.Player_Position.x)
	yyy = abs(global_position.y - GlobalPlayerStats.Player_Position.y)
	zzz = abs(global_position.z - GlobalPlayerStats.Player_Position.z)
	distance_from_target = xxx + yyy + zzz
	
	if distance_from_target > 200:
		rubber_band = true
	else:
		rubber_band = false
	
	var direction: Vector3 = (GlobalPlayerStats.Player_Position - global_position).normalized()
	look_at(GlobalPlayerStats.Player_Position)
	
	if active:
		if true_speed < max_move_speed or rubber_band:
			added_speed += (0.5 + (difficulty/20.0)) * delta
		else:
			true_speed = max_move_speed
		
		if rubber_band:
			true_speed = (base_move_speed + added_speed) * 3.0
			visuals.scale = visuals.scale.lerp(Vector3(3.0,3.0,3.0), delta)
		elif !in_wall:
			true_speed = base_move_speed + added_speed
			visuals.scale = visuals.scale.lerp(Vector3(1.0 + (true_speed/max_move_speed), 1.0 + (true_speed/max_move_speed), 1.0 + (true_speed/max_move_speed)), delta)
		else:
			true_speed = (base_move_speed + added_speed) * 0.75
			visuals.scale = visuals.scale.lerp(Vector3((1.0 + (true_speed/max_move_speed))/2, (1.0 + (true_speed/max_move_speed))/2, (1.0 + (true_speed/max_move_speed))/2), delta * 3.0)
		
		# Floats to player
		if distance_from_target > 2:
			global_position += direction * true_speed * delta
		
		if freezing:
			GlobalPlayerStats.Freeze_Goal += (30.0 + (difficulty * 4)) * delta
			GlobalPlayerStats.Freeze += (30.0 + (difficulty * 4)) * delta
	else:
		visuals.scale = visuals.scale.lerp(Vector3(1,1,1), delta)
	
	if Input.is_action_just_pressed("debug_0"):
		print_rich("[color=white]>---<[color=black]SMOG CHECKUP[color=white]>---<")
		print_rich("[color=black]Difficulty = " + str(difficulty))
		print_rich("[color=black]Target Distance: " + str(distance_from_target))
		print_rich("[color=black]Rubber Banding?: " + str(rubber_band))
		print_rich("[color=black]In a wall?:" + str(in_wall))
		print_rich("[color=black]Speed:" + str(true_speed))
		print_rich("[color=black]Freezing?: " + str(freezing))
		print_rich("[color=white]>----------------------<")


func _on_area_3d_body_entered(_body: Node3D) -> void:
	if !in_wall:
		if added_speed < 5.0 - (difficulty/10.0):
			added_speed = 0.0
		else:
			added_speed -= 5.0 - (difficulty/10.0)
			added_speed /= 2.0
		in_wall = true

func _on_area_3d_body_exited(_body: Node3D) -> void:
	in_wall = false



func _on_attack_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		freezing = true

func _on_attack_hitbox_area_exited(area: Area3D) -> void:
	if area.is_in_group("player"):
		freezing = false
