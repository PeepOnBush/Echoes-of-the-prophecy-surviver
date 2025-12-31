class_name Arrow extends Node2D

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
	get_tree().create_timer(10.0).timeout.connect(onTimeOut)
	if fire_audio:
		audio_stream_player_2d.stream = fire_audio
		audio_stream_player_2d.play()
	
	# Rotate initially
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

# --- MODIFIED HIT LOGIC ---
func onDidDamage(victim_hitbox: HitBox) -> void:
	# 1. Identify the victim (Assuming HitBox is a child of the Enemy Node)
	var enemy = victim_hitbox.owner 
	# If 'owner' is not the enemy root, use victim_hitbox.get_parent()
	
	# 2. Add to history
	if enemy:
		hit_history.append(enemy)
	
	# 3. CHECK BOUNCE
	if current_bounces < max_bounces:
		var next_target = find_nearest_enemy(global_position)
		
		if next_target:
			# Target Found: Rotate arrow towards it
			current_bounces += 1
			
			# Point the arrow at the new target
			var direction_to_target = (next_target.global_position - global_position).normalized()
			rotation = direction_to_target.angle()
			
			# (Optional) Play sound? Speed up? Decrease Damage?
			return # KEEP FLYING!
	
	# No bounce left, or no targets found
	queue_free()

# --- TARGET SCANNING ---
func find_nearest_enemy(current_pos: Vector2) -> Node2D:
	var nearest_dist = 500.0 * 500.0 # Range limit (squared)
	var nearest_enemy = null
	
	# 1. Get the Main Scene Root (The Level)
	var main_scene = get_tree().current_scene
	
	# 2. Iterate through ALL children of the level
	# This avoids "Group" typos entirely.
	for node in main_scene.get_children():
		
		# 3. CLASS CHECK: Is this node an Enemy?
		if node is Enemy:
			var enemy = node
			
			# Validation Checks (Dead? Already hit?)
			if enemy in hit_history: continue
			if enemy.hp <= 0: continue
			
			# Distance Check
			var dist = current_pos.distance_squared_to(enemy.global_position)
			
			if dist < nearest_dist:
				nearest_dist = dist
				nearest_enemy = enemy
				
	return nearest_enemy

func onTimeOut() -> void:
	queue_free()
