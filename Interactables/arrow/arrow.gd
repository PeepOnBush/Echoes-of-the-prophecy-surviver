class_name Arrow extends Node2D



const EXPLOSION_SCENE = preload("res://GUI/Upgrades/skill_scene/Explosion.tscn")

@export var move_speed : float = 300
@export var fire_audio : AudioStream

var move_dir : Vector2 = Vector2.RIGHT

# --- RICOCHET VARIABLES ---
var max_bounces : int = 0
var current_bounces : int = 0
var hit_history : Array[Node] = [] # Stores Enemies we've already hit

@onready var hurt_box: HurtBox = $HurtBox
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sprite_2d_2: Sprite2D = $Sprite2D2
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
 
func _ready() -> void:
	hurt_box.did_damage.connect(onDidDamage)
	get_tree().create_timer(5.0).timeout.connect(onTimeOut)
	if fire_audio:
		audio_stream_player_2d.stream = fire_audio
		audio_stream_player_2d.play()
	
	# Rotate initially
	updateDamageValue()
	rotateNode()

func _process(delta: float) -> void:
	# This logic follows rotation perfectly, allowing us to just change 'rotation' to steer
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * move_speed * delta

func shoot(fire_dir : Vector2 ) -> void:
	move_dir = fire_dir
	rotateNode()

func rotateNode() -> void:
	var angle : float = move_dir.angle()
	rotation = angle 
	# Note: Since Arrow is the parent Node2D, changing 'rotation' rotates all children.
	# We don't strictly need to rotate sprite_2d/hurt_box individually unless they are unlinked.
func updateDamageValue() -> void:
	if PlayerManager.player.berserker_mode:
		var missing_hp = PlayerManager.player.max_hp - PlayerManager.player.hp
		hurt_box.damage += int(missing_hp * 0.5) # +1 dmg per 2 missing HP
	pass
# --- MODIFIED HIT LOGIC ---
func onDidDamage(victim_hitbox: HitBox) -> void:
	# SAFETY CHECK: If the thing we hit isn't a HitBox (rare but possible), stop.
	if victim_hitbox == null:
		queue_free()
		return

	# 1. Identify who we hit
	var victim_enemy = victim_hitbox.owner 
	
	# 2. Add to history
	if victim_enemy:
		hit_history.append(victim_enemy)
		var status = victim_enemy.get_node_or_null("StatusHandler") 

		if status:
			# Check Fire
			if PlayerManager.player.chance_to_burn > 0 and randf() < PlayerManager.player.chance_to_burn:
				status.apply_burn(3.0, 2)
			
			# Check Ice
			if PlayerManager.player.chance_to_freeze > 0 and randf() < PlayerManager.player.chance_to_freeze:
				status.apply_freeze(5.0, 0.5)
		if PlayerManager.player.explosive_arrows_unlocked:
			print("Spawning Explosion!") # DEBUG PRINT
			spawn_explosion()
		else:
			print("Explosion locked.")
	# 3. Check Bounce Count
	if current_bounces < max_bounces:
		var next_target = find_nearest_enemy(global_position)
		
		if next_target:
			# SUCCESS: Found a new target!
			current_bounces += 1
			
			# 4. Turn towards new target
			var direction_to_target = (next_target.global_position - global_position).normalized()
			
			# FORCE ROTATION UPDATE IMMEDIATELY
			rotation = direction_to_target.angle()
			
			return # KEEP FLYING!

	# 4. No bounces left OR no targets nearby -> Die
	queue_free()

# --- TARGET SCANNING ---
func find_nearest_enemy(current_pos: Vector2) -> Node2D:
	var enemies = get_tree().get_nodes_in_group("Enemies")
	print("Ricochet Scan: Scanning ", enemies.size(), " total enemies.")
	
	var nearest_dist = 1000.0 * 1000.0 # Increase range temporarily to test
	var nearest_enemy = null
	
	for enemy in enemies:
		# 1. Skip self (Already hit)
		if enemy in hit_history:
			print(" - Skipped: Already hit")
			continue
		
		# 2. Skip dead
		if "hp" in enemy and enemy.hp <= 0:
			print(" - Skipped: Dead")
			continue
			
		# 3. Check Distance
		var dist = current_pos.distance_squared_to(enemy.global_position)
		var pixel_dist = sqrt(dist)
		
		print(" - Checking Enemy: ", enemy.name, " | Distance: ", int(pixel_dist))
		
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_enemy = enemy
			print("   -> NEW CANDIDATE!")
		else:
			print("   -> Too far / Not closer")
			
	if nearest_enemy:
		print(">> SELECTED TARGET: ", nearest_enemy.name)
	else:
		print(">> FAILURE: No valid target found.")
		
	return nearest_enemy

func spawn_explosion() -> void:
	var boom = EXPLOSION_SCENE.instantiate()
	
	# Spawn it in the world, not on the arrow (since arrow moves/dies)
	get_tree().current_scene.call_deferred("add_child", boom)
	
	boom.global_position = global_position
func onTimeOut() -> void:
	queue_free()
