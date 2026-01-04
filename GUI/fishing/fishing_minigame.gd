class_name FishingMinigame extends Control

signal fishing_finished(success : bool, fish : FishData)

# --- CONFIGURATION ---
@export var fish_pool : Array[FishData] # Drag your fish resources here!
@export var base_decay_rate : float = 15.0 # How fast bar falls by default
@export var click_power : float = 10.0 # How much it goes up per click
@export var reeling_audio : AudioStream # reeling sound
@export var finished_catching_audio : AudioStream # reeling sound
@export var fish_out_of_the_water_audio : AudioStream # reeling sound
@export var rope_snapped : AudioStream # reeling sound

@onready var shaker_container: Control = $shakerContainer
@onready var tension_bar: TextureProgressBar = $shakerContainer/TensionBar
@onready var fish_icon: TextureRect = $FishIcon

var current_fish : FishData
var current_progress : float = 0.0
var is_active : bool = false
var original_shaker_pos : Vector2
func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS # Runs while game paused
	await get_tree().process_frame
	original_shaker_pos = shaker_container.position 
func start_fishing() -> void:
	if fish_pool.size() == 0:
		print("No fish in the lake!")
		close_minigame()
		return

	# 1. Pick a fish
	current_fish = fish_pool.pick_random()
	fish_icon.texture = current_fish.icon
	
	# 2. Reset Bar
	current_progress = 40.0 # Give player a head start
	tension_bar.value = current_progress
	original_shaker_pos = shaker_container.position 

	# 3. Pause Game / Show UI
	get_tree().paused = true
	visible = true
	is_active = true
	
	# Optional: Play "Reel In" sound loop

func _process(delta: float) -> void:
	if not is_active: return
	
	# --- THE TUG OF WAR ---
	
	# 1. The Gravity (Fish pulling down)
	# Heavier fish pull down harder
	var decay = base_decay_rate * current_fish.weight_difficulty
	current_progress -= decay * delta
	
	# 2. The Strength (Player pulling up)
	# You can use "attack" or "interact" button
	if Input.is_action_just_pressed("attack"): 
		# Clicking adds progress
		current_progress += click_power
		juice_shake_bar()
		# Optional: Play "Click/Reel" sound
		AudioManager.play_sfx(reeling_audio)
	# 3. Update Visuals
	tension_bar.value = current_progress
	
	# 4. Check Win/Loss
	if current_progress >= 100.0:
		game_over(true)
	elif current_progress <= 0.0:
		game_over(false)

func game_over(win : bool) -> void:
	is_active = false
	
	if win:
		print("Caught: ", current_fish.name)
		AudioManager.play_sfx(finished_catching_audio)
		AudioManager.play_sfx(fish_out_of_the_water_audio)
		# Flash bar green or play victory sound
		# Give Fish (Item) to inventory logic here later
	else:
		print("Line snapped!")
		AudioManager.play_sfx(rope_snapped)
		# Flash bar red or play snap sound
	
	# Small delay before closing so player sees the result
	await get_tree().create_timer(1.0).timeout
	close_minigame()
	fishing_finished.emit(win, current_fish)

func close_minigame() -> void:
	visible = false
	get_tree().paused = false # Resume Game
	

# --- JUICE: THE STRENGTH SHAKE ---
func juice_shake_bar() -> void:
	var tween = create_tween()
	var shake_strength = 5.0 * current_fish.weight_difficulty
	
	# Shake relative to the ORIGINAL position
	var shake_offset = Vector2(
		randf_range(-shake_strength, shake_strength),randf_range(-2, 2)
	)
	
	# Tween OUT
	tween.tween_property(shaker_container, "position", 
		original_shaker_pos + shake_offset, 0.05
	)
	
	# Tween BACK (To Original, NOT Vector2.ZERO)
	tween.tween_property(shaker_container, "position", original_shaker_pos, 0.05
	)
