class_name EnemySpawner extends Area2D

# --- 1. CONFIGURATION ---
@export var spawn_radius: float = 400.0
@export var isEnabled : bool = false

# --- NEW: THE ENEMY ROSTER ---
# In the inspector, you will add items to this Dictionary.
# Key (String) = The name you use in the waves array (e.g., "slime")
# Value (PackedScene) = The actual scene file (e.g., Slime.tscn)
@export var enemy_roster: Dictionary 

@export var boss_list: Array[PackedScene] 

# --- 2. THE DIRECTOR BRAIN ---
var time_elapsed: float = 0.0
var current_wave_index: int = -1
var active_enemy_pool: Array[PackedScene] = []

@onready var spawn_timer: Timer = $Timer

# --- 3. WAVE DEFINITIONS ---
var waves : Array = [
	# 0 to 10 seconds: Just Slimes, slow spawn
	{ "time": 0, "rate": 2.0, "types": ["slime"] },
	
	# 10 to 30 seconds: Add Goblins, faster spawn
	{ "time": 5, "rate": 1.0, "types": ["slime", "slime", "goblin"] },
	
	# 30 to 60 seconds: Goblin Horde
	{ "time": 10, "rate": 0.5, "types": ["goblin"] },
	
	# THE BOSS WAVE
	{ 
		"time": 15, 
		"rate": 0.5, 
		"types": ["boss"], # Special tag
		"is_boss_wave": true
	}
]
func _ready() -> void:
	# 1. AUTO-START: Always enable spawning when the level loads fresh
	#isEnabled = true
	# 2. RESET TIMER
	time_elapsed = 0.0
	current_wave_index = -1
	# 3. RESET HUD: Snap the UI back to 00:00 immediately
	PlayerHud.update_timer(0.0) 
	# 4. DIFFICULTY SCALING
	# Example: Run 1 = 100% speed. Run 2 = 110% speed.
	var difficulty_mult = 1.0 + ((LevelManager.current_run_difficulty - 1) * 0.1)
	apply_difficulty_to_waves(difficulty_mult)
	
	# 3. Setup Timer
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_timer_timeout)
	spawn_timer.start()
	check_wave_update()

func _process(delta: float) -> void:
	# FIX: Only tick time if the spawner is active!
	# This ensures that when you kill the boss (isEnabled=false), the clock STOPS.
	if isEnabled:
		time_elapsed += delta
		check_wave_update()
		PlayerHud.update_timer(time_elapsed)
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
	if isEnabled:
		# 1. Set the Spawn Rate
		spawn_timer.wait_time = wave_data["rate"]
		spawn_timer.start()
		
		# 2. Build the Enemy Pool dynamically from the Roster
		active_enemy_pool.clear()
		
		for type_name in wave_data["types"]:
			if type_name == "boss":
				continue # Bosses are handled below
				
			# Look up the string in our exported dictionary
			if enemy_roster.has(type_name):
				var scene_to_spawn = enemy_roster[type_name]
				if scene_to_spawn: # Ensure a scene was actually dropped in the inspector
					active_enemy_pool.append(scene_to_spawn)
			else:
				printerr("Spawner Warning: '", type_name, "' is not in the Enemy Roster!")
		
		# 3. Check for Boss
		if wave_data.has("is_boss_wave"):
			spawn_boss()

func spawn_boss() -> void:
	# Calculate which boss to spawn based on Run Count
	# Run 1 = Index 0. Run 2 = Index 1.
	var boss_index = (LevelManager.current_run_difficulty - 1)
	
	# Safety Check: If we run out of bosses (e.g., Round 5 but only 3 bosses),
	# Loop back to the first one, or pick the last one.
	if boss_index >= boss_list.size():
		boss_index = boss_index % boss_list.size() # Loops (0, 1, 2, 0, 1, 2)
		# OR use: boss_index = boss_list.size() - 1 # Keeps fighting the last/hardest boss
	
	var boss_to_spawn = boss_list[boss_index]
	
	# --- Standard Spawn Logic ---
	var center_pos = Vector2.ZERO
	if PlayerManager.player:
		center_pos = PlayerManager.player.global_position
		
	var spawn_pos = center_pos + Vector2(600, 0) 
	
	var boss_instance = boss_to_spawn.instantiate()
	get_tree().current_scene.add_child(boss_instance)
	boss_instance.global_position = spawn_pos
	
	boss_instance.tree_exited.connect(on_boss_defeated)

	pass
func _on_timer_timeout() -> void:
	if isEnabled == false or active_enemy_pool.size() == 0:
		return
		
	var random_enemy_scene = active_enemy_pool.pick_random()
	if random_enemy_scene == null: return

	var enemy_instance = random_enemy_scene.instantiate()
	#Increase health
	#var hp_mult = 1.0 + ((LevelManager.current_run_difficulty - 1) * 0.1)
	#enemy_instance.max_hp = int(enemy_instance.max_hp * hp_mult)
	#enemy_instance.hp = enemy_instance.max_hp
	# --- POSITIONING FIX ---
	var random_angle = randf() * TAU 
	var spawn_vector = Vector2(spawn_radius, 0).rotated(random_angle)
	
	# OLD CODE:
	# enemy_instance.global_position = global_position + spawn_vector
	
	# NEW CODE: Find the player explicitly!
	if PlayerManager.player:
		enemy_instance.global_position = PlayerManager.player.global_position + spawn_vector
	else:
		# Fallback if player is dead/missing
		enemy_instance.global_position = global_position + spawn_vector
	
	get_tree().current_scene.add_child(enemy_instance)

func on_boss_defeated() -> void:
	# Stop the spawner
	onRoundFinish(false)
	
	# Optional: You can also trigger the Victory Screen here if you haven't yet
	# PlayerHud.show_victory()


func onRoundFinish(should_spawn: bool = false) -> void:
	isEnabled = should_spawn
	
	if isEnabled == false:
		spawn_timer.stop() # Make sure the timer actually stops ticking!
	pass

# --- NEW HELPER FOR DIFFICULTY ---
func apply_difficulty_to_waves(multiplier: float) -> void:
	# We iterate through the dictionary and speed up spawn rates
	# Note: We duplicate so we don't permanently change the defaults in the Resource
	var scaled_waves = waves.duplicate(true)
	for w in scaled_waves:
		if w.has("rate"):
			w["rate"] = w["rate"] / multiplier # Higher multiplier = Lower wait time
	waves = scaled_waves
