extends Node3D

# Variables taken from children
@onready var camera_mount = $CameraMount
@onready var spring_arm_3d: SpringArm3D = $CameraMount/SpringArm3D

# Variables that can be edited in engine

var target: Node

@export_group("Properties")
@export var camera_sensitivity = 0.25

# Locks Mouse to window
func _ready():
	target = get_tree().get_first_node_in_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

 #Tracks position of "View" in space
func _physics_process(delta):
	self.position = self.position.lerp(target.position, delta * 5.5)
	spring_arm_3d.spring_length = 2.0 + ((GlobalPlayerStats.Light + 50)/10)
	
	controller_rotation()

# Moves camera view
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x*camera_sensitivity))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y*camera_sensitivity))
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, -(PI/2 - 0.5), (PI/4 - 0.65))

func controller_rotation():
	if Input.is_action_pressed("controller_rotate_left"):
		rotate_y(deg_to_rad(6*camera_sensitivity))
	if Input.is_action_pressed("controller_rotate_right"):
		rotate_y(deg_to_rad(-6*camera_sensitivity))
	if Input.is_action_pressed("controller_rotate_up"):
		camera_mount.rotate_x(deg_to_rad(6*camera_sensitivity))
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, -(PI/2 - 0.5), (PI/4 - 0.65))
	if Input.is_action_pressed("controller_rotate_down"):
		camera_mount.rotate_x(deg_to_rad(-6*camera_sensitivity))
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, -(PI/2 - 0.5), (PI/4 - 0.65))
