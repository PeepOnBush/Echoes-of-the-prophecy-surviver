class_name StateChargeAttack extends State
 
@export var charge_duration : float = 1.0
@export var move_speed : float = 80.0
@export var sfx_charged : AudioStream
@export var sfx_spin : AudioStream


@onready var idle: stateIdle = $"../idle"

var timer : float = 0.0
var walking : bool = false
var is_attacking : bool = false 
var particles : ParticleProcessMaterial



func _ready() -> void:
	pass # Replace with function body.

func init() -> void:
	pass

## What happen when the player enter this state ?
func Enter() -> void:
	timer = charge_duration
	is_attacking = false
	walking = false
	pass
## What happen when the player exit this state ?
func Exit() -> void:
	
	pass 
## What happen when the _process update in this state ?
func Process(_delta : float) -> State:
	#handle timer, when timer's done, let the player know the charge complete
	if timer > 0:
		timer -= _delta
		if timer <= 0:
			timer = 0  
	
	
	if is_attacking == false:
		if player.direction == Vector2.ZERO:
			walking = false
			player.UpdateAnimation("charge")
		elif player.SetDirection() or walking == false:
			walking = true
			player.UpdateAnimation("charge_walk")
			pass
	player.velocity = player.direction * move_speed
	
	return null
	
func Physics(_delta : float) -> State:
	return null

func HandleInput( _event : InputEvent ) -> State:
	if _event.is_action_released("attack"):
		if timer > 0:
			return idle
		elif is_attacking == false:
			chargeAttack()
	return null

func chargeAttack() -> void:
	is_attacking = true
	player.animationPlayer.play("charge_attack")
	player.animationPlayer.seek(getSpinFrame())
	var _duration : float = player.animationPlayer.current_animation_length
	player.make_invulnerable( _duration )
	await get_tree().create_timer(_duration * 0.875).timeout
	
	state_machine.changeState(idle)
	pass

func getSpinFrame() -> float:
	var interval : float = 0.05
	match player.cardinal_direction:
		Vector2.DOWN:
			return interval * 0
		Vector2.UP:
			return interval * 4
		_:
			return interval * 6
