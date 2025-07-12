class_name stateStun extends State


@export var knockback_speed : float = 200.0
@export var decelerate_speed : float = 10.0
@export var invulnerable_duration : float = 1.0

var hurt_box : HurtBox 
var direction : Vector2
var nextState : State = null


@onready var idle: State = $"../idle"
@onready var death: StateDeath = $"../Death"


func init() -> void:
	player.PlayerDamaged.connect(_player_damaged)
func Enter() -> void:

	player.animationPlayer.animation_finished.connect(_animation_finished)
	direction = player.global_position.direction_to(hurt_box.global_position)
	player.velocity = direction * -knockback_speed
	player.UpdateAnimation("stun")
	player.SetDirection()
	
	player.make_invulnerable(invulnerable_duration)
	player.effect_animation_player.play("damaged")
	PlayerManager.shakeCamera(hurt_box.damage)
	#PlayerManager.apply_hitstop(0.3)
	pass
## What happen when the player exit this state ?
func Exit() -> void:
	nextState = null
	player.animationPlayer.animation_finished.disconnect(_animation_finished)
	pass
## What happen when the _process update in this state ?
func Process(_delta: float) -> State:
	player.velocity -= player.velocity * decelerate_speed * _delta
	return nextState
	
func Physics(_delta : float) -> State:
	
	return null

func HandleInput( _event: InputEvent) -> State:
	return null

func _player_damaged(_hurt_box : HurtBox) -> void:
	hurt_box = _hurt_box
	if state_machine.currentState != death:
		state_machine.changeState(self)
	pass
	
func _animation_finished (_a : String) -> void:
	nextState = idle
	if player.hp <= 0:
		nextState = death
