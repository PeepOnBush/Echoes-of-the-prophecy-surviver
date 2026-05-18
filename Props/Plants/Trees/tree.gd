extends Sprite2D

func _ready() -> void:
	# 1. Make this tree's material unique so they don't all share the same settings
	material = material.duplicate()
	
	# 2. Give this specific tree a random offset in the wind cycle (0 to 100)
	var random_wind_offset = randf() * 100.0
	material.set_shader_parameter("offset", random_wind_offset)
	
	# Optional: Slightly randomize the speed per tree so it looks very organic
	var random_speed = randf_range(1.2, 1.8)
	material.set_shader_parameter("speed", random_speed)
