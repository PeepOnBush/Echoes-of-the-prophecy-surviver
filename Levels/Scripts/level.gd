class_name Level extends Node2D

@export var music : AudioStream

# --- PROCEDURAL GENERATION SETTINGS ---
@export_category("Procedural Generation")
@export var generate_props : bool = false
@export var prop_scenes : Array[PackedScene] # Drag your trees, rocks, bushes here
@export var map_limits : Rect2 = Rect2(-1000, -1000, 2000, 2000) # The size of your arena
@export var grid_step : int = 100 # How far apart to check (prevents massive overlapping)
@export_range(0.0, 1.0) var density : float = 1 # Higher = dense forest, Lower = open field
@export var safe_zone_radius : float = 250.0 # Clear area in the center for player spawn

func _ready() -> void:
	self.y_sort_enabled = true
	PlayerManager.set_as_parent(self)
	LevelManager.level_load_started.connect( _free_level )
	AudioManager.playMusic(music)
	
	# THE GENERATOR
	if generate_props:
		generate_map_props()

func generate_map_props() -> void:
	if prop_scenes.size() == 0:
		return

	# 1. Setup Noise (This makes it look organic, not random)
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.02 # Lower = larger clumps of trees. Higher = scattered noise.
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM

	# 2. Iterate through the map in a grid
	# We use a grid loop so we don't spawn 1000 trees on top of each other
	var x_start = int(map_limits.position.x)
	var y_start = int(map_limits.position.y)
	var x_end = int(map_limits.end.x)
	var y_end = int(map_limits.end.y)

	for x in range(x_start, x_end, grid_step):
		for y in range(y_start, y_end, grid_step):
			
			var pos = Vector2(x, y)
			
			# 3. Check Safe Zone (Don't spawn on top of player)
			if pos.distance_to(Vector2.ZERO) < safe_zone_radius:
				continue
			
			# 4. Get Noise Value (-1 to 1)
			# We normalize it roughly to 0-1 for easier logic
			var noise_val = noise.get_noise_2d(x, y)
			
			# 5. Spawn Check
			# If noise is higher than our density threshold, spawn something
			if noise_val < (density - 0.5): # Adjusting math to fit -1 to 1 range
				spawn_single_prop(pos)

func spawn_single_prop(pos : Vector2) -> void:
	# Add a little random offset so they aren't perfectly aligned to the grid
	var offset = Vector2(randf_range(-16, 16), randf_range(-16, 16))
	var final_pos = pos + offset
	
	# Pick a random prop
	var scene = prop_scenes.pick_random()
	var instance = scene.instantiate()
	
	# Set position
	instance.global_position = final_pos
	
	# Optional: Add variety (Scale and Flip)
	# Flip H randomly
	if randf() > 0.5:
		if instance.has_node("Sprite2D"): # Assuming your props have a Sprite2D
			instance.get_node("Sprite2D").flip_h = true
	
	# Add to scene
	add_child(instance)

func _free_level() -> void:
	PlayerManager.unparent_player(self)
	queue_free()
