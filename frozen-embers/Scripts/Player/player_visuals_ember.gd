extends Node3D

@onready var animation: AnimationPlayer = $Model/AnimationPlayer

#Particles
@onready var boost_start_particles: GPUParticles3D = $Particles/BoostStartParticles
@onready var boost_active_particles: GPUParticles3D = $Particles/BoostActiveParticles

#0-GROUNDED,1-AIRBORNE,2-CROUCHED,3-SLIDING,4-HIGH_JUMP,5-LONG_JUMP,6-WALL_CLING,7-AIR_DIVE,8-ATTACK,9-AIR_ATTACK, 
#10-LEDGE_GRAB,11-REIGNITE,12-EXTINGUISH,13-SWIMMING,14-FREEZE_DEATH
var current_state : int = 0

var dash_toggle : bool = false

var loop = false
var hold_on = false

func _process(_delta: float) -> void:
	handle_particles()
	current_state = get_parent().current_state
	dash_toggle = get_parent().dash_toggle
	handle_state_transitions()


func start_loop():
	loop = true

func reset_loop():
	loop = false

func reset_hold():
	hold_on = false

func handle_state_transitions():
	match current_state:
		
		#GROUNDED
		0:
			if get_parent().is_moving and get_parent().current_boost > 50:
				animation.play("Run",0.0)
			elif get_parent().is_moving and get_parent().current_boost < 50:
				animation.play("Walk",0.0)
			else:
				animation.play("Idle Stand")
			reset_loop()
		
		#AIRBORNE
		1:
			if hold_on:
				animation.play("Jump Cancel",0.1)
			else:
				animation.play("Airborne",0.15)
				reset_loop()
		
		#CROUCHED
		2:
			if get_parent().is_moving:
				animation.play("Sneak",0.0)
			else:
				animation.play("Idle Crouch")
			reset_loop()
		
		#SLIDING
		3:
			animation.play("Slide",0.2)
			boost_active_particles.emitting = true
		
		#HIGH_JUMP
		4:
			animation.play("High Jump",0.2)
			boost_active_particles.emitting = true
		
		#LONG_JUMP
		5:
			if loop:
				animation.play("Long Jump Loop",0.0)
			else:
				animation.play("Long Jump Start",0.2)
			boost_active_particles.emitting = true
		
		#WALL_CLING
		6:
			animation.play("Wall Slide")
		
		#AIR_DIVE
		7:
			hold_on = true
			
			if get_parent().air_dive_hesitate:
				animation.play("Air Dive Start",0.0)
			elif !get_parent().air_dive_hesitate and !get_parent().is_on_floor():
				animation.play("Air Dive Loop",0.0)
			else:
				animation.play("Air Dive Landing",0.0)
			
			boost_active_particles.emitting = true
		
		#ATTACK
		8:
			if get_parent().combo_counter == 1:
				animation.play("Attack Combo 1",0.1)
			if get_parent().combo_counter == 2:
				animation.play("Attack Combo 2",0.0)
			if get_parent().combo_counter == 3:
				animation.play("Attack Combo 3",0.0)
		
		#AIR_ATTACK
		9:
			animation.play("Attack Air",0.0)
		
		#LEDGE_GRAB
		10:
			animation.play("Ledge Grab")
		
		#REIGNITE
		11:
			animation.play("Reignite")
		
		#EXTINGUISH
		12:
			animation.play("Extinguish")
		
		#SWIMMING
		13:
			if get_parent().is_moving and get_parent().current_boost < 50:
				animation.play("Swim",0.1)
			else:
				animation.play("Idle Water")
			reset_loop()
		
		#FREEZE_DEATH
		14:
			animation.play("Death Freeze")
		
		#DESPRIATION
		15:
			if GlobalLevelStats.DESPERATION_VICTORY:
				animation.play("Desperation Win")
			else:
				animation.play("Desperation Idle")

func handle_particles():
	if Input.is_action_just_pressed("dash"):
		if GlobalPlayerStats.Heat > 0 or GlobalPlayerStats.Light_Goal > GlobalPlayerStats.Light_Min + 0.1:
			boost_start_particles.emitting = true
	
	if Input.is_action_pressed("dash") and (GlobalPlayerStats.Heat > 0 or GlobalPlayerStats.Light_Goal > GlobalPlayerStats.Light_Min + 0.1):
			boost_active_particles.emitting = true
	else:
			boost_active_particles.emitting = false

func handle_death():
	GlobalPlayerStats.Freeze = 0
	GlobalPlayerStats.Freeze_Goal = 0
	GlobalLevelStats.game_over()
