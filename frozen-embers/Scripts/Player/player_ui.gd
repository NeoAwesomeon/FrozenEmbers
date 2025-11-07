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

func _process(_delta: float) -> void:
	
	state_label.text = GlobalPlayerStats.PLAYER_CURRENT_STATE
	boost_label.text = str(GlobalPlayerStats.PLAYER_BOOST_COUNT)
	speed_meter.value = GlobalPlayerStats.PLAYER_CURRENT_SPEED
	speed_label.text = str(snapped(GlobalPlayerStats.PLAYER_CURRENT_SPEED, 1))
	gravity_label.text = str(GlobalPlayerStats.PLAYER_GRAVITY)
	
	
	light_meter.value = GlobalPlayerStats.Light
	light_meter.max_value = GlobalPlayerStats.Light_Max
	light_meter.min_value = GlobalPlayerStats.Light_Min
	light_label.text = str(GlobalPlayerStats.Light_Goal)
	
	heat_meter.value = GlobalPlayerStats.Heat
	heat_meter.max_value = GlobalPlayerStats.Heat_Max
	heat_meter.min_value = 0
	heat_label.text = str(snapped(GlobalPlayerStats.Heat , 1))
	
	heat_shield_meter.value = GlobalPlayerStats.PLAYER_HEAT_SHIELD
	heat_shield_label.text = str(snapped(GlobalPlayerStats.PLAYER_HEAT_SHIELD, 0.01))
	
	freeze_meter.value = GlobalPlayerStats.Freeze
	freeze_meter.max_value = GlobalPlayerStats.Heat_Max
	
