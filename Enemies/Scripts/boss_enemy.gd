class_name BossEnemy extends Enemy # Inherits all your movement/damage logic

@export var is_final_boss : bool = false
@export var boss_name: String = "King Goblin"
@export var portal_scene: PackedScene 
@export var corpse_scene: PackedScene 

@export_file("*.tscn") var return_to_camp_scene : String 

func _ready() -> void:
	super() # Run the normal Enemy _ready()
	
	# 1. Wake up the HUD
	# (Assuming PlayerHud is a global singleton or accessed via Player)
	# If PlayerHud is not global, access it via: PlayerManager.player.player_hud
	PlayerHud.showBossHealth(boss_name)
	PlayerHud.updateBossHealth(hp, 10) # 500 is max_hp
		# JUICE: Zoom out camera to see the big boy
	var cam = get_viewport().get_camera_2d()
	if cam:
		var tween = create_tween()
		tween.tween_property(cam, "zoom", Vector2(0.8, 0.8), 1.0) # Zoom out to 0.8x
	
	pass
func _take_damage(hurt_box: HurtBox) -> void:
	# 1. Do normal damage logic
	super(hurt_box) 
	if hp < 0:
		# Check if this is the final boss
		if is_final_boss:
			# Trigger Victory Sequence via PlayerManager or direct call
				PlayerHud.showVictoryScreen()
				AudioManager.playMusic(null)
			# We might need to add a short delay for the death animation/particles
			# If victory doesn't appear immediately after, await get_tree().create_timer(0.5).timeout
	# 2. Update the UI Bar
	PlayerHud.updateBossHealth(hp, 10)

func _exit_tree() -> void:
	# 3. Hide bar when dead
	PlayerHud.hideBossHealth()
	# Restore Camera
	var cam = get_viewport().get_camera_2d()
	if cam:
		var tween = cam.create_tween()
		tween.tween_property(cam, "zoom", Vector2(1.0, 1.0), 1.0)
		print("zoomed back in")

func on_death_complete() -> void:
	if corpse_scene:
		var corpse = corpse_scene.instantiate() as BossCorpse
		
		var my_sprite = $Sprite2D 
		
		# --- THE FIX ---
		# Capture the scale BEFORE removing the child!
		# global_scale captures the size whether you scaled the Sprite itself OR the Boss root.
		var final_scale = my_sprite.global_scale 
		
		remove_child(my_sprite) 
		
		# Pass the scale as the 3rd argument
		corpse.setup(my_sprite, return_to_camp_scene, final_scale)
		# ---------------
		
		get_tree().current_scene.call_deferred("add_child", corpse)
		corpse.global_position = global_position
		
		LevelManager.increment_difficulty()
		print("going to " + return_to_camp_scene)
	
	queue_free()
	pass
