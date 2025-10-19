extends Node3D

# Variables taken from children
@onready var camera_mount = $CameraMount

# Variables that can be edited in engine
@export_group("Auxiliary")
@export var target: Node
@export_group("Properties")
@export var camera_sensitivity = 0.25

# Locks Mouse to window
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

 #Tracks position of "View" in space
func _physics_process(delta):
	self.position = self.position.lerp(target.position, delta * 5.5)

# Moves camera view
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x*camera_sensitivity))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y*camera_sensitivity))
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, -(PI/2 - 0.5), (PI/4 - 0.65))
