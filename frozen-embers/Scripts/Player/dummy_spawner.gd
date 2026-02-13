extends Camera3D

@onready var desperation_warning: Label = $"VBoxContainer/Desperation Warning"

@export_subgroup("Spawns")
@export var pause_menu : PackedScene
@export var dummy : PackedScene
@export var major : PackedScene
@export var minor : PackedScene


func _process(_delta: float) -> void:
	if GlobalLevelStats.DESPERATION_MODE:
		desperation_warning.text = "LEFT CLICK TO STUN MONSTER"
	else:
		desperation_warning.text = "Stun Unavailable..."

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		add_sibling(pause_menu.instantiate())
	
	if event.is_action_pressed("debug_1"):
		shoot_dummy_ray()
	if event.is_action_pressed("debug_2"):
		shoot_max_ray()
	if event.is_action_pressed("debug_3"):
		shoot_major_ray()
	if event.is_action_pressed("debug_4"):
		shoot_minor_ray()

func shoot_dummy_ray():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 2000
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var raycast_result = space.intersect_ray(ray_query)
	
	if !raycast_result.is_empty():
		var instance = dummy.instantiate()
		instance.position = raycast_result["position"]
		add_sibling(instance)


func shoot_max_ray():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 2000
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var raycast_result = space.intersect_ray(ray_query)
	
	if !raycast_result.is_empty():
		GlobalLevelStats.MAX_NOISE_ACTIVE = true
		GlobalLevelStats.MAX_NOISE_LOCATION = raycast_result["position"]
		print("Max Noise Location: " + str(GlobalLevelStats.MAX_NOISE_LOCATION))

func shoot_major_ray():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 2000
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var raycast_result = space.intersect_ray(ray_query)
	
	if !raycast_result.is_empty():
		var instance = major.instantiate()
		instance.position = raycast_result["position"]
		instance.scale = Vector3(10,10,10)
		add_sibling(instance)

func shoot_minor_ray():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 2000
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var raycast_result = space.intersect_ray(ray_query)
	
	if !raycast_result.is_empty():
		var instance = minor.instantiate()
		instance.position = raycast_result["position"]
		instance.scale = Vector3(10,10,10)
		add_sibling(instance)
