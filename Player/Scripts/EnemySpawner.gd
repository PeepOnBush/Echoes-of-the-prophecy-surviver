extends Area2D

# --- 1. CONFIGURATION ---
@export var spawn_radius: float = 400.0

# Drag your specific enemy scenes here in the Inspector
@export var slime_scene: PackedScene
@export var goblin_scene: PackedScene

# --- 2. THE DIRECTOR BRAIN ---
var time_elapsed: float = 0.0
var current_wave_index: int = -1
var active_enemy_pool: Array[PackedScene] = []

@onready var spawn_timer: Timer = $Timer

# --- 3. WAVE DEFINITIONS ---
# time: When does this wave start? (in seconds)
# rate: How often do they spawn? (0.5 = 2 per second)
# types: What enemies spawn?
#waves Dictionary
var waves : Array = [
	# 0 to 10 seconds: Just Slimes, slow spawn
	{ "time": 0, "rate": 2.0, "types": ["slime"] },
	
	# 10 to 30 seconds: Add Goblins, faster spawn
	{ "time": 10, "rate": 1.0, "types": ["slime", "slime", "goblin"] },
	
	# 30 to 60 seconds: Goblin Horde
	{ "time": 30, "rate": 0.5, "types": ["goblin"] },
	
	# 60+ seconds: CHAOS (Everything, super fast)
	{ "time": 60, "rate": 0.2, "types": ["slime", "goblin"] }
]

func _ready() -> void:
	# Make sure the timer loops
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_timer_timeout)
	
	# Force start the first wave
	check_wave_update()

func _process(delta: float) -> void:
	time_elapsed += delta
	check_wave_update()
	
	# Optional: Print time to console for debugging
	# print(int(time_elapsed))
	# Update the UI
	PlayerHud.update_timer(time_elapsed)
	pass
func check_wave_update() -> void:
	var next_index = current_wave_index + 1
	
	# If we haven't run out of waves yet...
	if next_index < waves.size():
		var next_wave_data = waves[next_index]
		
		# If the game time has passed the wave's start time
		if time_elapsed >= next_wave_data["time"]:
			start_wave(next_wave_data)
			current_wave_index = next_index
			print("WAVE STARTED: ", current_wave_index)

func start_wave(wave_data: Dictionary) -> void:
	# 1. Set the Spawn Rate
	spawn_timer.wait_time = wave_data["rate"]
	spawn_timer.start() # Restart timer to apply new speed immediately
	
	# 2. Build the Enemy Pool
	active_enemy_pool.clear()
	for type_name in wave_data["types"]:
		match type_name:
			"slime": active_enemy_pool.append(slime_scene)
			"goblin": active_enemy_pool.append(goblin_scene)

func _on_timer_timeout() -> void:
	if active_enemy_pool.size() == 0:
		return
		
	# 1. Pick random enemy from the CURRENT wave pool
	var random_enemy_scene = active_enemy_pool.pick_random()
	var enemy_instance = random_enemy_scene.instantiate()
	
	# 2. Math: Pick random angle (0 to 360)
	var random_angle = randf() * TAU 
	
	# 3. Create vector: Go 'spawn_radius' distance in that direction
	var spawn_vector = Vector2(spawn_radius, 0).rotated(random_angle)
	
	# 4. Add to Level
	get_tree().current_scene.add_child(enemy_instance)
	enemy_instance.global_position = global_position + spawn_vector
