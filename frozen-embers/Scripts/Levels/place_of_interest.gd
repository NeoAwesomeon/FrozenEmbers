extends Area3D

@onready var collision_shape: CollisionShape3D = $CollisionShape3D


@export var area_scale : float = 0.5
@export_category("Monsters")
@export var wolves : bool = true

func _ready() -> void:
	collision_shape.shape.radius = area_scale
	
	if wolves:
		GlobalLevelStats.Points_of_Interest_Wolf.append(self.global_position)
