extends CharacterBody3D

@onready var hurtbox: Area3D = $Hurtbox

var prep = false

func _ready() -> void:
	GlobalPlayerStats.Player_Position = hurtbox.global_position

func _on_hurtbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("monster_attack"):
		prep = true

func _process(_delta: float) -> void:
	if prep and !GlobalLevelStats.DESPERATION_MODE:
		queue_free()
	
	if Input.is_action_just_pressed("extinguish"):
		queue_free()
