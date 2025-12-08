class_name EnemyStateCharge extends EnemyState

@export var alert_duration : float = 0.6  # How long it freezes/warns
@export var dash_duration : float = 0.5   # How long it dashes
@export var dash_speed : float = 400.0    # Speed of the dash
@export var next_state : EnemyState       # Drag the "Chase" node here

var timer : float = 0.0
var dash_direction : Vector2
var is_dashing : bool = false

func Enter() -> void:
	# Phase 1: ALERT
	is_dashing = false
	timer = alert_duration
	enemy.velocity = Vector2.ZERO
	
	# Visual Feedback: Turn RED
	enemy.modulate = Color(9.688, 1.838, 1.838, 1.0) # Bright Red
	enemy.UpdateAnimation("idle") # Or a "prepare" animation if you have one
	
	# Lock aim on player
	if PlayerManager.player:
		dash_direction = enemy.global_position.direction_to(PlayerManager.player.global_position)
	else:
		dash_direction = Vector2.DOWN

func Exit() -> void:
	# Reset Visuals
	enemy.modulate = Color(1, 1, 1, 1) # Reset color
	
	# Clean up physics
	enemy.velocity = Vector2.ZERO

func Process(_delta : float) -> EnemyState:
	timer -= _delta
	
	if is_dashing == false:
		# LOGIC: We are currently standing still and flashing red
		if timer <= 0:
			# Time to launch!
			is_dashing = true
			timer = dash_duration
			# Optional: Play a dash sound here
	else:
		# LOGIC: We are currently rocketing forward
		enemy.velocity = dash_direction * dash_speed
		enemy.move_and_slide()
		
		# While dashing, force the sprite to face the movement direction
		enemy.SetDirection(dash_direction)
		enemy.UpdateAnimation("walk") # Or a "dash" animation
		
		if timer <= 0:
			# Dash finished, go back to chasing
			return next_state
			
	return null
