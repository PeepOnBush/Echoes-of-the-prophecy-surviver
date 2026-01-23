extends Node2D

@export var bow_node : Node2D # Assign BowPivot here
@export var sword_node : Node2D # Assign SwordPivot here

@export var arrow_scene: PackedScene
@export var fire_rate: float = 0.2 
@export var sword_recoil_force: float = 250.0 

enum WeaponType { BOW, SWORD }
var current_weapon = WeaponType.BOW
var current_cooldown: float = 0.0

func _ready() -> void:
	equip_weapon(WeaponType.BOW)
	# --- NEW: SETUP SWORD HIT DETECTION ---
	var sword_hurtbox = sword_node.get_node_or_null("HurtBox") # Adjust path if needed!
	if sword_hurtbox:
		# We connect to the "did_damage" signal from your HurtBox.gd
		# Using a Callable bind isn't needed unless you want specific data
		sword_hurtbox.did_damage.connect(on_sword_hit)

func _process(delta: float) -> void:
	# 1. Weapon Switching Input
	if Input.is_action_just_pressed("weapon_1"): # Map Key '1'
		equip_weapon(WeaponType.BOW)
	elif Input.is_action_just_pressed("weapon_2"): # Map Key '2'
		equip_weapon(WeaponType.SWORD)

	# 2. Logic for Active Weapon
	if current_weapon == WeaponType.BOW:
		handle_bow(delta)
	elif current_weapon == WeaponType.SWORD:
		handle_sword(delta)

func equip_weapon(type: WeaponType) -> void:
	current_weapon = type
	
	if type == WeaponType.BOW:
		bow_node.visible = true
		sword_node.visible = false
		
		# Sword is NOT in hand, so it SHOULD be on back
		PlayerManager.player.show_sword_on_back = true
		
		# Logic cleanup
		sword_node.process_mode = Node.PROCESS_MODE_INHERIT
		disable_collision(sword_node, true)
		
	elif type == WeaponType.SWORD:
		bow_node.visible = false
		sword_node.visible = true
		
		# Sword IS in hand, so remove from back
		PlayerManager.player.show_sword_on_back = false
		
		disable_collision(sword_node, false)
	
	# Refresh Animation instantly so the sprite updates right now
	# (Access state machine current state to refresh correctly)
	if PlayerManager.player and PlayerManager.player.state_Machine:
		var machine = PlayerManager.player.state_Machine
		if machine.currentState:
			# If the machine is running, force an update
			# We can usually infer the generic state ("idle" or "walk") via Velocity
			# But honestly, we don't need to be precise here. Just re-triggering idle is fine for visual swap.
			PlayerManager.player.UpdateAnimation("idle")
	
	if type == WeaponType.BOW:
		bow_node.visible = true
		sword_node.visible = false
		# Disable Sword Physics so it doesn't kill while invisible
		sword_node.process_mode = Node.PROCESS_MODE_INHERIT
		disable_collision(sword_node, true)
		
	elif type == WeaponType.SWORD:
		bow_node.visible = false
		sword_node.visible = true
		disable_collision(sword_node, false)

func disable_collision(node: Node2D, disabled: bool) -> void:
	var hurtbox = node.get_node_or_null("HurtBox")
	if hurtbox:
		hurtbox.set_deferred("monitoring", !disabled)

# --- BOW LOGIC ---
func handle_bow(delta: float) -> void:
	bow_node.look_at(get_global_mouse_position())
	handle_flip(bow_node)
	
	if current_cooldown > 0: current_cooldown -= delta
	
	if Input.is_action_pressed("click") and current_cooldown <= 0:
		shoot()
		current_cooldown = fire_rate

func shoot():
	if arrow_scene:
		var arrow = arrow_scene.instantiate()
		get_tree().current_scene.add_child(arrow)
		arrow.global_position = bow_node.get_node("Muzzle").global_position
		arrow.rotation = bow_node.global_rotation
		arrow.max_bounces = PlayerManager.player.arrow_ricochet_amount

# --- SWORD LOGIC ---
@warning_ignore("unused_parameter")
func handle_sword(delta: float) -> void:
	# Logic: Point towards mouse
	sword_node.look_at(get_global_mouse_position())
	handle_flip(sword_node)
	
	# Since it follows the mouse, "Swinging" is done by the player moving the mouse.
	# The HurtBox stays active (managed by equip function).

func handle_flip(node: Node2D) -> void:
	var angle_degrees = node.rotation_degrees
	if abs(angle_degrees) > 90:
		node.scale.y = -1 
	else:
		node.scale.y = 1
@warning_ignore("unused_parameter")
func on_sword_hit(victim_hitbox) -> void:
	# Check if we are actually holding the sword
	if current_weapon == WeaponType.SWORD:
		# 1. Calculate direction AWAY from the mouse/sword tip
		var mouse_pos = get_global_mouse_position()
		var player_pos = PlayerManager.player.global_position
		
		# Direction from Mouse -> Player (Backward)
		var recoil_dir = (player_pos - mouse_pos).normalized()
		
		# 2. Apply Force to Player
		PlayerManager.player.apply_recoil(recoil_dir * sword_recoil_force)
		
		## 3. Optional: Screen Shake
		#PlayerManager.shakeCamera(0.2)
