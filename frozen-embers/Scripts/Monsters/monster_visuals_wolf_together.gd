extends Node3D

@onready var animation: AnimationPlayer = $Monster_Wolf_05/AnimationPlayer

@onready var desperation_save_buffer: Timer = $"../Timers/DesperationSaveBuffer"

@onready var red_flash: GPUParticles3D = $RedFlash

#0-SPAWN, 1-WANDER, 2-HUH, 3-STARE, 4-CURIOUS, 5-PURSUIT, 6-CHASE, 7-ENDGAME, 8-DESPERATION, 9-STUNNED, 10-HURT
var current_state : int = 0

var windup : bool = false
var loop_stun_anim : bool = false

func _process(_delta: float) -> void:
	current_state = get_parent().current_state
	handle_state_transitions()

func trigger_save_active():
	GlobalLevelStats.DESPERATION_SAVE_ACTIVE = true

func trigger_loop_stun_anim():
	loop_stun_anim = true

func windup_complete():
	windup = true

func handle_state_transitions():
	match current_state:
		
		#SPAWN
		0: 
			animation.play("KO",0.0)
		
		#WANDER
		1:
			animation.play("Walk",0.1)
		
		#HUH
		2:
			animation.play("Huh?",0.1)
		
		#STARE
		3:
			animation.play("Huh?",0.1)
		
		#CURIOUS
		4:
			
			animation.play("Run",0.1)
		
		#PURSUIT
		5:
			animation.play("Run",0.0)
		
		#CHASE
		6:
			animation.play("Run",0.0)
		
		#ENDGAME
		7:
			animation.play("Run",0.0)
		
		#HURT
		10:
			animation.play("Hurt",0.1)
		
		#DESPERATION
		8:
			if GlobalLevelStats.DESPERATION_VICTORY:
				animation.play("Desperation Pass",0.0)
			
			elif !windup:
				print("INCOMING")
				animation.play("Desperation Windup",0.1)
				
			elif GlobalLevelStats.DESPERATION_SAVE_ACTIVE:
				print("NOW")
				if !red_flash.emitting:
					red_flash.emitting = true
				
				if windup and desperation_save_buffer.is_stopped():
					animation.play("Desperation Hold",0.0)
					desperation_save_buffer.start()
		
		#STUNNED
		9:
			if loop_stun_anim:
				animation.play("KO",0.0)
				
			else:
				print("YEAH")
				desperation_save_buffer.stop()
				windup = false
				GlobalLevelStats.DESPERATION_SAVE_ACTIVE = false
				loop_stun_anim = false
				animation.play("Desperation Pass",0.0)


func _on_desperation_save_buffer_timeout() -> void:
	if !GlobalLevelStats.DESPERATION_VICTORY:
		animation.play("Desperation Fail",0.0)


func ggs():
	GlobalLevelStats.game_over()
