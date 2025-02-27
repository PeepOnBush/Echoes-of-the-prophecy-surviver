class_name EnemyStateWander extends EnemyState

@export var animName : String = "walk"
@export var wander_speed : float = 20.0

@export_category("AI")
@export var state_animation_duration : float = 0.5
@export var state_cycles_min : int = 1
@export var state_cycles_max : int = 3
@export var nextState : EnemyState

var _timer : float = 0.0
var _direction : Vector2


func init() -> void:
	pass

## What happen when the player enter this state ?
func Enter() -> void:
	_timer = randf_range(state_cycles_min,state_cycles_max) * state_animation_duration
	var rand = randf_range(0 , 3)
	_direction = enemy.DIR_4[rand]
	enemy.velocity = _direction * wander_speed
	enemy.SetDirection(_direction)
	enemy.UpdateAnimation( animName )
	pass
## What happen when the player exit this state ?
func Exit() -> void:
	
	pass 
## What happen when the _process update in this state ?
func Process(_delta : float) -> EnemyState:
	_timer -= _delta
	if _timer < 0 :
		return nextState
	return null
	
func Physics(_delta : float) -> EnemyState:
	return null

