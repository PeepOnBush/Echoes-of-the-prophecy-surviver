class_name EnemyStateChase extends EnemyState

@export var animName : String = "walk"
@export var chase_speed : float = 40.0
@export var turn_rate : float = 0.25

@export_category("AI")
@export var vision_area : VisionArea
@export var attack_area : HurtBox
@export var state_aggro_duration : float = 0.5
@export var nextState : EnemyState

var _timer : float = 0.0
var _direction : Vector2
var _canSeePlayer : bool = false

func init() -> void:
	if vision_area:
		vision_area.player_entered.connect(_on_player_enter)
		vision_area.player_exited.connect(_on_player_exit)
	pass

## What happen when the player enter this state ?
func Enter() -> void:
	_timer = state_aggro_duration
	enemy.UpdateAnimation(animName)
	if attack_area:
		attack_area.monitoring = true
	pass

func Exit() -> void:
	if attack_area:
		attack_area.monitoring = false
	_canSeePlayer = false
	pass 
## What happen when the _process update in this state ?
func Process(_delta : float) -> EnemyState:
	if PlayerManager.player.hp <= 0:
		return nextState
	var new_direction : Vector2 = enemy.global_position.direction_to(PlayerManager.player.global_position)
	_direction = lerp( _direction, new_direction, turn_rate)
	enemy.velocity = _direction * chase_speed
	if enemy.SetDirection(_direction):
		enemy.UpdateAnimation(animName)
	
	if _canSeePlayer == false:
		_timer -= _delta
		if _timer < 0:
			return nextState
	else: 
		_timer = state_aggro_duration
	return null

func Physics(_delta : float) -> EnemyState:
	return null

func _on_player_enter() -> void:
	_canSeePlayer = true
	if (
			state_machine.currentState is EnemyStateStun
			or state_machine.currentState is EnemyStateDestroy
	):
		return
	state_machine.changeState(self)
	pass

func _on_player_exit() -> void:
	_canSeePlayer = false
	pass
