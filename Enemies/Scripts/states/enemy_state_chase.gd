class_name EnemyStateChase extends EnemyState

@export var animName : String = "walk"
@export var chase_speed : float = 40.0
@export var turn_rate : float = 0.25
var _direction : Vector2


func Enter() -> void:
	enemy.UpdateAnimation(animName)
	pass

func Exit() -> void:
	pass 

func Process(_delta : float) -> EnemyState:
	# 1. Check if player exists
	var player = PlayerManager.player
	if !player or player.hp <= 0:
		return null # Stop chasing if player is dead
	
	# 2. Calculate direction to player (Global Aggro)
	var new_direction : Vector2 = enemy.global_position.direction_to(player.global_position)
	
	# 3. Smooth turning (Optional, makes them less twitchy)
	_direction = lerp(_direction, new_direction, turn_rate)
	
	# 4. Apply Movement
	enemy.velocity = _direction * chase_speed
	
	# 5. Update Sprite Direction and Animation
	if enemy.SetDirection(_direction):
		enemy.UpdateAnimation(animName)
	
	# We NEVER return a nextState. We chase forever.
	return null

func Physics(_delta : float) -> EnemyState:
	return null
