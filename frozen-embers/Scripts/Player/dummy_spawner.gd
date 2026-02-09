extends Camera3D

@export_subgroup("Spawns")
@export var dummy : PackedScene

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		shoot_ray()

func shoot_ray():
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
		#instance.scale = Vector3(50,50,50)
		add_sibling(instance)
		
		#GlobalLevelStats.MAX_NOISE_ACTIVE = true
		#GlobalLevelStats.MAX_NOISE_LOCATION = raycast_result["position"]
		#print("Max Noise Location: " + str(GlobalLevelStats.MAX_NOISE_LOCATION))
