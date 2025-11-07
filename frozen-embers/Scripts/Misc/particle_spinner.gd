extends GPUParticles3D

@export var y_speed = 0.1

func _process(delta: float) -> void:
	rotate_y(y_speed * delta)
