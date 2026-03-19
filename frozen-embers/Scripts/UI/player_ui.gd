extends Control

@onready var state_label: Label = $VBoxContainer/StateLabel

@onready var boost_label: Label = $VBoxContainer/SpeedDisplays/Panel/BoostLabel
@onready var speed_meter: ProgressBar = $VBoxContainer/SpeedDisplays/SpeedMeter
@onready var speed_label: Label = $VBoxContainer/SpeedDisplays/SpeedMeter/SpeedLabel

@onready var gravity_label: Label = $VBoxContainer/SpeedDisplays/Panel2/GravityLabel

@onready var light_meter: ProgressBar = $VBoxContainer/LightMeter
@onready var light_label: Label = $VBoxContainer/LightMeter/LightLabel

@onready var heat_meter: ProgressBar = $VBoxContainer/HeatMeter
@onready var heat_label: Label = $VBoxContainer/HeatMeter/HeatLabel

@onready var heat_shield_meter: ProgressBar = $VBoxContainer/HeatShieldMeter
@onready var heat_shield_label: Label = $VBoxContainer/HeatShieldMeter/HeatShieldLabel

@onready var freeze_meter: ProgressBar = $VBoxContainer/HeatMeter/FreezeMeter

@onready var noise_meter: ProgressBar = $VBoxContainer/NoiseMeter
@onready var noise_label: Label = $VBoxContainer/NoiseMeter/NoiseLabel

@onready var progres_counter: Label = $ProgresCounter

@onready var speed_displays: HBoxContainer = $VBoxContainer/SpeedDisplays

@onready var debug_invin: Label = $DebugVBoxContainer/DebugInvin
@onready var debug_obliv: Label = $DebugVBoxContainer/DebugObliv


var xxx : int = 0
var yyy : int = 0
var zzz : int = 0
var distance : int = 1

var stat_toggle : bool = false

func _ready() -> void:
	debug_invin.visible = false
	debug_obliv.visible = false
	debug_show_stats()

func debug_show_stats():
	if !stat_toggle:
		state_label.visible = false
		boost_label.visible = false
		light_label.visible = false
		heat_label.visible = false
		heat_shield_label.visible = false
		speed_displays.visible = false
		noise_label.visible = false
	else:
		state_label.visible = true
		boost_label.visible = true
		light_label.visible = true
		heat_label.visible = true
		heat_shield_label.visible = true
		speed_displays.visible = true
		noise_label.visible = true

func _process(_delta: float) -> void:
	
	handle_debug()
	
	state_label.text = GlobalPlayerStats.PLAYER_CURRENT_STATE
	boost_label.text = "x" + str(GlobalPlayerStats.PLAYER_BOOST_COUNT)
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
	
	if GlobalPlayerStats.PLAYER_NOISE_SIZE < 1.0:
		noise_meter.value = 0.0
	else:
		noise_meter.value = GlobalPlayerStats.PLAYER_NOISE_SIZE
	noise_label.text = "Noise: " + str(snapped(GlobalPlayerStats.PLAYER_NOISE_SIZE, 0.1))
	
	# Compares player's location with that of the exit's to find the distance
	if !GlobalLevelStats.EXIT_OPEN:
		progres_counter.text = "Beacons: " + str(GlobalLevelStats.REMAINING_BEACONS)
	else:
		xxx = abs(GlobalPlayerStats.Player_Position.x - GlobalLevelStats.EXIT_LOCATION.x)
		yyy = abs(GlobalPlayerStats.Player_Position.y - GlobalLevelStats.EXIT_LOCATION.y)
		zzz = abs(GlobalPlayerStats.Player_Position.z - GlobalLevelStats.EXIT_LOCATION.z)
		distance = snapped(xxx + yyy + zzz, 1)
		progres_counter.text = str(distance - 2)

func handle_debug():
	if Input.is_action_just_pressed("debug_1"):
		if !stat_toggle:
			stat_toggle = true
		else:
			stat_toggle = false
		debug_show_stats()
	
	if Input.is_action_just_pressed("debug_4"):
		if !debug_invin.visible:
			debug_invin.visible = true
		else:
			debug_invin.visible = false
	
	if Input.is_action_just_pressed("debug_5"):
		if !debug_obliv.visible:
			debug_obliv.visible = true
		else:
			debug_obliv.visible = false
