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
@export var sizzle : AudioStream # reeling sound
@export var ding : AudioStream # reeling sound
@export var undercook : AudioStream
@export var overcook : AudioStream 
@export var cooking : AudioStream
#-- on ready --
@onready var shaker_container: Control = $ShakeContainer
@onready var cauldron_visuals: Control = $Cauldron
@onready var color_rect: ColorRect = $ColorRect
@onready var progress_label: Label = $Label
@onready var progress_bar: TextureProgressBar = $Progress
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

@onready var border: NinePatchRect = $ShakeContainer/Border
@onready var heat_bar: TextureProgressBar = $ShakeContainer/HeatBar
@onready var zone_indicator: ColorRect = $ShakeContainer/ZoneIndicator

var current_heat : float = 0.0
var current_cook_progress : float = 0.0 # 0 to target_cook_time
var is_active : bool = false
var active_recipe : RecipeData
func _ready() -> void:
	color_rect.visible = false
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS # Run while game is paused
	setup_zone_visuals()

func setup_zone_visuals() -> void:
	# Use the PARENT container size, because that is the "Source of Truth"
	var container_width = shaker_container.custom_minimum_size.x
	#var container_height = shaker_container.custom_minimum_size.y
	
	# 1. Calculate Width (Zone Span)
	var width_ratio = (zone_max - zone_min) / 100.0
	zone_indicator.size.x = container_width * width_ratio
	
	# 2. Force Full Height
	zone_indicator.size.y = 24.0
	
	# 3. Position (Horizontal Offset)
	# e.g. If zone_min is 40%, we start at 40% of the container width
	zone_indicator.position.x = container_width * (zone_min / 100.0)
	zone_indicator.position.y = 8.0
	pass
func start_cooking(recipe : RecipeData) -> void: 
	color_rect.visible = true
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
	AudioManager.play_looping_sfx(cooking, "cauldron_boil")
	# Juice: Pop in
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)
	pass
func _process(delta: float) -> void:
	if not is_active: return
	
	# 1. HEAT LOGIC (It always rises!)
	current_heat += (heat_rise_speed * active_recipe.difficulty) * delta
	
	# 2. STIR LOGIC (Click to cool down)
	if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("interact"):
		current_heat -= stir_cooling
		shake_cauldron() # Juice!
		AudioManager.play_sfx(sizzle)
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
		AudioManager.play_sfx(overcook)
		return
	if current_heat == 0.0:
		end_game(false)
		AudioManager.play_sfx(undercook)
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
		AudioManager.play_sfx(ding)
		# Play Victory Sound
	else:
		print("Burnt!!")
		# Play Explosion Sound
	
	AudioManager.stop_looping_sfx("cauldron_boil")
	await get_tree().create_timer(1.0).timeout
	visible = false
	get_tree().paused = false
	color_rect.visible = false
	# Pass the result item in the signal too, just in case HUD wants to show it
	cooking_finished.emit(win) # You might want to update the signal definition if you want to pass data back

func shake_cauldron() -> void:
	var tween = create_tween()
	# Rotate slight left/right
	tween.tween_property(cauldron_visuals, "rotation_degrees", randf_range(-5, 5), 0.05)
	tween.tween_property(cauldron_visuals, "rotation_degrees", 0, 0.05)
