class_name stateAttacking extends State

var attacking : bool = false
@onready var attackAnimationPlayer : AnimationPlayer = $"../../Sprite2D/AttackEffectSprite/AnimationPlayer"
@onready var audio : AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"
@export var attack_sound : AudioStream 
@export_range(1,20,0.5) var decelerate_speed : float = 5.0
@onready var animationPlayer : AnimationPlayer = $"../../AnimationPlayer"
@onready var walk : State = $"../walk"
@onready var idle : State = $"../idle"
@onready var charge_attack: State = $"../ChargeAttack"
@onready var hurt_box : HurtBox = %AttackHurtBox


## What happen when the player enter this state ?
func Enter() -> void:
	player.UpdateAnimation("attack")
	attackAnimationPlayer.play("attack_" + player.AnimDirection())
	animationPlayer.animation_finished.connect(EndAttack)
	audio.stream = attack_sound 
	audio.pitch_scale = randf_range(0.9 , 1.1)
	audio.play()
	attacking = true
	
	await get_tree().create_timer(0.075).timeout
	if attacking:
		hurt_box.monitoring = true
	pass

## What happen when the player exit this state ?
func Exit() -> void:
	animationPlayer.animation_finished.disconnect(EndAttack)
	attacking = false
	hurt_box.monitoring = false
	pass

## What happen when the _process update in this state ?
func Process(_delta : float) -> State:
	player.velocity -= player.velocity * decelerate_speed * _delta 
	
	if attacking == false:
		if player.direction == Vector2.ZERO:
			return idle
		else: 
			return walk
	return null

func Physics(_delta : float) -> State:
	return null

func HandleInput(_event : InputEvent) -> State:
	return null

func EndAttack(_newAnimationName : String) -> void:
	if Input.is_action_pressed("attack"):
		state_machine.changeState(charge_attack)
	attacking = false
	pass
