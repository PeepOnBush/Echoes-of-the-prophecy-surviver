class_name BossEnemy extends Enemy # Inherits all your movement/damage logic


@export var boss_name: String = "King Goblin"
@export var portal_scene: PackedScene 
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
	# 1. Spawn the Portal
	if portal_scene:
		var portal = portal_scene.instantiate()
		
		# Configure the Portal
		portal.level = return_to_camp_scene
		portal.target_transition_area = "LevelTransition" # Or wherever you want to land in Camp
		portal.center_player = true
		if "is_dynamic_spawn" in portal:
			portal.is_dynamic_spawn = true
		# Add to Scene Root (So it doesn't get deleted with the boss)
		get_tree().current_scene.call_deferred("add_child", portal)
		portal.global_position = global_position
	
	# 2. NOW delete the boss
	# This triggers 'tree_exited', which tells the Spawner to stop via the signal we set up earlier.
	queue_free()
