extends Node

const PLAYER = preload("res://Player/player.tscn")
const INVENTORY_DATA : InventoryData = preload("res://GUI/pause_menu/inventory/player_inventory.tres")

signal leveled_up
signal interact_pressed
signal camera_shook(trauma : float)
var player : Player
var playerSpawned : bool = false
var interact_handled : bool = true


var level_requirements = [ 0, 50, 100, 200, 400, 800, 1500, 3000, 4500, 6000, 8500, 12000 ]

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
	if player.xp >= level_requirements[player.level]:
		player.level += 1
		player.attack += 1
		player.defense += 1
		leveled_up.emit()
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
