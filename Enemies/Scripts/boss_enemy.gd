class_name BossEnemy extends Enemy # Inherits all your movement/damage logic


@export var boss_name: String = "King Goblin"

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
	
