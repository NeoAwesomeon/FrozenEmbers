@tool
extends Node3D

# Variables taken from children
@onready var camera_mount = $CameraMount
@onready var spring_arm_3d: SpringArm3D = $CameraMount/SpringArm3D
@onready var shader_filter: MeshInstance3D = $CameraMount/SpringArm3D/Camera3D/ShaderFilter

# Variables that can be edited in engine
var target: Node

var clear_filter : bool = false

# Locks Mouse to window
func _ready():
	if not Engine.is_editor_hint():
		target = get_tree().get_first_node_in_group("player")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

 #Tracks position of "View" in space
func _physics_process(delta):
	if Engine.is_editor_hint():
		shader_filter.visible = false
	
	if not Engine.is_editor_hint():
		self.position = self.position.lerp(target.position, delta * 5.5)
		spring_arm_3d.spring_length = 2.0 + ((GlobalPlayerStats.Light + 50)/10)
		
		controller_rotation()

# Moves camera view
func _input(event):
	if not Engine.is_editor_hint():
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * GlobalOptionSettings.camera_sensitivity))
			camera_mount.rotate_x(deg_to_rad(-event.relative.y*GlobalOptionSettings.camera_sensitivity))
			camera_mount.rotation.x = clamp(camera_mount.rotation.x, -(PI/2 - 0.5), (PI/4 - 0.65))
		
		if event.is_action_pressed("debug_2"):
			if shader_filter.visible:
				shader_filter.visible = false
			else:
				shader_filter.visible = true

func controller_rotation():
	if Input.is_action_pressed("controller_rotate_left"):
		rotate_y(deg_to_rad(6*GlobalOptionSettings.camera_sensitivity))
	if Input.is_action_pressed("controller_rotate_right"):
		rotate_y(deg_to_rad(-6*GlobalOptionSettings.camera_sensitivity))
	if Input.is_action_pressed("controller_rotate_up"):
		camera_mount.rotate_x(deg_to_rad(6*GlobalOptionSettings.camera_sensitivity))
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, -(PI/2 - 0.5), (PI/4 - 0.65))
	if Input.is_action_pressed("controller_rotate_down"):
		camera_mount.rotate_x(deg_to_rad(-6*GlobalOptionSettings.camera_sensitivity))
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, -(PI/2 - 0.5), (PI/4 - 0.65))
