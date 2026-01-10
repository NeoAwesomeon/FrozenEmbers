extends Control

@onready var state_label: Label = $VBoxContainer/StateLabel

@onready var boost_label: Label = $VBoxContainer/HBoxContainer/Panel/BoostLabel
@onready var speed_meter: ProgressBar = $VBoxContainer/HBoxContainer/SpeedMeter
@onready var speed_label: Label = $VBoxContainer/HBoxContainer/SpeedMeter/SpeedLabel

@onready var gravity_label: Label = $VBoxContainer/HBoxContainer/Panel2/GravityLabel

@onready var light_meter: ProgressBar = $VBoxContainer/LightMeter
@onready var light_label: Label = $VBoxContainer/LightMeter/LightLabel

@onready var heat_meter: ProgressBar = $VBoxContainer/HeatMeter
@onready var heat_label: Label = $VBoxContainer/HeatMeter/HeatLabel

@onready var heat_shield_meter: ProgressBar = $VBoxContainer/HeatShieldMeter
@onready var heat_shield_label: Label = $VBoxContainer/HeatShieldMeter/HeatShieldLabel

@onready var freeze_meter: ProgressBar = $VBoxContainer/HeatMeter/FreezeMeter

@onready var progres_counter: Label = $ProgresCounter
var xxx
var yyy = 0
var zzz = 0
var distance = 1

func _process(_delta: float) -> void:
	
	state_label.text = GlobalPlayerStats.PLAYER_CURRENT_STATE
	boost_label.text = str(GlobalPlayerStats.PLAYER_BOOST_COUNT)
	speed_meter.value = GlobalPlayerStats.PLAYER_CURRENT_SPEED
	speed_label.text = "Speed: " + str(snapped(GlobalPlayerStats.PLAYER_CURRENT_SPEED, 1))
	gravity_label.text = str(GlobalPlayerStats.PLAYER_GRAVITY)
	
	
	light_meter.value = GlobalPlayerStats.Light
	light_meter.max_value = GlobalPlayerStats.Light_Max
	light_meter.min_value = GlobalPlayerStats.Light_Min
	light_label.text = "Light: " + str(GlobalPlayerStats.Light_Goal)
	
	heat_meter.value = GlobalPlayerStats.Heat
	heat_meter.max_value = GlobalPlayerStats.Heat_Max_Start_Value
	heat_meter.min_value = 0
	heat_label.text = "Heat: " + str(snapped(GlobalPlayerStats.Heat , 1)) + "/" + str(snapped(GlobalPlayerStats.Heat_Max , 1))
	
	heat_shield_meter.value = GlobalPlayerStats.PLAYER_HEAT_SHIELD
	heat_shield_label.text = str(snapped(GlobalPlayerStats.PLAYER_HEAT_SHIELD, 0.01))
	
	freeze_meter.value = GlobalPlayerStats.Freeze
	freeze_meter.max_value = GlobalPlayerStats.Freeze_Max
	
	# Compares player's location with that of the exit's to find the distance
	if !GlobalLevelStats.EXIT_OPEN:
		progres_counter.text = "Beacons: " + str(GlobalLevelStats.REMAINING_BEACONS)
	else:
		xxx = abs(GlobalPlayerStats.Player_Position.x - GlobalLevelStats.EXIT_LOCATION.x)
		yyy = abs(GlobalPlayerStats.Player_Position.y - GlobalLevelStats.EXIT_LOCATION.y)
		zzz = abs(GlobalPlayerStats.Player_Position.z - GlobalLevelStats.EXIT_LOCATION.z)
		distance = snapped(xxx + yyy + zzz, 1)
		progres_counter.text = str(distance - 2)
