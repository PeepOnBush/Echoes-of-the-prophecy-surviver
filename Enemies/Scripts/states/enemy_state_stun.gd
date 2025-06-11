class_name EnemyStateStun extends EnemyState

@export var animName : String = "stun"
@export var knockback_speed : float = 350.0
@export var decelerate_speed : float = 10.0

@export_category("AI")
@export var nextState : EnemyState

var _damage_position : Vector2
var _direction : Vector2
var animationFinished : bool = false


func init() -> void:
	enemy.enemyDamaged.connect(_on_enemy_damaged)
	pass

## What happen when the player enter this state ?
func Enter() -> void:
	enemy.invulnerable = true
	animationFinished = false
	_direction = enemy.global_position.direction_to(_damage_position)
	
	enemy.SetDirection(_direction)
	enemy.velocity = _direction * -knockback_speed
	enemy.UpdateAnimation( animName )
	enemy.animationPlayer.animation_finished.connect(_on_animation_finished)
	pass
## What happen when the player exit this state ?
func Exit() -> void:
	enemy.invulnerable = false
	enemy.animationPlayer.animation_finished.disconnect(_on_animation_finished)
	pass 
## What happen when the _process update in this state ?
func Process(_delta : float) -> EnemyState:
	if animationFinished == true :
		return nextState
	enemy.velocity -=enemy.velocity * decelerate_speed * _delta
	return null
	
func Physics(_delta : float) -> EnemyState:
	return null

func _on_enemy_damaged(hurt_box : HurtBox) -> void:
	_damage_position = hurt_box.global_position
	state_machine.changeState(self)
	
func _on_animation_finished( _a : String ) -> void:
	animationFinished = true
