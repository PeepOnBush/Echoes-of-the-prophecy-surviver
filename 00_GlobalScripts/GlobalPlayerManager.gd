extends Node

const PLAYER = preload("res://Player/player.tscn")
const INVENTORY_DATA : InventoryData = preload("res://GUI/pause_menu/inventory/player_inventory.tres")
signal xp_changed
signal leveled_up
signal interact_pressed
signal camera_shook(trauma : float)
@warning_ignore("unused_signal")
signal enemy_defeated
var player : Player
var playerSpawned : bool = false
var interact_handled : bool = true
# The default pool (Basic stats everyone starts with)
var default_upgrades: Array[UpgradeData] = [] 
# The pool of special skills you bought from Sylvana/Soran
var unlocked_upgrades: Array[UpgradeData] = [] 
#var level_requirements = [ 0, 50, 100, 200, 400, 800, 1500, 3000, 4500, 6000, 8500, 12000 ]
var level_requirements = [0 , 5 , 10 , 20 , 25 ]
func _ready() -> void:
	add_player_instance()
	await get_tree().create_timer(0.2).timeout
	playerSpawned = true

func add_player_instance() -> void:
	player = PLAYER.instantiate()
	add_child(player)
	pass

func set_health( hp : int, max_hp : int) -> void:
	player.max_hp = max_hp
	player.hp = hp
	player.update_hp(0)
	pass

func rewardXP(_xp : int ) -> void:
	player.xp += _xp
	xp_changed.emit()
	checkForLevelAdvance()
	pass
 
func checkForLevelAdvance() -> void:
	if player.level >= level_requirements.size():
		return
	if player.xp >= level_requirements[player.level]:
		player.level += 1
		#player.attack += 1
		#player.defense += 1
		leveled_up.emit()
		#checkForLevelAdvance()
	pass


func set_player_position( _new_pos : Vector2 ) -> void:
	player.global_position = _new_pos
	pass
	
func set_as_parent( _p : Node2D) -> void:
	if player.get_parent():
		player.get_parent().remove_child(player)
	_p.add_child( player )

func unparent_player(_p : Node2D) -> void:
	_p.remove_child(player)

func play_audio( _audio : AudioStream) -> void:
	player.audio.stream = _audio
	player.audio.play()
	pass

func Interact() -> void:
	interact_handled = false
	interact_pressed.emit()

func shakeCamera(trauma : float = 1) -> void:
	@warning_ignore("narrowing_conversion")
	camera_shook.emit(clampi(trauma,0 ,2))

func apply_hitstop(duration: float = 5.0) -> void:
	get_tree().paused = true
	await get_tree().create_timer(duration).timeout
	get_tree().paused = false

func resetCameraOnPlayer(tween_duration : float = 0.5) -> void:
	var camera : Camera2D = get_viewport().get_camera_2d()
	if camera:
		if camera.get_parent() == player:
			return
		camera.reparent(player)
		
		var tween : Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_QUAD)
		tween.tween_property(camera,"position",Vector2.ZERO,tween_duration)
	pass

# Call this to unlock a new skill
func unlock_new_upgrade(upgrade: UpgradeData) -> void:
	if not unlocked_upgrades.has(upgrade):
		unlocked_upgrades.append(upgrade)
		# Save game here usually

# Helper to check if we already bought it (so we don't buy it twice)
func has_unlocked(upgrade: UpgradeData) -> bool:
	return unlocked_upgrades.has(upgrade)

# Returns the COMPLETE list for the Battle Level Up Screen
func get_battle_upgrade_pool() -> Array[UpgradeData]:
	var total_pool = default_upgrades.duplicate()
	total_pool.append_array(unlocked_upgrades)
	return total_pool
