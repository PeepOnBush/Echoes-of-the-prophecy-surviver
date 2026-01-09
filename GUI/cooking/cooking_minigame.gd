class_name CookingMinigame extends Control

signal cooking_finished(success: bool)

# --- BALANCING VARIABLES ---
@export var heat_rise_speed : float = 30.0 # Heat gains per second
@export var stir_cooling : float = 15.0 # Heat removed per click
@export var target_cook_time : float = 5.0 # Seconds inside the green zone to win

# --- ZONE SETTINGS ---
# Defined as 0.0 to 100.0
@export var zone_min : float = 40.0 
@export var zone_max : float = 60.0

@onready var heat_bar: TextureProgressBar = $shakerContainer/HeatBar
@onready var zone_indicator: ColorRect = $shakerContainer/HeatBar/ZoneIndicator
@onready var cauldron_visuals: Control = $Cauldron

@onready var progress_label: Label = $Label
@onready var progress_bar: TextureProgressBar = $Progress

var current_heat : float = 0.0
var current_cook_progress : float = 0.0 # 0 to target_cook_time
var is_active : bool = false
var active_recipe : RecipeData
func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS # Run while game is paused
	setup_zone_visuals()

func setup_zone_visuals() -> void:
	var full_width = heat_bar.size.x # Use Width (X) for horizontal bar
	
	var width_ratio = (zone_max - zone_min) / 100.0
	
	# Set Width
	zone_indicator.size.x = full_width * width_ratio
	
	# Set Position (Start from Left)
	zone_indicator.position.x = full_width * (zone_min / 100.0)
	
	# Ensure Y position centers it vertically on the bar
	zone_indicator.position.y = 0 
	zone_indicator.size.y = heat_bar.size.y

func start_cooking(recipe : RecipeData) -> void: 
	active_recipe = recipe # <--- Store it for later
	
	is_active = true
	visible = true
	get_tree().paused = true
	
	# Apply Difficulty
	# If difficulty is 2.0, heat rises twice as fast!
	# We use a temporary variable so we don't mess up the default export
	# (You might need to change your _process to use 'current_rise_speed' instead of export)
	# OR simpler: modify a multiplier variable.
	
	# Reset
	current_heat = 0.0
	current_cook_progress = 0.0
	heat_bar.value = 0
	progress_bar.value = 0
	
	# Juice: Pop in
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)

func _process(delta: float) -> void:
	if not is_active: return
	
	# 1. HEAT LOGIC (It always rises!)
	current_heat += (heat_rise_speed * active_recipe.difficulty) * delta
	
	# 2. STIR LOGIC (Click to cool down)
	if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("interact"):
		current_heat -= stir_cooling
		shake_cauldron() # Juice!
		# Play "Splash/Stir" Sound
	
	# Clamp heat
	current_heat = clamp(current_heat, 0.0, 100.0)
	heat_bar.value = current_heat
	
	# 3. CHECK ZONE
	if current_heat > zone_min and current_heat < zone_max:
		# We are cooking!
		current_cook_progress += delta
		cauldron_visuals.modulate = Color(1.2, 1.2, 1) # Slight glow
	else:
		# Optional: Food cools down if you leave the zone?
		# current_cook_progress -= delta * 0.5 
		cauldron_visuals.modulate = Color.WHITE
	
	# 4. OVERHEAT FAIL CONDITION
	if current_heat >= 100.0:
		end_game(false)
		return
		
	# 5. UI UPDATE
	# Convert time (0 to 5) into Percentage (0 to 100)
	progress_bar.value = (current_cook_progress / target_cook_time) * 100.0
	progress_label.text = str(int(progress_bar.value)) + "%"
	
	# 6. WIN CONDITION
	if current_cook_progress >= target_cook_time:
		end_game(true)

func end_game(win : bool) -> void:
	is_active = false
	if win:
		print("Dish Cooked: ", active_recipe.recipe_name)
		# --- GIVE REWARD ---
		if active_recipe.result_item:
			PlayerManager.INVENTORY_DATA.add_item(active_recipe.result_item)
		# -------------------
		# Play Victory Sound
	else:
		print("Burnt!!")
		# Play Explosion Sound
		
	await get_tree().create_timer(1.0).timeout
	visible = false
	get_tree().paused = false
	
	# Pass the result item in the signal too, just in case HUD wants to show it
	cooking_finished.emit(win) # You might want to update the signal definition if you want to pass data back

func shake_cauldron() -> void:
	var tween = create_tween()
	# Rotate slight left/right
	tween.tween_property(cauldron_visuals, "rotation_degrees", randf_range(-5, 5), 0.05)
	tween.tween_property(cauldron_visuals, "rotation_degrees", 0, 0.05)
