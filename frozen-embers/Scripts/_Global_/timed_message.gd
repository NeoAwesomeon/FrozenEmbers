extends Label

@onready var timer: Timer = $Timer

func _ready() -> void:
	self.visible = false

func _on_timer_timeout() -> void:
	self.visible = false
