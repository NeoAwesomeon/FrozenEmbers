extends State

class_name HighJumpPlayer

# These variables keep track of the CharacterBody3D's mobility
var player_body
var point_of_view
var movement_velocity: Vector3
var rotation_direction: float

# These variables will constantly change based on how the player acts
@export var high_jump_strength = 16.5

var gravity = 0.0

func enter():
	print("Current State: High Jump")
	point_of_view = get_tree().get_first_node_in_group("player_pov")
	player_body = state_machine.get_parent()
	
	gravity = -high_jump_strength

func physics_update(delta):
	
	var applied_velocity: Vector3
	
	handle_gravity(delta)
	
	# Converts velocity into usable data while refreshing script and accounting for uncontrolled influences
	applied_velocity = player_body.velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	player_body.velocity = applied_velocity
	player_body.move_and_slide()
	
	GlobalPlayerStats.PLAYER_CURRENT_STATE = "High Jump"

func handle_gravity(delta):
	#Constantly applies gravity to the player that slowly ramps up over time
	gravity += 25 * delta
	
	#Resets gravity while on the floor and gives a small bit of time for a jump
	if gravity > 0:
		state_machine.change_state("FreedomStatePlayer")
	
