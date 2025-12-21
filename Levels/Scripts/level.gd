class_name Level extends Node2D

@export var music : AudioStream

# --- GENERATION SETTINGS ---
@export_category("Procedural Generation")
@export var generate_props : bool = false
@export var map_limits : Rect2 = Rect2(-1000, -1000, 2000, 2000)
@export var grid_step : int = 50 # Smaller step for more density control
@export var safe_zone_radius : float = 300.0

# --- THE BIOME PALETTE ---
@export_group("Biomes")
@export var trees : Array[PackedScene]      # High "Moisture"
@export var bushes : Array[PackedScene]     # Medium "Moisture"
@export var decorations : Array[PackedScene]# Low "Moisture" (Flowers, Pebbles)
@export var rare_props : Array[PackedScene] # Very low chance (Crates, Statues)
# --- NEW SETTINGS ---
@export var spawn_attempts : int = 3000 # How many times we try to place something
@export var min_distance_between_props : float = 24.0 # Prevents clutter

# Store positions to check distance manually (simple overlap prevention)
var spawned_positions : Array[Vector2] = []
var spawned_props_data : Array[Dictionary] = []


func _ready() -> void:
	self.y_sort_enabled = true
	PlayerManager.set_as_parent(self)
	LevelManager.level_load_started.connect( _free_level )
	AudioManager.playMusic(music)
	
	if generate_props:
		generate_map_advanced()

func generate_map_advanced() -> void:
	spawned_props_data.clear()
	
	# 1. Setup Noise
	var noise_type = FastNoiseLite.new()
	noise_type.seed = randi()
	noise_type.frequency = 0.015
	
	var noise_density = FastNoiseLite.new()
	noise_density.seed = randi() + 100
	noise_density.frequency = 0.05 

	var attempts = 0
	# Safety Loop
	while attempts < spawn_attempts:
		attempts += 1
		
		# A. Pick Spot
		var random_x = randf_range(map_limits.position.x, map_limits.end.x)
		var random_y = randf_range(map_limits.position.y, map_limits.end.y)
		var pos = Vector2(random_x, random_y)
		
		# B. Basic Safety
		if pos.distance_to(Vector2.ZERO) < safe_zone_radius:
			continue
		if is_position_blocked(pos):
			continue

		# --- SELECTION LOGIC START ---
		
		var scene_to_spawn : PackedScene = null
		var required_radius : float = 16.0 
		
		# 1. CHECK RARE PROPS FIRST (The Missing Link)
		# Give it a 1% chance (0.01) to spawn independently of noise
		if rare_props.size() > 0 and randf() < 0.01:
			scene_to_spawn = rare_props.pick_random()
			required_radius = 45.0 # Rare items (statues/crates) usually need space!
			
		else:
			# 2. If not rare, run Standard Biome Logic
			var type_val = noise_type.get_noise_2d(pos.x, pos.y)
			var density_val = noise_density.get_noise_2d(pos.x, pos.y)
			
			# Forest
			if type_val > 0.2: 
				if density_val > 0.1 and trees.size() > 0:
					scene_to_spawn = trees.pick_random()
					required_radius = 50.0 
			
			# Bushland
			elif type_val > -0.2:
				if density_val > -0.2 and bushes.size() > 0:
					scene_to_spawn = bushes.pick_random()
					required_radius = 24.0
			
			# Meadow
			else:
				if density_val > 0.0 and decorations.size() > 0:
					scene_to_spawn = decorations.pick_random()
					required_radius = 12.0 
		
		# --- SELECTION LOGIC END ---

		# If nothing was selected (low density noise), skip
		if scene_to_spawn == null:
			continue
			
		# D. Distance Check (Now includes Rare Props radius)
		if is_too_close_to_others(pos, required_radius):
			continue

		# E. Spawn it
		spawn_prop(scene_to_spawn, pos, required_radius)

# New Helper Function: Prevents objects from spawning inside each other
func is_too_close_to_others(new_pos: Vector2, my_radius: float) -> bool:
	# Iterate through ALL spawned items to ensure no overlap
	for prop in spawned_props_data:
		# Calculate minimum safe distance between the two objects
		var safe_distance = my_radius + prop.radius
		
		# Check distance squared (faster than distance)
		if new_pos.distance_squared_to(prop.pos) < safe_distance * safe_distance:
			return true
	return false
func spawn_prop(scene : PackedScene, pos : Vector2, radius: float) -> void:
	if scene == null: return
	var instance = scene.instantiate()
	instance.global_position = pos
	
	# Visual Variation (Scale/Color/Flip)
	var random_scale = randf_range(0.9, 1.1)
	instance.scale = Vector2(random_scale, random_scale)
	
	var color_var = randf_range(0.9, 1.0)
	var green_var = randf_range(0.9, 1.1)
	instance.modulate = Color(color_var, green_var, color_var, 1.0)
	
	if instance.has_node("Sprite2D"):
		if randf() > 0.5: instance.get_node("Sprite2D").flip_h = true
	
	# Save data for future collision checks
	spawned_props_data.append({ "pos": pos, "radius": radius })
	add_child(instance)

# This prevents spawning trees inside your TileMap walls or water
func is_position_blocked(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	# Adjust mask to match your Wall/Water collision layers
	query.collision_mask = 1 # Example: Layer 1 is Walls
	
	var result = space_state.intersect_point(query)
	return result.size() > 0

func _free_level() -> void:
	PlayerManager.unparent_player(self)
	queue_free()
