extends Area3D

@export var area_scale : float = 0.5
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	collision_shape.shape.radius = area_scale
	GlobalLevelStats.Points_of_Interest.append(self.global_position)
