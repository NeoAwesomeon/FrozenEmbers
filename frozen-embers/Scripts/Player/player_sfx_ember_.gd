extends Node

@onready var footstep: AudioStreamPlayer = $Footstep
@onready var crumple: AudioStreamPlayer = $Crumple
@onready var fire_swing: AudioStreamPlayer = $FireSwing
@onready var low_woosh: AudioStreamPlayer = $LowWoosh
@onready var reverb_woosh: AudioStreamPlayer = $ReverbWoosh
@onready var soft_slide: AudioStreamPlayer = $SoftSlide
@onready var soft_slide_loop: AudioStreamPlayer = $SoftSlideLoop
@onready var torch_loop: AudioStreamPlayer = $TorchLoop
@onready var special_fire_loop: AudioStreamPlayer = $SpecialFireLoop
@onready var heartbeat: AudioStreamPlayer = $Heartbeat
@onready var fire_fwomf: AudioStreamPlayer = $FireFwomf
@onready var boom: AudioStreamPlayer = $Boom
@onready var flap: AudioStreamPlayer = $Flap
@onready var snuff_fire: AudioStreamPlayer = $SnuffFire
@onready var freezing: AudioStreamPlayer = $Freezing
@onready var splash: AudioStreamPlayer = $Splash

var freezing_count = false

func _process(_delta: float) -> void:
	
	if GlobalPlayerStats.Heat_Goal < 1 or GlobalPlayerStats.PLAYER_CURRENT_STATE == "Swimming":
		play_freezing()
	else:
		reset_freezing()
	
	#stoppers
	if !get_parent().is_on_floor():
		soft_slide_loop.playing = false

func play_footstep():
	footstep.pitch_scale = randf_range(0.90, 1.10)
	footstep.playing = true

func play_crumple():
	crumple.playing = true

func play_jump():
	if get_parent().is_on_floor():
		play_footstep()
		low_woosh.pitch_scale = 1.0
	elif get_parent().is_on_wall_only():
		low_woosh.pitch_scale = 0.95 + (get_parent().wall_jump_count / 20.0)
	else:
		low_woosh.pitch_scale = 1.05
	low_woosh.playing = true

func play_high_jump():
	play_footstep()
	low_woosh.pitch_scale = 0.8
	low_woosh.playing = true
	reverb_woosh.pitch_scale = 1.0
	reverb_woosh.playing = true

func play_long_jump():
	if get_parent().is_on_floor():
		play_footstep()
		low_woosh.pitch_scale = 0.9
		reverb_woosh.pitch_scale = 1.1
	else:
		low_woosh.pitch_scale = 1
		reverb_woosh.pitch_scale = 1.2
	low_woosh.playing = true
	reverb_woosh.playing = true

func play_torch_swing():
	if get_parent().combo_counter < 2:
		fire_swing.pitch_scale = randf_range(0.90, 1.10)
	if get_parent().combo_counter < 3:
		fire_swing.pitch_scale += (get_parent().combo_counter / 10.0)
	else:
		fire_swing.pitch_scale = 0.8
	fire_swing.playing = true

func play_slide():
	soft_slide.playing = true
	if !soft_slide_loop.playing:
		soft_slide_loop.playing = true
func stop_slide():
	soft_slide.playing = false
	soft_slide_loop.playing = false

func play_torch_loop():
	torch_loop.volume_db = -9.0 + ((GlobalPlayerStats.Light_Goal) / 10.0)
	if !torch_loop.playing:
		torch_loop.playing = true
func stop_torch_loop():
	torch_loop.playing = false

func play_boost_loop():
	if Input.is_action_just_pressed("dash"):
		play_boost_fire()
	if !special_fire_loop.playing:
		special_fire_loop.playing = true
func stop_boost_loop():
	special_fire_loop.playing = false

func play_heartbeat():
	heartbeat.pitch_scale = 1.0 + ((GlobalPlayerStats.Heat - 300) / 600)
	heartbeat.playing = true

func play_boost_fire():
	fire_fwomf.playing = true

func play_boom():
	boom.playing = true

func play_flap():
	flap.playing = true

func play_snuff_fire():
	snuff_fire.playing = true

func play_freezing():
	if freezing_count:
		return
	else:
		freezing.playing = true
		freezing_count = true
func reset_freezing():
	freezing_count = false

func play_splash():
	splash.playing = true
