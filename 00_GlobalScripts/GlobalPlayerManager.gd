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
var GLOBAL_CHEST_DATA : InventoryData = InventoryData.new()
# The default pool (Basic stats everyone starts with)
@export var default_upgrades: Array[UpgradeData] = [] 
# The pool of special skills you bought from Sylvana/Soran
var unlocked_upgrades: Array[UpgradeData] = [] 
#var level_requirements = [ 0, 50, 100, 200, 400, 800, 1500, 3000, 4500, 6000, 8500, 12000 ]
var level_requirements = [0 , 5 , 10 , 20 , 25 ]
var current_run_buffs : Dictionary = {
	"MAX_HP": 0,
	"ATTACK": 0,
	"DEFENSE": 0
}

func _ready() -> void:
	GLOBAL_CHEST_DATA.slots.resize(36) 
	getDefaultBuff()
	add_player_instance()
	await get_tree().create_timer(0.2).timeout
	playerSpawned = true
	pass
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
	# 1. Safety Check: Is the player dead/freed?
	if not is_instance_valid(player):
		print("Player was freed! Spawning a new instance.")
		add_player_instance() # Create a fresh player
	
	# 2. Existing Logic
	if player.get_parent():
		player.get_parent().remove_child(player)
	_p.add_child( player )
	pass
func unparent_player(_p : Node2D) -> void:
	_p.remove_child(player)
	pass
func play_audio( _audio : AudioStream) -> void:
	player.audio.stream = _audio
	player.audio.play()
	pass

func Interact() -> void:
	if LevelManager.is_transitioning:
		return
	interact_handled = false
	interact_pressed.emit()
	pass
func shakeCamera(trauma : float = 1) -> void:
	@warning_ignore("narrowing_conversion")
	camera_shook.emit(clampi(trauma,0 ,2))
	pass

func apply_hitstop(duration: float = 5.0) -> void:
	get_tree().paused = true
	await get_tree().create_timer(duration).timeout
	get_tree().paused = false
	pass
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
	pass
# Helper to check if we already bought it (so we don't buy it twice)
func has_unlocked(upgrade: UpgradeData) -> bool:
	return unlocked_upgrades.has(upgrade)

# Returns the COMPLETE list for the Battle Level Up Screen
func get_battle_upgrade_pool() -> Array[UpgradeData]:
	var total_pool = default_upgrades.duplicate()
	total_pool.append_array(unlocked_upgrades)
	return total_pool

func getDefaultBuff() -> void:
	# CRITICAL CHANGE: Use 'load()' instead of 'preload()'
	# preload() locks the asset at compile time, which causes the type mismatch.
	# load() grabs it fresh when the game actually runs.
	
	var muscle = load("res://GUI/Upgrades/skill_resources/Muscle.tres")
	if muscle: default_upgrades.append(muscle)
	
	#var iron = load("res://GUI/Upgrades/skill_resources/Iron Skin.tres")
	#if iron: default_upgrades.append(iron)
	#
	#var quick_draw = load("res://GUI/Upgrades/skill_resources/Attack Speed.tres")
	#if quick_draw : default_upgrades.append(quick_draw)
	#
	var crit_increase = load("res://GUI/Upgrades/skill_resources/Crit Increase.tres")
	if  crit_increase : default_upgrades.append(crit_increase)
	
	var crit_chance = load("res://GUI/Upgrades/skill_resources/VitalPoint.tres")
	if crit_chance : default_upgrades.append(crit_chance)
	pass
# 1. Called by the Item Effect when eating
func add_run_buff(stat_name: String, amount: float) -> void:
	if current_run_buffs.has(stat_name):
		current_run_buffs[stat_name] += amount
		print("Meal Eaten! Run Buff added: ", stat_name, " +", amount)
		# Optional: Play "Burp" sound?
	pass
# 2. Called when Spawning the Player in the Arena
# (Add this call inside your add_player_instance or _ready)
func apply_buffs_to_player_instance() -> void:
	if not player: return
	
	# Apply HP
	if current_run_buffs["MAX_HP"] > 0:
		player.max_hp += int(current_run_buffs["MAX_HP"])
		player.hp += int(current_run_buffs["MAX_HP"]) # Heal the difference
		player.update_hp(0) # Refresh UI
	
	# Apply Attack (Needs player variable support)
	# Assuming player.attack is a variable you can modify:
	if current_run_buffs["ATTACK"] > 0:
		player.attack += int(current_run_buffs["ATTACK"])
		
	# Apply Defense
	if current_run_buffs["DEFENSE"] > 0:
		player.defense += int(current_run_buffs["DEFENSE"])
	pass
# 3. Cleanup (Call this when returning to Camp or Dying)
func reset_run_buffs() -> void:
	current_run_buffs["MAX_HP"] = 0
	current_run_buffs["ATTACK"] = 0
	current_run_buffs["DEFENSE"] = 0
	pass
