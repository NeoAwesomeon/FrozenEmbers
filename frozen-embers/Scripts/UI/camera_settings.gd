extends VBoxContainer

@onready var camera_label: Label = $"Camera Sensitivity/HBoxContainer/CameraLabel"
@onready var camera_slider: HSlider = $"Camera Sensitivity/HBoxContainer/CameraSlider"

func _ready() -> void:
	camera_slider.value = GlobalOptionSettings.camera_sensitivity

func _on_camera_slider_value_changed(value: float) -> void:
	camera_label.text = str(value)
	GlobalOptionSettings.camera_sensitivity = value
