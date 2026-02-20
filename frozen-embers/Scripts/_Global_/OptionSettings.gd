extends Node

var MASTER_AUDIO : float = 1.0
var MUSIC_AUDIO : float = 1.0
var SFX_AUDIO : float = 1.0

enum INPUT_SCHEMES {KEYBOARD, CONTROLLER}
static var CURRENT_SCHEME: INPUT_SCHEMES = INPUT_SCHEMES.KEYBOARD

var settings_steal_focus = false

func _input(event: InputEvent) -> void:
	if CURRENT_SCHEME == INPUT_SCHEMES.CONTROLLER and (event is InputEventKey or event is InputEventMouse):
		CURRENT_SCHEME = INPUT_SCHEMES.KEYBOARD
		print("keyboard")
	elif CURRENT_SCHEME == INPUT_SCHEMES.KEYBOARD and (event is InputEventJoypadButton or event is InputEventJoypadMotion):
		CURRENT_SCHEME  = INPUT_SCHEMES.CONTROLLER
		print("gamepad") 
