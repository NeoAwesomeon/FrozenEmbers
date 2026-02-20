extends Button
class_name InputReMapButton

# The action that will be remapped
@export var action: String
# The position the action is in starting from 0 in Project Settings
@export var action_event_index: int = 0

const CONTROLLER_LABELS: Dictionary = {
		JoyButton.JOY_BUTTON_A: "A",
		JoyButton.JOY_BUTTON_B: "B",
		JoyButton.JOY_BUTTON_X: "X",
		JoyButton.JOY_BUTTON_Y: "Y",
		JoyButton.JOY_BUTTON_LEFT_SHOULDER: "LB",
		JoyButton.JOY_BUTTON_RIGHT_SHOULDER: "RB",
		JoyButton.JOY_BUTTON_LEFT_STICK: "L3",
		JoyButton.JOY_BUTTON_RIGHT_STICK: "R3",
		JoyButton.JOY_BUTTON_DPAD_UP: "D Pad Up",
		JoyButton.JOY_BUTTON_DPAD_DOWN: "D Pad Down",
		JoyButton.JOY_BUTTON_DPAD_LEFT: "D Pad Left",
		JoyButton.JOY_BUTTON_DPAD_RIGHT: "D Pad Right",
		JoyButton.JOY_BUTTON_START: "Start",
		JoyButton.JOY_BUTTON_GUIDE: "Select"
}

func _ready() -> void:
	toggle_mode = true
	_toggled(false)

func _toggled(toggled_on: bool) -> void:
	if !action or !InputMap.has_action(action):
		return
	
	if toggled_on:
		text = "AWAITING INPUT!!!"
		return
	
	# If no butotns are assigned to desired action
	if action_event_index >= InputMap.action_get_events(action).size():
		text = "Unassigned..."
		return
	
	# If action has a button assigned...
	var input = InputMap.action_get_events(action)[action_event_index]
	
	# Controller Version
	if input is InputEventJoypadButton:
		if CONTROLLER_LABELS.has(input.button_index):
			text = CONTROLLER_LABELS.get(input.button_index)
		else:
			text = "Button " + str(input.button_index)
	
	elif input is InputEventJoypadMotion:
		if input.axis == 0:
			if input.axis_value > 0.1:
				text = "Left Analog - Right"
			elif input.axis_value < -0.1:
				text = "Left Analog - Left"
			
		elif input.axis == 1:
			if input.axis_value > 0.1:
				text = "Left Analog - Down"
			elif input.axis_value < -0.1:
				text = "Left Analog - Up"
			
		elif input.axis == 2:
			if input.axis_value > 0.1:
				text = "Right Analog - Right"
			elif input.axis_value < -0.1:
				text = "Right Analog - Left"
			
		elif input.axis == 3:
			if input.axis_value > 0.1:
				text = "Right Analog - Down"
			elif input.axis_value < -0.1:
				text = "Right Analog - Up"
		
		elif input.axis == 4:
			text = "LT"
		
		elif input.axis == 5:
			text = "RT"
	
	# Keyboard Version
	elif input is InputEventKey:
		if input.physical_keycode != 0:
			text = OS.get_keycode_string(input.physical_keycode)
		else:
			text = OS.get_keycode_string(input.keycode)

func _unhandled_input(event: InputEvent) -> void:
	# If button is not being used
	if !InputMap.has_action(action) or !is_pressed():
		return
	
	# Checks if the button is pressed and an appropriate input is used
	if event.is_pressed() and (event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion):
		if event is InputEventJoypadMotion:
			if event.axis_value > 0.1:
				event.axis_value = 1.0
			elif event.axis_value < -0.1:
				event.axis_value = -1.0
		var action_events_list = InputMap.action_get_events(action)
		
		# Removes the old action
		if action_event_index < action_events_list.size():
			InputMap.action_erase_event(action, action_events_list[action_event_index])
		# Adds in the new event
		InputMap.action_add_event(action,event)
		action_event_index = InputMap.action_get_events(action).size()-1
		button_pressed = false
		
