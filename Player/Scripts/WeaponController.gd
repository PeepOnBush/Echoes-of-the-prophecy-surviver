extends Node2D

@export var arrow_scene: PackedScene

func _process(delta):
	# 1. Make the Pivot look at the mouse
	look_at(get_global_mouse_position())
	
	# 2. Handle Sprite Flipping (so the bow isn't upside down when aiming left)
	var angle_degrees = rotation_degrees
	# Normalize angle to -180 to 180 range logic usually handles itself, but:
	if abs(angle_degrees) > 90:
		scale.y = -1 # Flip vertically to keep bow right-side up
	else:
		scale.y = 1

func _input(event):
	# 3. Shooting
	if event.is_action_pressed("click"): # Make sure "click" is mapped in Input Map (Project Settings)
		shoot()
	if event.is_action("click"):
		shoot()

func shoot():
	if arrow_scene:
		var arrow = arrow_scene.instantiate()
		# Add arrow to the main world (root), not the player!
		get_tree().root.add_child(arrow)
		
		# Set Position and Rotation matching the Muzzle
		arrow.global_position = $Muzzle.global_position
		arrow.rotation = global_rotation
