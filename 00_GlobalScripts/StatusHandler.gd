class_name StatusHandler extends Node

# Determine who owns this handler (The Enemy/Player)
@onready var parent_body = get_parent()
@onready var sprite = parent_body.get_node_or_null("Sprite2D")

# --- BURN VARS ---
var burn_duration: float = 0.0
var burn_tick_timer: float = 0.0
var burn_damage: int = 1

# --- FREEZE VARS ---
var freeze_duration: float = 0.0
var original_speed: float = 0.0
var is_frozen: bool = false

func _process(delta: float) -> void:
	handle_burn(delta)
	handle_freeze(delta)

# --- 1. BURN LOGIC (Damage Over Time) ---
func apply_burn(duration: float, dmg_per_tick: int) -> void:
	burn_duration = duration
	burn_damage = dmg_per_tick
	# Visual: Turn Red
	if sprite: sprite.modulate = Color(3, 0.5, 0.5) # Glow Red (using Raw values > 1)

func handle_burn(delta: float) -> void:
	if burn_duration > 0:
		burn_duration -= delta
		burn_tick_timer -= delta
		
		if burn_tick_timer <= 0:
			burn_tick_timer = 0.5 
			
			# ONLY DO LOGIC HERE
			if "hp" in parent_body:
				# Apply damage
				parent_body.hp -= burn_damage
				EffectManager.damageText(burn_damage, parent_body.global_position)
				
				# Only check for death AFTER burning
				if parent_body.hp <= 0:
					# Check if they handle destruction signal
					if parent_body.has_signal("enemyDestroyed"):
						parent_body.enemyDestroyed.emit(null) 
					else:
						parent_body.queue_free()

		# Reset Color when done
		if burn_duration <= 0 and sprite:
			sprite.modulate = Color.WHITE

# --- 2. FREEZE LOGIC (Slow Down) ---
func apply_freeze(duration: float, slow_factor: float) -> void:
	# If not already frozen, save the original speed
	if not is_frozen:
		if "move_speed" in parent_body: # Assuming Enemy.gd has move_speed or chase_speed
			original_speed = parent_body.chase_speed # Adjust variable name based on your script
			parent_body.chase_speed = original_speed * slow_factor
			is_frozen = true
	
	freeze_duration = duration
	if sprite: sprite.modulate = Color(0.5, 0.5, 3) # Blue

func handle_freeze(delta: float) -> void:
	if freeze_duration > 0:
		freeze_duration -= delta
		
		if freeze_duration <= 0:
			# Thaw out
			if is_frozen:
				if "chase_speed" in parent_body:
					parent_body.chase_speed = original_speed
				is_frozen = false
				if sprite: sprite.modulate = Color.WHITE
