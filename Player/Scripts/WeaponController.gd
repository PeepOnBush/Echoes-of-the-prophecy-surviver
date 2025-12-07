extends Node2D

@export var arrow_scene: PackedScene
@export var fire_rate: float = 0.2 # 0.2 seconds between shots (5 shots per sec)

var current_cooldown: float = 0.0
func _process(delta):
	# 1. Aim at Mouse (Existing logic)
	look_at(get_global_mouse_position())
	
	# Flip logic (Existing logic)
	var angle_degrees = rotation_degrees
	if abs(angle_degrees) > 90:
		scale.y = -1 
	else:
		scale.y = 1

	# 2. Cooldown Management
	if current_cooldown > 0:
		current_cooldown -= delta

	# 3. SHOOTING LOGIC (Hold to Shoot)
	# We use 'Input' directly instead of 'event'
	if Input.is_action_pressed("click") and current_cooldown <= 0:
		shoot()
		current_cooldown = fire_rate # Reset timer



func shoot():
	if arrow_scene:
		var arrow = arrow_scene.instantiate()
		# Add arrow to the main world (root), not the player!
		get_tree().root.add_child(arrow)
		
		# Set Position and Rotation matching the Muzzle
		arrow.global_position = $Muzzle.global_position
		arrow.rotation = global_rotation
